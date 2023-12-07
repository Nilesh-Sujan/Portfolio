"use strict";

/*
    This is an example of what a command script should look.
    Your commands should be stored in an object variable of any name. For this example the command was stored in a variable called example.

    ------------------------Command Properties------------------------------------------
    -----All commands must have these 4 properties---------------------------------------
    Name: sets the name of your command, a command can have multiple names. All names should be inside a [] (bracket)
    Level: sets the level a Discord member has to be in order to run this command. If set to Visitor then anyone can run the command
    Available: only 2 options, true or false. Set to true to allow your command to be used within the bot, set to false if you want to turn off the command so it cannot be run.
    Run: this is where you write the code for the command itself.

    You can also write any helper functions, variables, etc outside of module.exports for any extra help for your bot. Think of the Run function as your main() function that runs the rest of this command script.

    Remember to add your commands in the inside of module.exports. You can add multiple commands in one module.exports as long as they are in the form of a list {} 
    ALL COMMANDS MUST BE IN THE BRACKETS OF module.exports OR THEY WON'T APPEAR!!!
*/

var example = {
    Name : ["example", "ex"],
    Level: "User",
    Available: true,
    Run: function(message, params){
        message.channel.send("Hello world!");
    }
};

module.exports = [example];