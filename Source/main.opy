#!suppressWarnings w_already_imported
#!include "language.opy"
#!include "settings.opy"
#!include "ana.opy"
#!include "ai.opy"

globalvar isDebug

subroutine hudCreation
subroutine debug
subroutine ringCreation

#The first actions ran at game startup.
rule "Initial Setup":

    isDebug = createWorkshopSetting(bool, "Debug", "Enable Debug HUD", false)
    hudCreation()
    languageDetection()
    ringCreation()
    if isDebug == true:
        debug()
    else:
        disableInspector()

#Assembling heroes resets all variables set during waiting for game phase.
rule "Assembling Heroes Setup":
    @Condition isAssemblingHeroes() == true
    
    getAllPlayers().playerCarried = null
    getAllPlayers().thrower = null
    getAllPlayers().targetedPlayer = null
    getAllPlayers().isChasing = false
    getAllPlayers().detach()
    getAllPlayers().setMoveSpeed(100)
    setMatchTime(10)

#Creates core HUD elements.
def hudCreation():
    @Name "HUD Creation Subroutine"
    
    hudSubtext(getAllPlayers(), stringDiscord, HudPosition.RIGHT, -1, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), stringProject, HudPosition.RIGHT, -0.99, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), stringCode, HudPosition.RIGHT, -0.9, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " \n{0}".format(stringGH), HudPosition.RIGHT, -0.89, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(getAllPlayers(), stringTranslation, HudPosition.RIGHT, -2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    hudSubtext(getAllPlayers(), stringGHLink, HudPosition.RIGHT, -0.88, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if player.getUltCharge() == 100], "{0}{1}".format(buttonString(Button.ULTIMATE), stringUltEscape), HudPosition.TOP, 1.2, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubtext([player for player in getAllPlayers() if player.hasStatusEffect(Status.ASLEEP) == false], "{0}{1}".format(buttonString(Button.PRIMARY_FIRE), stringLeft), HudPosition.TOP, 1, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubtext([player for player in getAllPlayers() if player.hasStatusEffect(Status.ASLEEP) == false], "{0}{1}".format(buttonString(Button.SECONDARY_FIRE), stringRight), HudPosition.TOP, 1.1, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubtext([player for player in getAllPlayers() if player.thrower.playerCarried == player and player.hasStatusEffect(Status.ASLEEP) == false and canAutoEscape == false], "{0}{1}".format(buttonString(Button.JUMP), stringEscape), HudPosition.TOP, 1.3, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    
    if spawnAI == true:
        hudSubtext(getAllPlayers(), "{0} {1}".format(stringAnaBotSpawn, len([player for player in getAllPlayers() if player.isDummy() == true])), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

#!define playerRingCreation(playerNumber)     createEffect([player for player in getAllPlayers() if getPlayersInSlot(playerNumber, Team.ALL).hasStatusEffect(Status.ASLEEP) == true and getPlayersInSlot(playerNumber, Team.ALL).thrower == null], Effect.RING, Color.RED, getPlayersInSlot(playerNumber, Team.ALL).getPosition(), pickupRadius, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

#Creates other effects besides the HUD.
def ringCreation():
    @Name "Other Effect Creation"
    
    playerRingCreation(0)
    playerRingCreation(1)
    playerRingCreation(2)
    playerRingCreation(3)
    playerRingCreation(4)
    playerRingCreation(5)
    playerRingCreation(6)
    playerRingCreation(7)
    playerRingCreation(8)
    playerRingCreation(9)
    playerRingCreation(10)
    playerRingCreation(11)

    createEffect([_ for _, i in sorted(getAllPlayers(), lambda player: -1 * player.getScore()) if len(getAllPlayers()) > 0 and i != 0], Effect.GOOD_AURA, Color.YELLOW, (sorted(getAllPlayers(), lambda player: -1 * player.getScore()))[0], (scale/100)*2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createInWorldText([_ for _, i in sorted(getAllPlayers(), lambda player: -1 * player.getScore()) if len(getAllPlayers()) > 0 and i != 0], "#1", (sorted(getAllPlayers(), lambda player: -1 * player.getScore()))[0], 2.0, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText(getAllPlayers(), stringTitle, vect(0, 20, 113), 4, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText(getAllPlayers(), stringSubtitle, vect(0, 15, 113), 2, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

#Debug stuff created if enabled.
def debug():
    @Name "Debug Mode Setup"
    
    hudText(hostPlayer, getAverageServerLoad(), l"Server Load Average", null, HudPosition.LEFT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


