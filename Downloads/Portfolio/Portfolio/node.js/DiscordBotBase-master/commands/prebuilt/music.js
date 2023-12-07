const { Player } = require("discord-music-player");
const Discord = require("discord.js");
var client = null;

function createEmbed(data) {
    return new Discord.MessageEmbed()
        .setColor("#0099ff")
        .setTitle(data.title || " ")
        .setDescription(data.description);
}

var queue = {
    Name: ["queue", "q"],
    Level: "User",
    Available: true,
    Run: function(message, params){
        if(!client || !client.player) return;

        let queue = client.player.getQueue(message);
        let qString = (queue.songs.map((song, i) => {
            return `${i === 0 ? 'Now Playing' : `#${i+1}`} - ${song.name} | ${song.author}`
        }).join('\n'));
        if(queue)
            message.channel.send(createEmbed({
                title: "Queue",
                description: qString
            }));
    }
}

var play = {
    Name: ["play", "p"],
    Level: "User",
    Available: true,
    Run: async function (message, params) {
        if (!client || !client.player) {
            client = message.client;

            client.player = new Player(client, {
                leaveOnEmpty: true
            });
        }

        if (client.player.isPlaying(message)) {
            let song = await client.player.addToQueue(message, params.join(" "));

            if (song){
                message.channel.send(createEmbed({
                    title: "",
                    description: `Added ${song.name} to the queue [<@${message.author.tag}>]`
                }));
            }
            return;
        }
        else {
            let song = await client.player.play(message, params.join(" "));
            if (song){
                message.channel.send(createEmbed({
                    title: "",
                    description: `Started playing ${song.name} [<@${message.author.tag}>]`
                }));
            }
            return;
        }
    }
};

var playlist = {
    Name: ["playlist", "pl"],
    Level: "User",
    Available: true,
    Run: async function (message, params) {
        if (!client || !client.player) {
            client = message.client;

            client.player = new Player(client, {
                leaveOnEmpty: true
            });
        }

        await client.player.playlist(message, {
            search: params.join(" "),
            maxSongs: 50
        });
    }
};

var pause = {
    Name: ["pause"],
    Level: "User",
    Available: true,
    Run: async function (message, params) {
        if (!client || !client.player) return;

        let song = client.player.pause(message);

        if (song){
            message.channel.send(createEmbed({
                title: "",
                description: `${song.name} was paused [<@${message.author.tag}>]`
            }));
        }
    }
};

var progress = {
    Name: ["progress", "prog"],
    Level: "User",
    Available: true,
    Run: function (message, params) {
        if (!client || !client.player) return;

        let progressBar = client.player.createProgressBar(message, {
            size: 20,
            block: ":blue_square:",
            arrow: ":arrow_forward:"
        })

        if (progressBar){
            message.channel.send(createEmbed({
                title: "",
                description: progressBar
            }));
        }
    }
};

var currentSong = {
    Name: ["song"],
    Level: "User",
    Available: true,
    Run: async function (message, params) {
        if (!client || !client.player) return;

        let song = await client.player.nowPlaying(message);

        if (song) {
            message.channel.send(createEmbed({
                title: "Now Playing",
                description: song.name
            })
                .setThumbnail(song.thumbnail)
                .addField("User", `[<@${message.author.tag}>]`)
            );
        }
    }
}

var resume = {
    Name: ["resume"],
    Level: "User",
    Available: true,
    Run: async function (message, params) {
        if (!client || !client.player) return;

        let song = client.player.resume(message);

        if (song) {
            message.channel.send(createEmbed({
              title: "",
              description: `${song.name} was resumed [<@${message.author.tag}>]`  
            }));
        }
    }
};

var remove = {
    Name: ["remove"],
    Level: "User",
    Available: true,
    Run: function (message, params) {
        if (!client || !client.player) return;

        let songId = parseInt(params[0]) - 1;
        let song = client.player.remove(message, songId);
        if (song){
            message.channel.send(createEmbed({
                title: "",
                description: `Removed song ${song.name} ${params[0]} from the queue [<@${message.author.tag}>]`  
            }));
        }
    }
};

var skip = {
    Name: ["skip"],
    Level: "User",
    Available: true,
    Run: async function (message, params) {
        if (!client || !client.player) return;

        let song = client.player.skip(message);

        if (song){
            message.channel.send(createEmbed({
                title: "",
                description: `${song.name} was skipped [<@${message.author.tag}>]`  
            }));
        }
    }
};

var stop = {
    Name: ["stop", "disconnect", "dc"],
    Level: "User",
    Available: true,
    Run: async function (message, params) {
        if (!client || !client.player) return;

        let isDone = client.player.stop(message);

        if (isDone){
            message.channel.send(createEmbed({
                title: "",
                description: `Music stopped, the queue was cleared! [<@${message.author.tag}>]`  
            }));
        }
    }
};

var seek = {
    Name: ["seek"],
    Level: "User",
    Available: true,
    Run: async function (message, params) {
        if (!client || !client.player) return;

        let song = await client.player.seek(message, parseInt(params[0] * 1000));

        if(song){
            message.channel.send(createEmbed({
                title: "",
                description: `Seeked to ${params[0]} second of ${song.name} [<@${message.author.tag}>]` 
            }));
        }
    }
};

var setVolume = {
    Name: ["setvolume", "vol"],
    Level: "User",
    Available: true,
    Run: async function (message, params) {
        if (!client || !client.player) return;

        let isDone = client.player.setVolume(message, parseInt(params[0]));
        if (isDone){
            message.channel.send(createEmbed({
                title: "",
                description: `Volume set to ${params[0]}% [<@${message.author.tag}>]`
            }));
        }
    }
}

var shuffle = {
    Name: ["shuffle", "mix"],
    Level: "User",
    Available: true,
    Run: async function (message, params) {
        if (!client || !client.player) return;

        let songs = client.player.shuffle(message);
        if (songs){
            message.channel.send(createEmbed({
                title: "",
                description: `Server queue was shuffled [<@${message.author.tag}>]`
            }));
        }
    }
}

module.exports = [currentSong, queue, play, playlist, pause, progress, resume, remove, skip, stop, seek, setVolume, shuffle];