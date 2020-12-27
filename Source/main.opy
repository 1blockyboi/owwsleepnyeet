#!suppressWarnings w_already_imported
#!include "language.opy"
#!include "settings.opy"
#!include "ana.opy"
#!include "ai.opy"

globalvar isDebug
globalvar leader
globalvar leaderArray
globalvar titleColorR
globalvar titleColorG
globalvar titleColorB
globalvar y
globalvar spawnPositionArray

subroutine hudCreation
subroutine debug
subroutine ringCreation

#The first actions ran at game startup.
rule "Initial Setup":

    isDebug = createWorkshopSetting(bool, "Debug", "Enable Debug HUD", false)
    leader = null
    titleColorR = 255
    titleColorG = 0
    titleColorB = 0
    if (getCurrentMap() == Map.WORKSHOP_CHAMBER):
        y = 46
    else:
        y = 0
    spawnPositionArray = [vect(15, y, 15), vect(10, y, 15), vect(5, y, 15), vect(0, y, 15), vect(-5, y, 15), vect(-10, y, 15), vect(-15, y, 15), vect(15, y, 10), vect(15, y, 5), vect(15, y, 0), vect(15, y, -5), vect(15, y, -10), vect(15, y, -15), vect(10, y, -15), vect(5, y, -15), vect(0, y, -15), vect(-5, y, -15), vect(-10, y, -15), vect(-15, y, -15),  vect(-15, y, 10), vect(-15, y, 5), vect(-15, y, 0), vect(-15, y, -5), vect(-15, y, -10)]
    hudCreation()
    languageDetection()
    ringCreation()

    if (getCurrentMap() == Map.WORKSHOP_CHAMBER):
        createBeam(getAllPlayers(), Beam.GRAPPLE, vect(21,46,21), vect(24.495,101,24.495), Color.WHITE, EffectReeval.VISIBILITY)
        createBeam(getAllPlayers(), Beam.GRAPPLE, vect(21,46,-21), vect(24.495,101,-24.495), Color.WHITE, EffectReeval.VISIBILITY)
        createBeam(getAllPlayers(), Beam.GRAPPLE, vect(-21,46,21), vect(-24.495,101,24.495), Color.WHITE, EffectReeval.VISIBILITY)
        createBeam(getAllPlayers(), Beam.GRAPPLE, vect(-21,46,-21), vect(-24.495,101,-24.495), Color.WHITE, EffectReeval.VISIBILITY)
        createEffect(getAllPlayers(), Effect.SPHERE, Color.PURPLE, vect(0,120,0), 40, EffectReeval.VISIBILITY)
        createEffect(getAllPlayers(), Effect.SPHERE, Color.PURPLE, vect(0,120,0), 40, EffectReeval.VISIBILITY)
        createEffect(getAllPlayers(), Effect.SPHERE, Color.PURPLE, vect(0,120,0), 40, EffectReeval.VISIBILITY)
        createEffect(getAllPlayers(), Effect.SPHERE, Color.PURPLE, vect(0,120,0), 40, EffectReeval.VISIBILITY)
        createEffect(getAllPlayers(), Effect.SPHERE, Color.PURPLE, vect(0,120,0), 40, EffectReeval.VISIBILITY)
        createEffect(getAllPlayers(), Effect.SPHERE, Color.PURPLE, vect(0,120,0), 40, EffectReeval.VISIBILITY)
        createEffect(getAllPlayers(), Effect.SPHERE, Color.PURPLE, vect(0,120,0), 40, EffectReeval.VISIBILITY)
        createEffect(getAllPlayers(), Effect.SPHERE, Color.PURPLE, vect(0,120,0), 40, EffectReeval.VISIBILITY)
        createEffect(getAllPlayers(), Effect.SPHERE, Color.PURPLE, vect(0,120,0), 40, EffectReeval.VISIBILITY)
        createEffect(getAllPlayers(), Effect.SPHERE, Color.PURPLE, vect(0,120,0), 40, EffectReeval.VISIBILITY)

    elif (getCurrentMap() == Map.WORKSHOP_ISLAND_NIGHT):
        createEffect(getAllPlayers(), Effect.CLOUD, Color.WHITE, vect(0,-1,0), 20, EffectReeval.VISIBILITY)
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
    
    hudSubtext(getAllPlayers(), stringProject, HudPosition.RIGHT, -0.99, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), stringCode, HudPosition.RIGHT, -0.9, rgb(titleColorR,titleColorG,titleColorB), HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " \n{0}".format(stringGH), HudPosition.RIGHT, -0.89, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(getAllPlayers(), stringTranslation, HudPosition.RIGHT, -2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    hudSubtext(getAllPlayers(), stringGHLink, HudPosition.RIGHT, -0.88, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if player.getUltCharge() == 100], "{0}{1}".format(buttonString(Button.ULTIMATE), stringUltEscape), HudPosition.TOP, 1.2, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubtext([player for player in getAllPlayers() if player.hasStatusEffect(Status.ASLEEP) == false], "{0}{1}".format(buttonString(Button.PRIMARY_FIRE), stringLeft), HudPosition.TOP, 1, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubtext([player for player in getAllPlayers() if player.hasStatusEffect(Status.ASLEEP) == false], "{0}{1}".format(buttonString(Button.SECONDARY_FIRE), stringRight), HudPosition.TOP, 1.1, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubtext([player for player in getAllPlayers() if player.thrower.playerCarried == player and player.hasStatusEffect(Status.ASLEEP) == false and canAutoEscape == false], "{0}{1}".format(buttonString(Button.JUMP), stringEscape), HudPosition.TOP, 1.3, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    
    if spawnAI == true:
        hudSubtext(getAllPlayers(), "{0} {1}".format(stringAnaBotSpawn, len([player for player in getAllPlayers() if player.isDummy() == true])), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

#!define playerRingCreation(playerNumber)     createEffect([player for player in getAllPlayers() if getPlayersInSlot(playerNumber, Team.ALL).hasStatusEffect(Status.ASLEEP) == true and getPlayersInSlot(playerNumber, Team.ALL).thrower == null], Effect.RING, Color.RED if getPlayersInSlot(playerNumber, Team.ALL) != leader else Color.YELLOW, getPlayersInSlot(playerNumber, Team.ALL).getPosition(), pickupRadius, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)

#!define titleHud(height)   createInWorldText(getAllPlayers(), stringTitle, vect(0, 20 + (height), 113), 4, Clip.SURFACES, WorldTextReeval.VISIBILITY_STRING_AND_COLOR, rgb(titleColorR, titleColorG, titleColorB), SpecVisibility.DEFAULT)\
createInWorldText(getAllPlayers(), stringSubtitle, vect(0, 15 + (height), 113), 2, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

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

    createInWorldText([player for player in getAllPlayers() if leader != null and player != leader and leader.isAlive()], "#1", leader, 2.0, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, rgb(255,221,0), SpecVisibility.DEFAULT)
    titleHud(y)

#Debug stuff created if enabled.
def debug():
    @Name "Debug Mode Setup"
    
    hudText(hostPlayer, getAverageServerLoad(), l"Server Load Average", null, HudPosition.LEFT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer, hostPlayer.getPosition(), "Host Player Position", null, HudPosition.LEFT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

#Set a new leader.
rule "Set New First Place":
    @Condition (leader.getScore() < (sorted(getAllPlayers(), lambda player: -1 * player.getScore()))[0].getScore() and entityExists(leader)) or (leader == null and (sorted(getAllPlayers(), lambda player: -1 * player.getScore()))[0].getScore() > 0)

    leader.stopForcingOutlineFor(getAllPlayers())
    wait()
    leaderArray = (sorted(getAllPlayers(), lambda player: -1 * player.getScore()))
    if (len([x for x in leaderArray if x.getScore() >= leaderArray[0].getScore()]) > 1):
        leaderArray = [x for x in leaderArray if x.getScore() >= leaderArray[0].getScore()]
        leader = (sorted(leaderArray, lambda player: -1 * player.scoreTime))[0]
    else:
        leader = leaderArray[0]
    leader.stopForcingOutlineFor(getAllPlayers())
    leader.startForcingOutlineFor(getAllPlayers(), true, rgb(255,221,0), OutlineVisibility.ALWAYS)

#Get rid of leader when leader does not exist
rule "Destroy Leader":
    @Condition entityExists(leader) == false

    leader = null

#Wgeb a new player joins, force the outline of the leader.
rule "Leader Setup New Player":
    @Event playerJoined
    
    leader.startForcingOutlineFor(eventPlayer, true, rgb(255,221,0), OutlineVisibility.ALWAYS)

#Teleport Ana to the top of Workshop Chamber if that is the current map.
rule "Player Teleport":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()

    wait()
    eventPlayer.teleport(sorted(random.shuffle(spawnPositionArray), lambda position: len(getPlayersInRadius(position, 10, Team.ALL, LosCheck.OFF))))
    wait()
    eventPlayer.setFacing(directionTowards(eventPlayer, vect(0, y + (eventPlayer.getEyePosition() - eventPlayer.getPosition()), 0)), Relativity.TO_WORLD)
    eventPlayer.ready = true

#Chase color for fancy logo.
rule "Chase Color":
    chase(titleColorB, 255, rate = 300, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(titleColorB == 255, 9999)
    stopChasingVariable(titleColorB)
    chase(titleColorR, 0, rate = 300, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(titleColorR == 0, 9999)
    stopChasingVariable(titleColorR)
    chase(titleColorG, 255, rate = 300, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(titleColorG == 255, 9999)
    stopChasingVariable(titleColorG)
    chase(titleColorB, 0, rate = 300, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(titleColorB == 0, 9999)
    stopChasingVariable(titleColorB)
    chase(titleColorR, 255, rate = 300, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(titleColorR == 255, 9999)
    stopChasingVariable(titleColorR)
    chase(titleColorG, 0, rate = 300, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(titleColorG == 0, 9999)
    stopChasingVariable(titleColorG)
    goto RULE_START