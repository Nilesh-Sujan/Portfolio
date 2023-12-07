/*
    events.js

    This file is used to load all other Discord.js events like when a new member joins a server, when a member leaves a server, etc. All the events can be written inside the module.exports
    This file currently has a simple welcome message for whenever a new member joins and sends it to the welcome channel

    For a full list of events that Discord has please refer to:
        https://discord.js.org/#/docs/main/stable/class/Client
*/

module.exports = function(client){
    client.on("guildMemberAdd", member => {
        let channel = member.guild.channels.cache.find(ch => ch.name === "welcome");

        if(!channel){
            console.log("No welcome channel");
            return;
        } 
        channel.send(`Welcome to the server ${member.user.username}! Enjoy your stay!`);
    });
};