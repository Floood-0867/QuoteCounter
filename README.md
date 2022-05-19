# Quote-Counter
A discord bot that does all your quote related needs

## Features
- Recieving quotes from a discord server and adding them to a database
- Counting all quotes in the quote database
- Counting quotes in the quote database, but sorting by who has said what
- Saves all quotes to a server specific JSON file
- Custom admin role to be set by server owner
- Configuration file, done by server
- Seperate admin and normal help pages
- Clearing the database with a command
- Exporting the JSON file out of the server and sending through discord
- Editing quotes that are already in the quote database

##Planned Features
- Locking bot commands to a certain channel

## Regular Command List
- q!quote - Adds quotes to the database - Example: q!quote "example quote" - example author
- q!help - Brings up the help menu - Example: q!help
- q!edit - Edit a quote already in the database(Can only be used by the quotes subbmitter)(TBD) Example: q!edit 1 "edited example quote" - edited example author
- q!count - Counts all quotes in the database - Example: q!count
- q!countname - Sort all the quotes in the database by author(TBD) - Example: qcountbyname! OR q!countname
- q!ping - Pings the bot - Example: q!ping


## Admin Specific Command List
- q!help config - Brings up the admin help page - Example: q!help config
- q!admin - Set the admin role for admin commands(Can only be used by server owner) - Example: q!admin @role
- q!clear - Clear all quotes in the specific servers database - Example: q!clear
- q!export - Usage: Export the json file of the quotes. - Example:q!export

