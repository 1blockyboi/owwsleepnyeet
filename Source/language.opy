#!mainFile "main.opy"
globalvar stringCreator
globalvar stringVersion
globalvar stringDiscordLink
globalvar stringCode
globalvar stringGHLink
globalvar stringProjectLink
globalvar stringLeft
globalvar stringRight
globalvar stringObjective
globalvar stringPick
globalvar stringEscape
globalvar stringDiscord
globalvar stringSubtitle
globalvar stringProject
globalvar stringUltEscape
globalvar stringTranslation
globalvar stringGraspEscape
globalvar stringTitle
globalvar stringAnaBotSpawn
globalvar stringGH
subroutine languageDetection
subroutine englishStrings
subroutine simplifiedChineseStrings

#These strings are the same no matter the language.
rule "Constant Strings":
    stringCreator = "Block#12425"
    stringVersion = "1.3.2"
    stringDiscordLink = "discord.gg/CSKSVDH"
    stringProjectLink = "workshop.codes/sleepyeet"
    stringCode = "Code: QKTTV"
    stringGHLink = "grandeurhammers.com/discord"

#Language is determined by the host player's language. If the player's language is not support, it defaults to English.
def languageDetection():
    @Name "Language Detection"
    
    if "{0}".format(Hero.ANA) == "Ana":
        englishStrings()
    elif "{0}".format(Hero.ANA) == "安娜":
        simplifiedChineseStrings()
    else:
        englishStrings()

#English Strings
def englishStrings():
    @Name "English"
    
    stringSubtitle = "Created by: {0}. Version: {1}".format(stringCreator, stringVersion)
    stringLeft = ": to pick up sleeping player"
    stringRight = ": to yeet carried player"
    stringObjective = "Yeet sleeping players off the island!"
    stringPick = "Picked up"
    stringEscape = ": To escape her grasp!"
    stringDiscord = "Join the discord: {0} (All caps)".format(stringDiscordLink)
    stringProject = "Project: {0} (All lowercase)".format(stringProjectLink)
    stringUltEscape = ": To gain a speed boost and wake up if asleep!"
    stringTranslation = ""
    stringGraspEscape = " escaped!"
    stringTitle = "Sleep 'N Yeet"
    stringAnaBotSpawn = "{0} Ana bots Enabled. Current count:".format(abilityIconString(Hero.TORBJORN, Button.ABILITY_2))
    stringGH = "{0} Certified by Grandeur Hammers".format(abilityIconString(Hero.TORBJORN, Button.ABILITY_2))

#Simplified Chinese Strings
#Translated by Zesty#51453
def simplifiedChineseStrings():
    @Name "Simplified CN (Thanks to Zesty for translation)"
 
    stringSubtitle = "由{0}制作。版本：{1}".format(stringCreator, stringVersion)
    stringLeft = "：捡起沉睡的玩家"
    stringRight = "：抛投抓住的玩家"
    stringObjective = "把睡着的玩家丢出小岛！"
    stringPick = "捡起"
    stringEscape = "：逃离她的魔爪！"
    stringDiscord = "加入Discord：{0}（全大写）".format(stringDiscordLink)
    stringProject = "项目：{0}（全小写）".format(stringProjectLink)
    stringUltEscape = "：获得加速，如果是沉睡状态则将睡醒！"
    stringTranslation = "由Zesty#51453翻译"
    stringGraspEscape = "逃脱了！"
    stringTitle = "梦中丢人"
    stringAnaBotSpawn = "{0} 启用了安娜机器人。目前数量：".format(abilityIconString(Hero.TORBJORN, Button.ABILITY_2))
    stringGH = "{0} 由Grandeur Hammers认证".format(abilityIconString(Hero.TORBJORN, Button.ABILITY_2))