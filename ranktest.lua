local discordia = require("discordia")
local client = discordia.Client()
local token = require("../token")




local rankxp = {
	0,
	83,
	174,
	276,
	388,
	512,
	650,
	801,
	969,
	1154,
	1358,
	1584,
	1833,
	2107,
	2411,
	2746,
	3115,
	3523,
	3973,
	4470,
	5018,
	5624,
	6291,
	7028,
	7842,
	8740,
	9730,
	10824,
	12031,
	13363,
	14833,
	16456,
	18247,
	20224,
	22406,
	24815,
	27473,
	30408,
	33648,
	37224,
	41171,
	45529,
	50339,
	55649,
	61512,
	67983,
	75127,
	83014,
	91721,
	101333,
	111945,
	123660,
	136594,
	150872,
	166636,
	184040,
	203254,
	224466,
	247886,
	273742,
	302288,
	333804,
	368599,
	407015,
	449428,
	496254,
	547953,
	605032,
	668051,
	737627,
	814445,
	899257,
	992895,
	1096278,
	1210421,
	1336443,
	1475581,
	1629200,
	1798808,
	1986068,
	2192818,
	2421087,
	2673114,
	2951373,
	3258594,
	3597792,
	3972294,
	4385776,
	4842295,
	5346332,
	5902831,
	6517253,
	7195629,
	7944614,
	8771558,
	9684577,
	10692629,
	11805606,
	13034431,
	14391160,
	15889109,
	17542976,
	19368992,
	21385073,
	23611006,
	26068632,
	28782069,
	31777943,
	35085654,
	38737661,
	42769801,
	47221641,
	52136869,
	57563718,
	63555443,
	70170840,
	77474828,
	85539082,
	94442737,
	104273167
}

local function diffdate(Date)
	local d1 = {
		year = tonumber(string.sub(os.date("%F"), 1, 4)),
		month = tonumber(string.sub(os.date("%F"), 6, 7)),
		day = tonumber(string.sub(os.date("%F"), 9, 10))
	}
	local d2 = {
		year = tonumber(string.sub(Date, 1, 4)),
		month = tonumber(string.sub(Date, 6, 7)),
		day = tonumber(string.sub(Date, 9, 10))
	}
	print(string.format("Member joined at %d, it is now %d. They have been here for %d", os.time(d2), os.time(d1), os.difftime(os.time(d1), os.time(d2))))
	return os.difftime(os.time(d1), os.time(d2))
end

local function maxlevel(Number)
	local level = 120
	local levelxp = 0
	for i = 1, 120 do
		if rankxp[i] > Number then
			level = i - 1
			levelxp = rankxp[i - 1]
			nextlevelxp = rankxp[i]
			break
		end
	end
	print(string.format("Member had a total of %d xp, bringing them over %d required to get them to level %d", Number, levelxp, level))
	return level, Number, nextlevelxp - Number
end

local function removeroles(Guild)
	for role in Guild.roles  do
		if string.sub(role.name, 1, 5) == "Level" then
			print("Deleted role "..role.name)
			role:delete()
		end
	end
end

local function lwrite(String)
	local file = io.open("./levels.txt", "a")
	io.output(file)
	io.write(String)
	io.close(file)
end

local function createroles(Guild)
	local file = io.open("./levels.txt", "w+")
	io.close(file)
	for i = 1, 120 do
		levels[i] = Guild:createRole()
		levels[i].position = i + 7
		levels[i].name = "Level "..tonumber(i)
		levels[i].color = discordia.Color(math.floor(i * 2.125), 0, 255 - math.floor(i * 2.125))
		levels[i].hoist = true
		levels[i].mentionable = false
		print(string.format("Creating role %d of 120 (%f procent):%s", i, i/1.2, levels[i].name))
		lwrite(levels[i].id.."\n")
	end
end

local function giveroles(Guild)
	for member in Guild.members do
		print("Calculating level for "..member.name.."...")
		member:addRoles(levels[maxlevel(diffdate(member.joinedAt))])
	end
end

function fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local function loadroles(Guild)
	local num = 1
	for line in io.lines("./levels.txt") do
		levels[num] = Guild:getRole(line)
		print(string.format("Loaded role with id %s. Name: %s. Role %d#", line, levels[num].name, num))
		num = num + 1
	end
end

local levels = {}

local function gettime(Message)
	local level, number, nextlevelxp = maxlevel(diffdate(Message.member.joinedAt))
	return string.format("`You have %d xp, bringing you to level %d. Next level in %d xp.`", number, level, nextlevelxp)
end

client:on("ready", function()
	p(string.format("Logged in as %s", client.user.username))
end)

client:on("messageCreate", function(message)
	if message.author == client.user then return end
	local cmd, arg = string.match(message.content, "(%S+) (.*)")
	cmd = cmd or message.content

	if cmd == "!test" then
		for user in message.guild.members do
			print(user.name.."   "..tonumber(diffdate(user.joinedAt)))
		end
	end

	if cmd == "!createroles" then
		if message.author.id ~= message.guild.owner.id then return end
		if true then
			createroles(message.guild)
		end
	end
	if cmd == "!deleteroles" then
		if message.author.id ~= message.guild.owner.id then return end
		removeroles(message.guild)
	end

	if cmd == "!test2" then
		if message.author.id ~= message.guild.owner.id then return end
		for roles in message.guild.roles do
			print(roles.name.."  "..tostring(roles.position))
		end
	elseif cmd == "!pos" then
		if message.author.id ~= message.guild.owner.id then return end
		for role in message.mentionedRoles do
			role.position = 9
		end
	elseif cmd == "!giveroles" then
		if message.author.id ~= message.guild.owner.id then return end
		giveroles(message.guild)
	elseif cmd == "!loadroles" then
		loadroles(message.guild)
	elseif cmd == "!time" then
		message.channel:sendMessage(gettime(message))
	end
end)

client:run(_G.SPOOKY_TOKEN)
