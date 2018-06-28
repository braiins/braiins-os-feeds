#!/usr/bin/lua

local CJSON = require "cjson"
local SOCKET = require "socket"
local NX = require "nixio"

local CGMINER_HOST = "127.0.0.1"
local CGMINER_PORT = 4028

local SERVER_HOST = "*"
local SERVER_PORT = 4029

local HISTORY_SIZE = 60

local CHAINS = 6
local SAMPLE_TIME = 1
local MHS = {60, 300, 900}


local LED_PATH = '/sys/devices/soc0/amba_pl/amba_pl:leds/leds/Red LED'

-- utility functions
function log(fmt, ...)
	io.write((fmt..'\n'):format(...))
end

-- class declarations
local History = {}
History.__index = History

local RollingAverage = {}
RollingAverage.__index = RollingAverage

local CGMinerDevs = {}
CGMinerDevs.__index = CGMinerDevs

local Monitor = {}
Monitor.__index = Monitor

local Led = {}
Led.__index = Led

function get_uptime()
	return NX.sysinfo()['uptime']
end

-- Led class
function Led.new(path)
	local self = setmetatable({}, Led)
	self.path = path
	return self
end

function Led:sysfs_write(attr, val)
	local path = self.path..'/'..attr
	local f = io.open(path, 'w')
	if not f then
		log('failed to open %s', path)
		return
	end
	f:write(val)
	f:close()
end

function Led:set_mode(mode)
	log('led mode %s', mode)
	if mode == 'on' or mode == 'off' then
		self:sysfs_write('trigger', 'none')
		if mode == 'off' then
			self:sysfs_write('brightness', '0')
		else
			self:sysfs_write('brightness', '255')
		end
	elseif mode == 'blink-fast' or mode == 'blink-slow' then
		local time_on, time_off = 50, 950
		if mode == 'blink-fast' then
			time_off = 50
		end
		self:sysfs_write('trigger', 'timer')
		self:sysfs_write('delay_on', tostring(time_on))
		self:sysfs_write('delay_off', tostring(time_off))
	else
		log('bad led mode %s', mode)
		return
	end
end


-- History class
function History.new(max_size)
	local self = setmetatable({}, History)
	self.max_size = max_size
	self.size = 0
	self.pos = 1
	return self
end

function History:append(value)
	if self.size < self.max_size then
		table.insert(self, value)
		self.size = self.size + 1
	else
		self[self.pos] = value
		self.pos = self.pos % self.max_size + 1
	end
end

function History:values()
	local i = 0
	return function()
		i = i + 1
		if i <= self.size then
			return self[(self.pos - i - 1) % self.size + 1]
		end
	end
end

function History:last_value()
	if self.size then
		return self[self.pos]
	end
end

-- RollingAverage class
function RollingAverage.new(interval)
	local self = setmetatable({}, RollingAverage)
	self.interval = interval
	self.time = 0
	self.value = 0
	return self
end

function RollingAverage:add(value, time)
	local dt = time - self.time

	if dt <= 0 then
		return
	end

	local fprop = 1 - (1 / math.exp(dt / self.interval))
	local ftotal = 1 + fprop

	self.time = time
	self.value = (self.value + (value / dt * fprop)) / ftotal
end

-- CGMiner class
function CGMinerDevs.new(response)
	local self = setmetatable({}, CGMinerDevs)
	self.data = response and CJSON.decode(response)
	return self
end

function CGMinerDevs:get(id)
	if self.data then
		for _, dev in ipairs(self.data.DEVS) do
			if dev.ID == id then
				return dev
			end
		end
	end
end

-- Monitor class
function Monitor.new(history_size, led_path)
	local self = setmetatable({}, Monitor)
	self.history = History.new(history_size)
	self.last_time = 0
	self.chains = {}
	self.state = ''
	self.led_mode = 'on'
	self.led_override = false
	self.led = Led.new(led_path)
	for _ = 1,CHAINS do
		local chain = {}
		chain.temp = 0
		chain.errs_last = 0
		chain.errs = 0
		chain.accepted = 0
		chain.rejected = 0
		chain.mhs_cur = 0
		chain.mhs_max = 0
		chain.mhs_nom = 0
		chain.mhs = {}
		for _, interval in ipairs(MHS) do
			chain.mhs[interval] = RollingAverage.new(interval)
		end
		table.insert(self.chains, chain)
	end
	self:set_state('dead')
	return self
end

function Monitor:sample_time()
	local time_diff = get_uptime() - self.last_time
	return math.abs(time_diff) >= SAMPLE_TIME
end

function Monitor.copy_chain2sample(chain, sample, id)
	local sample_chain = {}
	sample_chain.id = id
	sample_chain.temp = chain.temp
	sample_chain.errs = chain.errs
	sample_chain.acpt = chain.accepted
	sample_chain.rjct = chain.rejected
	sample_chain.mhs = {chain.mhs_cur }
	for _, interval in ipairs(MHS) do
		local mhs = chain.mhs[interval]
		table.insert(sample_chain.mhs, mhs.value)
	end
	-- TODO: do not insert when each value is zero
	table.insert(sample.chains, sample_chain)
end

-- interpolation is done by duplication of last values
function Monitor:interpolate(count)
	local last_time = self.last_time

	for i = 1,count do
		local sample = {}
		local current_time = last_time + SAMPLE_TIME

		sample.time = current_time
		sample.chains = {}

		for i, chain in ipairs(self.chains) do
			local id = i - 1
			-- use previous value for rolling average
			for _, mhs in pairs(chain.mhs) do
				mhs:add(chain.mhs_cur, current_time)
			end
			-- copy current chain values to the sample
			self.copy_chain2sample(chain, sample, id)
		end

		self.history:append(sample)
		last_time = current_time
	end
end

function Monitor:add_sample(response)
	local devs = CGMinerDevs.new(response)
	local sample = {}
	local current_time = get_uptime()
	local time_diff = math.abs(current_time - self.last_time)

	if (self.last_time > 0) and (time_diff > SAMPLE_TIME) then
		-- interpolate missing samples
		local missing_samples = math.floor((time_diff - 1) / SAMPLE_TIME)
		missing_samples = math.min(missing_samples, HISTORY_SIZE)
		self:interpolate(missing_samples)
	end

	sample.time = current_time
	sample.chains = {}

	for i, chain in ipairs(self.chains) do
		local id = i - 1
		local dev = devs:get(id)
		if dev then
			local errs = dev["Hardware Errors"]
			chain.temp = dev["TempAVG"]
			chain.errs = chain.errs + errs - chain.errs_last
			chain.errs_last = errs
			chain.accepted = dev["Accepted"]
			chain.rejected = dev["Rejected"]
			chain.mhs_cur = dev["MHS 5s"]
			chain.mhs_nom = dev["nominal MHS"] or 0
			chain.mhs_max = dev["maximal MHS"] or 0
		else
			chain.temp = 0
			chain.errs_last = 0
			chain.accepted = 0
			chain.rejected = 0
			chain.mhs_cur = 0
			chain.mhs_nom = 0
			chain.mhs_max = 0
		end
		for _, mhs in pairs(chain.mhs) do
			mhs:add(chain.mhs_cur, current_time)
		end
		-- copy current chain values to the sample
		self.copy_chain2sample(chain, sample, id)
	end
	self.history:append(sample)
	self.last_time = current_time
end

-- check if all chains are at least at 80% of nominal rate
function Monitor:check_healthy()
	local healthy = true
	for i, chain in ipairs(self.chains) do
		if chain.mhs_nom > 0 then
			--log("chain %d health %f", i, chain.mhs_cur/chain.mhs_nom*100)
			if chain.mhs_cur < chain.mhs_nom*0.8 then
				healthy = false
			end
		end
	end
	return healthy
end

function Monitor:get_response()
	if self.history.size then
		local result = {}
		for sample in self.history:values() do
			table.insert(result, sample)
		end
		return CJSON.encode(result)
	end
end

function Monitor:update_led()
	if self.led_override then
		self.led:set_mode('blink-fast')
	else
		self.led:set_mode(self.led_mode)
	end
end

local state_to_led = {
	dead = 'on',
	ok = 'off',
	sick = 'blink-slow',
}

local function write_to_file(path, fmt, ...)
	local f = io.open(path, 'w')
	if not f then
		print('cannot open '..path)
		return
	end
	f:write(fmt:format(...))
	f:close()
end

local function fan_set_duty(n, duty)
	local prefix = ('/sys/class/pwm/pwmchip%d'):format(n)
	local period = 100000
	write_to_file(prefix..'/export', '0')
	write_to_file(prefix..'/pwm0/period', '%d', period)
	write_to_file(prefix..'/pwm0/duty_cycle', '%d', math.floor((100 - duty)*period))
	write_to_file(prefix..'/pwm0/enable', '1')
end

local function safety_turn_all_fans_on()
	print('turning all fans on')
	for i = 0, 2 do
		fan_set_duty(i, 100)
	end
end

function Monitor:set_state(state)
	if state == 'dead' then
		safety_turn_all_fans_on()
	end
	if state ~= self.state then
		log('state %s', state)
		self.led_mode = assert(state_to_led[state])
		self.state = state
		self:update_led()
	end
end


local monitor = Monitor.new(HISTORY_SIZE, LED_PATH)
local server = assert(SOCKET.bind(SERVER_HOST, SERVER_PORT))

-- server accept is interrupted every second to get new sample from cgminer
server:settimeout(SAMPLE_TIME)

-- wait forever for incomming connections
while true do
	local client, err = server:accept()
	if client == nil and err ~= 'timeout' then
		NX.nanosleep(SAMPLE_TIME)
	end

	if monitor:sample_time() then
		local cgminer = assert(SOCKET.tcp())
		local ret, err = cgminer:connect(CGMINER_HOST, CGMINER_PORT)
		if ret then
			cgminer:send('{ "command":"devs" }')
			-- read all data and close the connection
			local result = cgminer:receive('*a')
			if result then
				-- remove null from string
				result = result:sub(1, -2)
			end
			monitor:add_sample(result)
			-- check if miner is running ok
			if monitor:check_healthy() then
				monitor:set_state('ok')
			else
				monitor:set_state('sick')
			end
		else
			monitor:set_state('dead')
		end
	end
	if client then
		local response = monitor:get_response(history)
		if response then
			client:send(response)
		end
		client:settimeout(1)
		local ok, err = client:receive('*a')
		if ok then
			local w = ok:match('^(%w+)')
			if w == 'on' then
				monitor.led_override = true
			elseif w == 'off' then
				monitor.led_override = false
			end
			monitor:update_led()
		end
		client:close()
	end
end
