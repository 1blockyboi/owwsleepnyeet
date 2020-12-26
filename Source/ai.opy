#!mainFile "main.opy"
#!include "ana.opy"
#!include "language.opy"

globalvar aiNumber
globalvar aimInaccuracyExtremes
globalvar spawnAI
globalvar willAttackPlayers
globalvar willEscape
globalvar willJump
globalvar willRoam
globalvar willUlt

playervar targetedPlayer
playervar isChasing
playervar aimInaccuracy

subroutine targetRoam

#!define positions(pos1, pos3, pos2)  [vect((pos1), (pos3), 0), vect((pos1), (pos3), (pos2)), vect((pos1), (pos3), -1 * (pos2)), vect(-1 * (pos1), (pos3), 0), vect(-1 * (pos1), 0, (pos2)), vect(-1 * (pos1), (pos3), -1 * (pos2)), vect(0, (pos3), (pos1)), vect((pos2), (pos3), (pos1)), vect(-1 * (pos1), (pos3), (pos1)), vect(0, (pos3), -1 * (pos1)), vect((pos2), (pos3), -1 * (pos1)), vect(-1 * (pos2), (pos3), -1 * (pos1))]
#Creates Workshop Settings for AI Bots.
rule "Initial Setup":
    spawnAI = createWorkshopSetting(bool, "Bots", "Bots Spawn", true)
    aiNumber = createWorkshopSetting(int<0:10>, "Bots", "Number of minimum required bots/players", 8)
    aimInaccuracyExtremes = createWorkshopSetting(float<0:10>, "Bots", "Range of Aim Error", 2)
    #This array is used by the bots to find different spots on the map
    positionArray = (positions(27, 46, 13.5) if getCurrentMap() == Map.WORKSHOP_CHAMBER else positions(25, 0, 12.5))
    willAttackPlayers = createWorkshopSetting(bool, "Bots", "Attack players (shoot sleep dart, chase, and yeet)", true)
    willEscape = createWorkshopSetting(bool, "Bots", "Bots will attempt to escape", true)
    willJump = createWorkshopSetting(bool, "Bots", "Bots will jump", true)
    willRoam = createWorkshopSetting(bool, "Bots", "Bots will roam around the map", true)
    willUlt = createWorkshopSetting(bool, "Bots", "Bots will use ultimate", true)

#Spawns AI when the player count is less than aiNumber    
rule "Spawn AI":
    @Condition spawnAI == true
    @Condition len(getAllPlayers()) < aiNumber
    
    wait(1, Wait.ABORT_WHEN_FALSE)
    createDummy(Hero.ANA, Team.ALL, -1, nearestWalkablePosition(vect(random.uniform(-20, 20), 0, random.uniform(-20, 20))), vect(0, 0, 0))
    getLastCreatedEntity().aimInaccuracy = vect(random.uniform(-1 * aimInaccuracyExtremes, aimInaccuracyExtremes), 0, random.uniform(-1 * aimInaccuracyExtremes, aimInaccuracyExtremes))
    if RULE_CONDITION:
        goto RULE_START

#Deletes AI if bots are overflowing the player count limit aiNumber.
rule "Delete AI":
    @Condition spawnAI == true
    @Condition len(getAllPlayers()) > aiNumber
    @Condition len([player for player in getAllPlayers() if player.isDummy() == true]) > 0
    
    wait(1, Wait.ABORT_WHEN_FALSE)
    destroyDummy(Team.ALL, (random.choice([player for player in getAllPlayers() if player.isDummy() == true])).getSlot())
    wait(1, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION:
        goto RULE_START

#Resets bot to the target roam state on spawn.
rule "Reset Player Target on Spawn":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasSpawned() == true
    
    targetRoam()

#Target Roam State: Targeting Subroutine: targets nearby non-sleeping players. Sets the facing direction towards the player plus aimInaccuracy vector. Determines a random aimInaccuracy vector.
def targetRoam():
    @Name "Target Roam Subroutine"
    
    eventPlayer.targetedPlayer = (sorted([player for player in getLivingPlayers(Team.ALL) if player.hasStatusEffect(Status.ASLEEP) == false and eventPlayer != player], lambda i: distance(eventPlayer, i)))[0]
    eventPlayer.startFacing(directionTowards(eventPlayer, eventPlayer.targetedPlayer + (eventPlayer.targetedPlayer.getVelocity() * (sqrt(distance(eventPlayer, eventPlayer.targetedPlayer) ** 2 / (3600 - eventPlayer.targetedPlayer.getSpeed() ** 2)))) + eventPlayer.aimInaccuracy), 600, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    eventPlayer.aimInaccuracy = vect(random.uniform(-1 * aimInaccuracyExtremes, aimInaccuracyExtremes), 0, random.uniform(-1 * aimInaccuracyExtremes, aimInaccuracyExtremes))

#Target Roam State: Movement: Determine a random throttle direction. Causes random jumping.
rule "Roam":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isChasing == false
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == false
    
    if willRoam == true:
        eventPlayer.startThrottleInDirection(vect(random.uniform(-1, 1), 0, random.uniform(-1, 1)), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    else:
        eventPlayer.stopThrottleInDirection()
    
    if random.randint(0, 5) <= 3 and willJump == true:
        eventPlayer.startForcingButton(Button.JUMP)
        wait()
        eventPlayer.stopForcingButton(Button.JUMP)
    wait(0.7, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION:
        goto RULE_START

#Target Roam State: Targeting Subroutine activation loop.
rule "Target Player while Roaming":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isChasing == false
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == false
    @Condition eventPlayer.playerCarried == []
    
    targetRoam()
    wait(5, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

#Target Roam State: Shoot Sleep Dart.
rule "Shoot sleep":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isChasing == false
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == false
    @Condition willAttackPlayers == true
    
    if (random.randint(0,1) == 1):
        eventPlayer.startForcingButton(Button.ABILITY_1)
        wait()
        eventPlayer.stopForcingButton(Button.ABILITY_1)
    wait(1)
    if RULE_CONDITION:
        goto RULE_START

#Chasing State: Chase Slept Player.
rule "Target Sleeping Player":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.targetedPlayer.hasStatusEffect(Status.ASLEEP) == true
    @Condition eventPlayer.playerCarried == []
    @Condition willAttackPlayers == true
    
    eventPlayer.isChasing = true
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer, eventPlayer.targetedPlayer), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.communicate(Comms.HELLO)

#Chasing State: Throw Carried Player off edge.
rule "Launch Player":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isChasing == true
    @Condition (eventPlayer.getPosition().x >= 17 - (throwStrength*0.4/10) or eventPlayer.getPosition().x <= -17 + (throwStrength*0.4/10) or eventPlayer.getPosition().z >= 17 - (throwStrength*0.4/10) or eventPlayer.getPosition().z <= -17 + (throwStrength*0.4/10)) == true
    @Condition len(eventPlayer.playerCarried) > 0
    @Condition willAttackPlayers == true
    
    eventPlayer.startForcingButton(Button.SECONDARY_FIRE)
    wait()
    eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
    eventPlayer.communicate(Comms.GOODBYE)

#Chasing State: Pick up slept player.
rule "Pick Up Player":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isChasing == true
    @Condition (len([player for player in getLivingPlayers(Team.ALL) if distance(player, eventPlayer) <= pickupRadius - (pickupRadius*0.333) and player.hasStatusEffect(Status.ASLEEP) == true])) > 0
    @Condition eventPlayer.playerCarried == []
    @Condition willAttackPlayers == true
    
    eventPlayer.stopForcingThrottle()
    if random.uniform(0, 1) > 0.7:
        wait(0.25)
        eventPlayer.stopThrottleInDirection()
        eventPlayer.startForcingButton(Button.CROUCH)
        wait(0.1)
        eventPlayer.stopForcingButton(Button.CROUCH)
        wait(0.15)
        eventPlayer.startForcingButton(Button.CROUCH)
        wait(0.1)
        eventPlayer.stopForcingButton(Button.CROUCH)
        wait(0.1)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
    wait()
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START

#Chasing State: Target nearest map edge vector.
rule "Move to Edge With Player":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isChasing == true
    @Condition len(eventPlayer.playerCarried) > 0
    @Condition willAttackPlayers == true
    
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer, sorted(positionArray, lambda player: distance(eventPlayer, player))[0]), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.targetedPlayer = sorted(positionArray, lambda player: distance(eventPlayer, player))[0]
    wait(3)
    if RULE_CONDITION:
        goto RULE_START

#Reset values from either state. Reverts to Target Roam state.
rule "Death Reset":
    @Event playerDied
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    
    eventPlayer.targetedPlayer = null
    eventPlayer.isChasing = false
    eventPlayer.stopForcingThrottle()

#When slept, state is reverted to Target Roam state.
rule "Sleep Reset":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == true
    
    eventPlayer.stopFacing()
    eventPlayer.targetedPlayer = null
    eventPlayer.isChasing = false
    eventPlayer.stopForcingThrottle()

#Target Roam State: Escape if captured by player.
rule "Escape":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.thrower != null
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == false
    @Condition willEscape == true
    
    autoEscape()
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START

#Activate Ult in either state.
rule "Ultimate usage":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.getUltCharge() == 100
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition willUlt == true
    
    eventPlayer.startForcingButton(Button.ULTIMATE)
    wait()
    eventPlayer.stopForcingButton(Button.ULTIMATE)

#Chasing State: If in Target Roam state, convert to chasing state, and run away from edge. Afterwards, revert to Target Roam State, even if it initially was in chasing state.
rule "Retreat from map edge":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition (eventPlayer.getPosition().x + 2 >= 21 or eventPlayer.getPosition().x - 2 <= -21 or eventPlayer.getPosition().z + 2 >= 21 or eventPlayer.getPosition().z - 2 <= -21) == true
    
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer, vect(0, 0, 0)), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.isChasing = true
    wait(0.7)
    if RULE_CONDITION:
        goto RULE_START
    eventPlayer.isChasing = false

#Chasing State: Revert to Target Roam state once player is thrown.    
rule "Stop Chasing After Removing Carried Players":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.playerCarried == []
    
    eventPlayer.isChasing = false

#Chasing State: Reverts to Target Roam state if targeted Player is eliminated through other means.
rule "Stop Staring at Dead Target":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.targetedPlayer.y <= -1
    @Condition entityExists(eventPlayer.targetedPlayer) == true
    @Condition eventPlayer.isChasing == true
    
    eventPlayer.isChasing = false

#Chasing State: If targeted player is picked up by other player, revert to Target Roam state.
rule "Stop targeting dead player":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.targetedPlayer.thrower != null
    @Condition entityExists(eventPlayer.targetedPlayer) == true
        
    eventPlayer.isChasing = false

#Chasing State: While carrying one player, pick up addition sleeping players in route.
rule "Pick up players while going to edge":
    @Event eachPlayer
    @Hero all
    @Condition spawnAI == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isChasing == true
    @Condition (len([player for player in getLivingPlayers(Team.ALL) if distance(player, eventPlayer) <= pickupRadius - (pickupRadius*0.333) and player.hasStatusEffect(Status.ASLEEP) == true and player.thrower == null])) > 0
    @Condition entityExists(eventPlayer.targetedPlayer) == false
    @Condition willAttackPlayers == true
    
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
    wait()
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)