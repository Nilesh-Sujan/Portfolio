const ms = require("ms");

var mute = {
    "Name" : ["mute"],
    "Level": "Admin",
    "Available": true,
    "Run": function(message, params){
        let mutedRole = message.guild.roles.cache.find(role => role.name == "Muted");
        if(!mutedRole) return message.channel.send("There is no muted role in this server.");

        let target = message.mentions.members.first();

        if(!target) return message.channel.send("You need to mention someone to mute");

        try{
            target.roles.add(mutedRole);

            var reply = `${target.user.username} has been muted`;
            if(params.length == 2){
                setTimeout(() => {
                    target.roles.remove(mutedRole);
                }, ms(params[1]));
                reply += ` for ${params[1]}`;
            }
            message.channel.send(reply);
        }catch(e){
            console.log(e);
        }
        
    }
};

module.exports = [mute];