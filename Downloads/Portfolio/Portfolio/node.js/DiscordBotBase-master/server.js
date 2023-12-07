"use strict";

const Discord = require("discord.js");
const Config = require("./settings/Config.json");
const Levels = require("./settings/Levels.json");
const Events = require("./discord_events/events");
const path = require("path");
const glob = require("glob");

let client = new Discord.Client();

var PREFIXES = {};
var commands = {};

function initializePrefixes() {
    for (var level in Config.prefixes) {
        if (level.includes("^")) {
            var startLevel = level.replace("^", "");
            var startLevelNum = Levels[startLevel];

            for (var prefix of Config.prefixes[level]) {
                PREFIXES[prefix] = {
                    Check: function (curLevel) {

                        return curLevel >= startLevelNum;
                    }
                }
            }
        }
        else {
            var numLevel = Levels[level];

            for (var prefix of Config.prefixes[level]) {
                PREFIXES[prefix] = {
                    Check: function (curLevel) {

                        return curLevel == numLevel;
                    }
                };
            }
        }
    }
}

function loadCommands() {
    try {
        glob.sync("./commands/**/*.js").forEach((file) => {

            for (var extraCmds in Config.prebuiltCommands) {
                if (file.includes(`${extraCmds}.js`) && !Config.prebuiltCommands[extraCmds])
                    return;
                else
                    console.log(`Loaded ${file}`);
            }

            var cmdFile;
            cmdFile = require(path.resolve(file));

            for (const cmd of cmdFile) {
                var numLevel = Levels[cmd.Level];

                for (var prefix in PREFIXES) {
                    if (commands[prefix] == null)
                        commands[prefix] = {};

                    if (PREFIXES[prefix].Check(numLevel)) {

                        for (const name of cmd.Name) {
                            commands[prefix][name] = {
                                Run: function (message, params) {
                                    for (var curRole in Config.Roles) {
                                        if (curRole == "@everyone" || message.member.roles.cache.find(role => role.name == curRole)) {
                                            var roleLevel = Levels[Config.Roles[curRole]];

                                            if (roleLevel >= numLevel && cmd.Available) {
                                                try {
                                                    cmd.Run(message, params);
                                                } catch (e) {
                                                    console.log(e);
                                                }

                                                return;
                                            }
                                        }
                                    }
                                }
                            };
                        }

                    }
                }
            }

        });
    } catch (e) {
        console.log(e);
    }
}

function searchCommands(message) {
    var msg = message.content;
    var command = "";
    var params;

    for (var prefix in PREFIXES) {
        if (msg.startsWith(prefix)) {
            params = msg.split(Config.separator);
            command = params.splice(0, 1)[0].substring(0 + prefix.length);

            if (commands[prefix][command])
                commands[prefix][command].Run(message, params);
            break;
        }
    }
}

client.on("ready", () => {
    try {
        initializePrefixes();
        loadCommands();
        console.log("Bot ready");
    }
    catch (err) {
        console.log(err);
    }
});

client.on("message", async (message) => {
    if (message.author.bot) return;
    
    try {
        searchCommands(message);
    } catch (e) {
        console.log(e);
    }


});

Events(client);
client.login(Config.token);