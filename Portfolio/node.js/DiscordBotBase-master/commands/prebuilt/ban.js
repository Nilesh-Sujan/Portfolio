const Discord  = require("discord.js");

var ban = {
    Name : ["ban"],
    Level : "Super Admin",
    Available: true,
    Run : function(message, params){
        let target = message.mentions.members.first();

        if(!target) return message.channel.send("You need to mention a user to ban");

        try{
            var reason = "No reason";

            if(typeof params[1] != "undefined")
                reason = params[1];

            let userMsg = new Discord.MessageEmbed()
                .setTitle("You have been banned")
                .setColor("76b3fc")
                .addField('Reason: ', reason)
                .addField(`Kicked by:`, message.author.username);


            target.ban().then((member) => {
                message.channel.send(`:wave: ${member.displayName} has been successfully banned!`);

                try{
                    target.send(userMsg);
                }catch(e){
                    console.log(e);
                }
                
            });
        }catch(e){
            console.log(e);
        }
        
    }
};

module.exports = [ban];