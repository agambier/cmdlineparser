-- NOTE: Change package path according to your Lua interpreter
package.path = package.path .. ";E:\\AGProjects\\cmdlineparser.git\\?.lua"

-- load CmdLineParser module
require "cmdlineparser"

-- Create a command line parser
local parser = CmdLineParser:new( "helloworld", "Hello World example for the Lua CmdLineParser" )

-- Add some options
parser:addOption( "username", "World", "Set user name" )
parser:addOption( "saybyebye", false, "Ask the app to say goodbye" )

-- Parse the command line
local result = parser:parse( arg, false )
if ( not result ) or parser.help.value then
	if not result then
		print( "ERROR: Failed to parse the command line" )
	end
	
	-- display the help section
	print( parser:helpToString() )
	-- ##### RETURN #####
	return
end

-- Say hello
print( "Hello " .. parser.username.value .." !" )

-- Say bye bye
if parser.saybyebye.value then
	print( "Bye bye " .. parser.username.value .." !" )
end

