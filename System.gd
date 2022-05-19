extends Node

var quotedata = []
var empty = []

var prefix = "q!"

var botcolor = "#a34488"


func _ready():
	var bot = DiscordBot.new()
	add_child(bot)
	bot.connect("bot_ready", self, "_on_bot_ready")
	bot.connect("message_create", self, "_on_message_create")
	bot.TOKEN = "your_bot_token_here"
	#bot.VERBOSE = true
	bot.login()

func _on_bot_ready(bot: DiscordBot):
	print("Logged in as " + bot.user.username + "#" + bot.user.discriminator)
	print("Listening on " + str(bot.channels.size()) + " channels and " + str(bot.guilds.size()) + " guilds.")
	bot.set_presence({
		"activity": {
			"type": "Game",
			"name": "q!help"
		}
	})

func _on_message_create(bot: DiscordBot, message: Message, channel: Dictionary):
	
	
	
	if message.author.bot or not message.content.begins_with(prefix):
		return
	
	
	var server = message.guild_id
	var sender = message.author.id
	var senderName = message.author.username + "#" + message.author.discriminator
	var senderId = message.author.id
	var content = message.content.trim_prefix(prefix).strip_edges()
	
	print("Received message: " + content)
	
	
	if content.begins_with("quote"):
		load_file("user://" + server + ".json")
		content = content.trim_prefix("quote")
		
		var sent = content.strip_edges().replace("”","\"").split("\"")
		
		#if the array is too big or too small, the bot won't let the command continue
		if sent.size() != 3:
			bot.send(message, "This message contains bad data, try qhelp! if you have difficulties.")
		else:
			var quote = sent[1].strip_edges()
			var author = sent[2].strip_edges().trim_prefix("-").strip_edges()
			bot.send(message, "\"" + quote + "\" -" + author)
			
			
			var datatoadd = {"quote" : quote, "author" : author, "sender ID" : senderId, "senderName": senderName}
			
			quotedata.append(datatoadd)
			
			var dm_channel = yield(bot.create_dm_channel(senderId), "completed")
			bot.send(dm_channel.id, "You have quoted " + author + " on the quote: \"" + quote + "\".\n Your quote is number " + str(quotedata.size()) + " on the quotes list.")
			
			
			save_file("user://" + server + ".json")
		
	elif content.begins_with("count") && content.ends_with("count") :
		load_file("user://" + server + ".json")
		bot.send(message, "Total Amount of Quotes: " + str(quotedata.size()))
	
	elif content.begins_with("countname"):
		load_file("user://" + server + ".json")
		var botembed = Embed.new()
		botembed.title = "QUOTES BY NAME"
		botembed.color = botcolor
		var currentname = null;
		var quotecount = 0;
		var count = 0;
		
		if quotedata.size() == 0:
			bot.send(message, "Cannot complete operation, quote list is empty")
			return
		
		
		
		
		
		var authornames = []
		
		"sort though the array and find every different author"
		
		currentname = quotedata[0].author.to_lower()
		authornames.append(currentname)
		for i in quotedata.size():
			currentname = quotedata[i].author.to_lower()
			if authornames.has(currentname):
				i+=1
			else:
				authornames.append(currentname)
				i+=1
		
		
		var authorcount = []
		
		
		for i in quotedata.size():
			currentname = quotedata[i].author.to_lower()
			authorcount.append(currentname)
			i+=1
		
		print(authorcount)
		
		var authorbycount = []
		
		var up = 0;
		for i in authornames.size():
			if up >= 25:
				bot.send(message, {"embeds": [botembed]})
				botembed.slice_fields(0,botembed._to_dict().fields.size())
				up = 0
			currentname = authornames[i]
			var a = authorcount.count(authornames[i])
			botembed.add_field(currentname.capitalize(),str(a), true)
			up += 1
		
		
		
		bot.send(message, {"embeds": [botembed]})
	
	elif content.begins_with("help"):
		content = content.trim_prefix("help").strip_edges()
		print(content)
		if content.begins_with("config"):
			load_file("user://config" + server + ".json")
			var config = quotedata
			if config.empty(): return
			if message.member.roles.has(config[0].values()[0]):
				var botembed = Embed.new()
				botembed.title = "QUOTE COUNTER HELP"
				botembed.color = botcolor
				botembed.add_field("q!export", "Usage: Export the json file of the quotes.\nExample:q!export", true)
				botembed.add_field("q!clear", "Usage: Clear the quotes list.\nExample:q!clear", true)
				botembed.add_field("q!admin", "Usage: Assign a role to quote admin(Can only be used by server owner).\nExample:q!assignadmin @role", true)
				
				bot.send(message, {"embeds": [botembed]})
			else: print("bad")
		else:
			var botembed = Embed.new()
			botembed.title = "QUOTE COUNTER HELP"
			botembed.color = botcolor
			botembed.add_field("q!help", "Usage: Send this help message.\nExample:q!help", true)
			botembed.add_field("q!quote", "Usage: Adding quotes to the database.\nExample: q!quote \"example quote\" -author ", true)
			botembed.add_field("q!edit", "Usage: Edit a specific quote within the database.\nExample: q!edit 1 \"edited example quote\" -author \n(Can only be used by the original submitter of the quote)", true)
			botembed.add_field("q!count", "Usage: Count all quotes in the database.\nExample: q!count", true)
			botembed.add_field("q!countname", "Usage: Sort all quotes in the database by author.\nExample: q!countbyname", true)
			botembed.add_field("q!countsubmit(TBD)", "Usage: Sort all quotes in the database by submitter.\nExample: q!countbyname", true)
			botembed.add_field("q!ping", "Usage: Ping the bot.\nExample: q!ping", true)
			botembed.add_field("q!help config", "Usage: Bring up the configuartion help page(admin only).\nExample: q!config", true)
			
			
			bot.send(message, {"embeds": [botembed]})
	
	elif content.begins_with("ping"):
		bot.send(message, "pong")
	
	elif content.begins_with("export"):
		load_file("user://config" + server + ".json")
		var config = quotedata
		if config.empty(): return
		if message.member.roles.has(config[0].values()[0]):
			
			var file = File.new()
			file.open("user://" + server + ".json", File.READ)
			
			
			var file_data: PoolByteArray = file.get_buffer(file.get_len())
			file.close()
			
			
			var sendfile = {
				"data": file_data,
				"name": "server.json",
				"media_type": "application/json"
			}
			
			
			bot.send(message, {"files": [sendfile]})
	
	elif content.begins_with("edit"):
		load_file("user://" + server + ".json")
		content = content.trim_prefix("edit")
		
		var sent = content.strip_edges().replace("”","\"").split("\"")
		
		#if the array is too big or too small, the bot won't let the command continue
		if sent.size() != 3:
			bot.send(message, "This message contains bad data, try qhelp! if you have difficulties.")
		else:
			var num = sent[0].strip_edges()
			
			var errortrue = false
			if num.empty() || !num.is_valid_integer():
				bot.send(message, "This message contains an invalid quote number, try qhelp! if you have difficulties.")
				errortrue = true
			elif int(num) <= 0:
				bot.send(message, "This message contains a non-existant quote in the list, please try again.")
				errortrue = true
			elif int(num) > quotedata.size():
				bot.send(message, "This message contains a non-existant quote in the list, please try again.")
				errortrue = true
			elif quotedata[int(num)-1].get("sender ID") != message.author.id:
				bot.send(message, "This edit references a quote that you have not submitted, please try again.")
				errortrue = true
			if errortrue:
				return
			
			
			var quote = sent[1].strip_edges()
			var author = sent[2].strip_edges().trim_prefix("-").strip_edges()
			bot.send(message, "\"" + quote + "\" -" + author)
			
			
			var datatoadd = {"quote" : quote, "author" : author, "sender ID" : senderId, "senderName": senderName}
			
			quotedata[int(num)-1] = datatoadd
			print(quotedata[int(num)-1])
			
			var dm_channel = yield(bot.create_dm_channel(senderId), "completed")
			bot.send(dm_channel.id, "You have edited the quote number " + num + " to the quote: \"" + quote + "\".")
			
			
			save_file("user://" + server + ".json")
	
	elif content.begins_with("admin"):
		var guild = bot.guilds[channel.guild_id]
		if guild.owner_id == sender:
			load_file("user://config" + server + ".json")
			var config = quotedata
			
			print("Received message: " + content)
			var sent = message.mention_roles
			if sent.size() == 1:
				sent = sent[0]
				
				#print(sent)
				
				
				var datatoadd = {"AdminRole": sent}
				config.remove(0)
				config.insert(0,datatoadd)# = datatoadd
				
				quotedata = config
				save_file("user://config" + server + ".json")
				bot.send(message, "New Admin Role Accepted")
			else:
				pass
		else:
			bot.send(message, "You need to be the server owner to accses this command")
	
	elif content.begins_with("clear"):
		quotedata = empty
		save_file("user://" + server + ".json")

func load_file(path):
	var file = File.new()
	
	if not file.file_exists(path):
		reset_data(path)
	
	file.open(path, File.READ)
	
	var text = file.get_as_text()
	
	quotedata = parse_json(text)
	
	file.close()


func save_file(path):
	var file = File.new()
	
	file.open(path, File.WRITE)
	
	file.store_line(to_json(quotedata))
	
	file.close()


func reset_data(path):
	quotedata = empty.duplicate(true)
	save_file(path)

