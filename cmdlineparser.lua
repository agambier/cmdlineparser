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
	
	-- Table used to store infos about added options
	newObj._infos = {}
	
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
	self[ name ] = defaultValue

	-- add associated infos
	self._infos[ name ] = {}
	self._infos[ name ].defaultValue = defaultValue
	self._infos[ name ].help = help
	self._infos[ name ].isHidden = isHidden or false
	self._infos[ name ].type = optionType
end

--
--
--
function CmdLineParser:parse( cmdLine, failOnError )
	local infos
	local optionName
	failOnError = failOnError or false

	if "table" == type( cmdLine ) then
		for i=1,#arg do
			if "--" == arg[ i ]:sub( 1, 2 ) then
				-- get CmdLineParserion name
				optionName = arg[ i ]:sub( 3 )
				infos = self._infos[ optionName ]

				if not infos then
					-- handle this kind of error ?
					if failOnError then
						-- ##### RETURN #####
						return false
					end
				elseif CmdLineParser.Types.Boolean == infos.type then
					-- it's a boolean so it does not need a value
					self[ optionName ] = true
					infos = nil
				end

			elseif infos then
				-- Get a value
				if CmdLineParser.Types.Number == infos.type then
					self[ optionName ] = tonumber( arg[ i ] )
				elseif CmdLineParser.Types.String == infos.type then
					self[ optionName ] = arg[ i ]
				end

				infos = nil
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
	for name in pairs( self ) do
		local infos = self._infos[ name ]
		
		-- options DO have associated infos
		if infos then
			if showHiddens or ( not infos.isHidden ) then
				result = result .. "\n  --" .. name 
				if CmdLineParser.Types.Boolean ~= infos.type then
					result = result .. " VALUE"
				end
				result = result .. "\n"
						
				if infos.help then
					result = result .. "      " .. infos.help .. "\n"
				end
				
				result = result .. "      Default value : " .. tostring( infos.defaultValue ) .. "\n"
				
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
	
	for name, value in pairs( self ) do
		if "table" ~= type( value ) then
			result = result .. name .. " = " .. tostring( value ) .. "\n"
		end
	end
	
	return result
end
