-- Initialization script
function OnInit(event)
	-- Define pattern names
	OK_PATTERN_COUNT    = 0
	OK_PATTERN_LFSR     = 1
	OK_PATTERN_WALKING1 = 2
	OK_PATTERN_WALKING0 = 3
	OK_PATTERN_HAMMER   = 4
	OK_PATTERN_NEIGHBOR = 5

	-- Init global values
	m_segmentSize = 4*1024*1024
	m_throttleIn = 0xffffffff
	m_throttleOut = 0xffffffff
	m_fixedPattern = 0
	m_check = true
	m_injectError = false
	m_transferSize = 0xffffffff
	m_blockSize = 0

	m_statusString = ""
	m_errorString = ""
	UpdateStatus()

	m_devInfo = OpalKelly.okTDeviceInfo()
	assert(event:GetDevice():GetDeviceInfo(m_devInfo) ==
		OpalKelly.FrontPanel_NoError, "GetDeviceInfo() failed")
end

-- Set up global variables from GUI controls
function Setup()
	local panel = okUI:FindPanel("panel1")

	m_throttleIn = panel:FindDigitEntry("throttleIn"):GetValue()
	m_throttleOut = panel:FindDigitEntry("throttleOut"):GetValue()

	local patternCombobox = panel:FindCombobox("pattern")
	m_pattern = patternCombobox:GetValue(patternCombobox:GetSelection())

	local injectErrorCombobox = panel:FindCombobox("injectError")
	m_injectError =
		(injectErrorCombobox:GetValue(injectErrorCombobox:GetSelection()) ~= 0)

	SetReadErrorsCount(0)
end

-- `Read From Pipe Out` button event
function OnPipeOutButton(button, event)
	if not button:IsPressed() then return end

	SetError("")
	SetStatus("Reading From Pipe Out...")

	local panel = okUI:FindPanel("panel1")
	m_transferSize = panel:FindDigitEntry("readLengthBytes"):GetValue()

	Setup()
	Transfer(event:GetDevice(), 1, false);

	SetStatus("Done.")
end

-- `Write To Pipe In` button event
function OnPipeInButton(button, event)
	if not button:IsPressed() then return end

	SetError("")
	SetStatus("Writing To Pipe In...")

	local panel = okUI:FindPanel("panel1")
	m_transferSize = panel:FindDigitEntry("writeLengthBytes"):GetValue()

	Setup()
	Transfer(event:GetDevice(), 1, true);

	SetStatus("Done.")
end

function SetError(str)
	m_errorString = str
	UpdateStatus()
end

function SetStatus(str)
	m_statusString = str
	UpdateStatus()
end

function SetReadErrorsCount(errorsCount)
	local panel = okUI:FindPanel("panel1")
	panel:FindDigitDisplay("readErrors"):SetValue(errorsCount)
end

function UpdateStatus()
	local logControl = okUI:FindPanel("panel1"):FindControl("status")

	local status = "Status: " .. m_statusString
	if m_errorString ~= nil and m_errorString ~= "" then
		status = status .. "\nError: " .. m_errorString
	end

	logControl:SetLabel(status)
end

-- Sets the reset state of the pattern generator based on the
-- selected pattern.
function PatternReset()
	-- return wordH, wordL
	if m_pattern == OK_PATTERN_COUNT then
		return 0x00000001, 0x00000001
	elseif m_pattern == OK_PATTERN_FIXED then
		return m_fixedPattern, m_fixedPattern
	end
	return 0x00000000, 0x00000000
end

-- Computes the next word in the data pattern based on the
-- selected pattern and the output word width (in bits).
function PatternNext(wordH, wordL, width)
	-- Global values
	neighborH = 0xFFFFFFFF
	neighborL = 0xFFFFFFFE

	local bit
	local hold
	local nextWordH = wordH
	local nextWordL = wordL

	-- return nextWordH, nextWordL

	if m_pattern == OK_PATTERN_COUNT then
		nextWordH = wordH + 1
		nextWordL = wordL + 1
	end

	return nextWordH, nextWordL
end

-- Generates a buffer of data following the selected data pattern
-- and word width.
function GenerateData(valid, byteCount, width)
	local wordH, wordL = PatternReset()

	if 64 == width then
		for i = 0, byteCount/8 - 1 do
			valid[i*8 + 0] = (wordL >> 0) & 0xff
			valid[i*8 + 1] = (wordL >> 8) & 0xff
			valid[i*8 + 2] = (wordL >> 16) & 0xff
			valid[i*8 + 3] = (wordL >> 24) & 0xff
			valid[i*8 + 4] = (wordH >> 0) & 0xff
			valid[i*8 + 5] = (wordH >> 8) & 0xff
			valid[i*8 + 6] = (wordH >> 16) & 0xff
			valid[i*8 + 7] = (wordH >> 24) & 0xff
			wordH, wordL = PatternNext(wordH, wordL, width)
		end
	elseif 32 == width then
		for i = 0, byteCount/4 - 1 do
			valid[i*4 + 0] = (wordL >> 0) & 0xff
			valid[i*4 + 1] = (wordL >> 8) & 0xff
			valid[i*4 + 2] = (wordL >> 16) & 0xff
			valid[i*4 + 3] = (wordL >> 24) & 0xff
			wordH, wordL = PatternNext(wordH, wordL, width)
		end
	elseif 16 == width then
		for i = 0, byteCount/2 - 1 do
			valid[i*2 + 0] = (wordL >> 0) & 0xff
			valid[i*2 + 1] = (wordL >> 8) & 0xff
			wordH, wordL = PatternNext(wordH, wordL, width)
		end
	elseif 8 == width then
		for i = 0, byteCount - 1 do
			valid[i] = wordL & 0xff
			wordH, wordL = PatternNext(wordH, wordL, width)
		end
	end

	-- Inject errors (optional)
	if m_injectError then
		if valid[7] > 1 then
			valid[7] = valid[7] - 1
		else
			valid[7] = valid[7] + 1
		end
	end
end

function CheckData(buffer, valid, byteCount)
	local errorsCount = 0
	for i = 0, byteCount/4 - 1 do
		if buffer[i] ~= valid[i] then
			errorsCount = errorsCount + 1
		end
	end

	return errorsCount
end


function Transfer(dev, count, isWrite)
	local buffer = OpalKelly.Buffer(m_segmentSize)
	local valid = OpalKelly.Buffer(m_segmentSize)
	local segmentSize = 0
	local remaining = 0
	local ret = 0

	-- Check capability bits for newer patterns
	-- Bit 0 - added Fixed pattern
	dev:UpdateWireOuts()
	if (dev:GetWireOutValue(0x3E) & 0x1) ~= 0x1 and m_pattern == OK_PATTERN_FIXED then
		SetError("Fixed pattern is not supported by this bitstream. Switching to LFSR.")
		m_pattern = OK_PATTERN_LFSR
	end

	-- Only COUNT and LFSR are supported on non-USB3 devices.
	if OpalKelly.OK_INTERFACE_USB3 ~= m_devInfo.deviceInterface then
		if  m_pattern == OK_PATTERN_WALKING0 or
			m_pattern == OK_PATTERN_WALKING1 or
			m_pattern == OK_PATTERN_HAMMER or
			m_pattern == OK_PATTERN_NEIGHBOR then
				SetError("Unsupported pattern for device type.  Switching to LFSR.")
				m_pattern = OK_PATTERN_LFSR
		end
	end

	if OpalKelly.OK_INTERFACE_USB3 == m_devInfo.deviceInterface then
		dev:SetWireInValue(0x03, m_fixedPattern)   -- Apply fixed pattern
		dev:SetWireInValue(0x02, m_throttleIn)     -- Pipe In throttle
		dev:SetWireInValue(0x01, m_throttleOut)    -- Pipe Out throttle
		dev:SetWireInValue(0x00, (m_pattern<<2) | 1<<1 | 1)  -- PATTERN | SET_THROTTLE=1 | RESET=1
		dev:UpdateWireIns()
		dev:SetWireInValue(0x00, (m_pattern<<2) | 0<<1 | 0)  -- PATTERN | SET_THROTTLE=0 | RESET=0
		dev:UpdateWireIns()
	else
		dev:SetWireInValue(0x02, m_throttleIn)     -- Pipe In throttle
		dev:SetWireInValue(0x01, m_throttleOut)    -- Pipe Out throttle
		dev:SetWireInValue(0x00, 1<<5 | ((m_pattern==OK_PATTERN_LFSR and 1 or 0)<<4) | 1<<2)  -- SET_THROTTLE=1 | MODE=LFSR | RESET=1
		dev:UpdateWireIns()
		dev:SetWireInValue(0x00, 0<<5 | ((m_pattern==OK_PATTERN_LFSR and 1 or 0)<<4) | 0<<2)  -- SET_THROTTLE=0 | MODE=LFSR | RESET=0
		dev:UpdateWireIns()
	end

	for i = 1, count do
		remaining = m_transferSize
		while remaining > 0 do
			segmentSize = math.min(m_segmentSize, remaining)
			remaining = remaining - segmentSize

			-- If we're validating data, generate data per segment.
			if m_check then
				if OpalKelly.OK_INTERFACE_USB3 == m_devInfo.deviceInterface then
					dev:SetWireInValue(0x00, (m_pattern<<2) | 0<<1 | 1)  -- PATTERN | SET_THROTTLE=0 | RESET=1
					dev:UpdateWireIns()
					dev:SetWireInValue(0x00, (m_pattern<<2) | 0<<1 | 0)  -- PATTERN | SET_THROTTLE=0 | RESET=0
					dev:UpdateWireIns()
				else
					dev:SetWireInValue(0x00, 0<<5 | ((m_pattern==OK_PATTERN_LFSR and 1 or 0)<<4) | 1<<2)  -- SET_THROTTLE=0 | MODE=LFSR | RESET=1
					dev:UpdateWireIns()
					dev:SetWireInValue(0x00, 0<<5 | ((m_pattern==OK_PATTERN_LFSR and 1 or 0)<<4) | 0<<2)  -- SET_THROTTLE=0 | MODE=LFSR | RESET=0
					dev:UpdateWireIns()
				end
				GenerateData(valid, segmentSize, m_devInfo.pipeWidth)
			end

			if isWrite then
				if 0 == m_blockSize then
					ret = dev:WriteToPipeIn(0x80, segmentSize, valid)
				else
					ret = dev:WriteToBlockPipeIn(0x80, m_blockSize, segmentSize, valid)
				end
			else
				if 0 == m_blockSize then
					ret = dev:ReadFromPipeOut(0xA0, segmentSize, buffer)
				else
					ret = dev:ReadFromBlockPipeOut(0xA0, m_blockSize, segmentSize, buffer)
				end
			end

			if ret < 0 then
				if ret == OpalKelly.FrontPanel_InvalidBlockSize then
					error("Block Size Not Supported")
				elseif ret == OpalKelly.FrontPanel_UnsupportedFeature then
					error("Unsupported Feature")
				else
					error("Transfer Failed with error: " .. ret)
				end

				if dev:IsOpen() == false then
					error("Device disconnected")
				end

				return
			end

			if m_check then
				local errorsCount = 0
				if false == isWrite then
					errorsCount = CheckData(buffer, valid, segmentSize)
					SetReadErrorsCount(errorsCount)
				else
					dev:UpdateWireOuts()
					errorsCount = dev:GetWireOutValue(0x21)
				end

				if 0 ~= errorsCount then
					SetError("Data check failed!")
				end
			end
		end
	end
end