-- Declare a namespace
CmdLineParser = {
	_VERSION = "-.--",
	
	-- option types
	Types = { Boolean = 0, Number = 1, String = 3 }
}
CmdLineParser.__index = CmdLineParser

---------------------------------------------------
--  private members
--	weak table storing private members for each instance
----------------------------------------------------- 
--local g_atPMembers = setmetatable( {}, { __mode = "k" } ) 

---------------------------------------------------
--  private functions
---------------------------------------------------

--
--
--
local function _tostring( self )
	if self.customToString then
		-- ##### RETURN #####
		return self:toString()
	end
	
	return tostring( self )
end
CmdLineParser.__tostring = _tostring


---------------------------------------------------
--  public functions
---------------------------------------------------

--	Function:	CmdLineParser:new
--		Constructor.
--		Call this function to create a new instance.
--
--	Parameters:
--		appName			[string]	Application name.
--		appDescription	[string]	Short description.
--
--	Returns:
--		Returns a new instance of the class.
function CmdLineParser:new( appName, appDescription )
	local newObj = {}

	setmetatable( newObj, CmdLineParser )

	-- public members
	newObj.customToString = false
	newObj.appName = appName;
	newObj.appDescription = appDescription;
	
	-- add default help option
	newObj:addOption( "help", false, "Display this help." )
	
	return newObj
end

--
--
--
function CmdLineParser:setCustomToString( enabled )
	self.customToString = enabled or false
end

function CmdLineParser:addOption( name, defaultValue, help, isHidden )
	local optionType, valueType

	-- detect type
	valueType = type( defaultValue )
	if "boolean" == valueType then
		optionType = CmdLineParser.Types.Boolean
		defaultValue = false
	elseif "number" == valueType then
		optionType = CmdLineParser.Types.Number
	elseif "string" == valueType then
		optionType = CmdLineParser.Types.String
	else
		-- ##### RETURN #####
		return -- unsupported type
	end

	-- add 
	self[ name ] = {}
	self[ name ].value = defaultValue

	-- associated settings
	self[ name ].defaultValue = defaultValue
	self[ name ].help = help
	self[ name ].isHidden = isHidden or false
	self[ name ].type = optionType
end

--
--
--
function CmdLineParser:parse( cmdLine, failOnError )
	local currentOption = nil
	failOnError = failOnError or false

	if "table" == type( cmdLine ) then
		for i=1,#arg do
			if "--" == arg[ i ]:sub( 1, 2 ) then
				-- get CmdLineParserion name
				currentOption = self[ arg[ i ]:sub( 3 ) ]

				if not currentOption then
					-- handle this kind of error ?
					if failOnError then
						-- ##### RETURN #####
						return false
					end
				elseif CmdLineParser.Types.Boolean == currentOption.type then
					-- it's a boolean so it does not need a value
					currentOption.value = true
					currentOption = nil
				end

			elseif currentOption then
				-- Get a value
				if CmdLineParser.Types.Number == currentOption.type then
					currentOption.value = tonumber( arg[ i ] )
				elseif CmdLineParser.Types.String == currentOption.type then
					currentOption.value = arg[ i ]
				end

				currentOption = nil
			end
		end
	end

	return true
end

--
--
--
function CmdLineParser:helpToString( showHiddens )
	local result = ""

	--	Application name
	result = "USAGE: " .. tostring( self.appName ) .. " [OPTION [VALUE]]\n"
	
	--	Description
	if self.appDescription then
		result = result .. self.appDescription .. "\n"
	end
	
	--	List of options
	result = result .. "\nOPTIONS"
	for key, value in pairs( self ) do
		--	for now, tables are options added to the parser
		if "table" == type( value ) then
			local option = self[ key ]
			
			if showHiddens or ( not option.isHidden ) then
				result = result .. "\n  --" .. key 
				if CmdLineParser.Types.Boolean ~= option.type then
				result = result .. " VALUE"
				end
				result = result .. "\n"
						
				if option.help then
					result = result .. "      " .. option.help .. "\n"
				end
				
				result = result .. "      Default value : " .. tostring( option.defaultValue ) .. "\n"
				
			end
		end
	end
		
	return result
end

--
--
--
function CmdLineParser:toString()
	local result = ""
	
	for key, value in pairs( self ) do
		local valueType = type( value )
		if "string" == valueType then
			result = result .. key .. " = " .. value .. "\n"
		elseif "table" == valueType then
			--	for now, tables are options added to the parser
			result = result .. key .. " = " .. tostring( self[ key ].value ) .. "\n"
		end
	end
	
	return result
end
