#!mainFile "main.opy"

settings {
    "main": {
        "description": "Sleep 'N Yeet! By: Block#12425. Version: 1.3.1. Use Workshop Settings to change the game! Additional language support: Simplified CN."
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "spectatorSlots": 6,
        "returnToLobby": "never"
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps": [
                "workshopIsland",
                "workshopIslandNight"
            ]
        },
        "general": {
            "enableHeroSwitching": false,
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "respawnTime%": 20
        }
    },
    "heroes": {
        "allTeams": {
            "ana": {
                "enableAbility2": false,
                "damageDealt%": 10,
                "movementSpeed%": 110,
                "enableScoping": false,
                "enablePrimaryFire": false,
                "enableMelee": false,
                "combatUltGen%": 0,
                "passiveUltGen%": 0,
                "ultGen%": 10
            },
            "enabledHeroes": [
                "ana"
            ]
        }
    }
}