-- NOTE: Change package path according to your Lua interpreter
package.path = package.path .. ";E:\\AGProjects\\cmdlineparser.git\\?.lua"

-- load CmdLineParser module
require "cmdlineparser"

function test( str )
	print( tostring( str:match( '=' ) )  )
	if str:match( '=' ) then
		local name, value = str:match( '^%-%-([^%-]*)="?([^"]*)"?' )
		print( "Value : " .. name .. " = " .. value )
	else
		print( "Boolean : " .. str:match( '^%-%-([^%-]*)' ) )
	end
end

test( '--username' )
test( '--username=alex' )
test( '--username="alexandre gambier"' )
test( '--username="ale= gambier=5"' )


-- Create a command line parser
local parser = CmdLineParser:new( "helloworld", "Hello World example for the Lua CmdLineParser" )

-- Add some options
parser:addOption( "username", "World", "Set user name" )
parser:addOption( "saybyebye", false, "Ask the app to say goodbye" )

-- Hidden options
parser:addOption( "birthday", false, "whish happy birthday", true )

-- Parse the command line
local result = parser:parse( arg, false )
if ( not result ) or parser.help then
	if not result then
		print( "ERROR: Failed to parse the command line" )
	end
	
	-- display the help section (use 'true' to show hidden options)
	print( parser:helpToString( false ) )
	-- ##### RETURN #####
	return
end

-- Say hello
print( "Hello " .. parser.username .." !" )

-- Happy birthday
if parser.birthday then
	print( "Today is your birthday. Happy Birthday !" )
end

-- Say bye bye
if parser.saybyebye then
	print( "Bye bye " .. parser.username .." !" )
end

