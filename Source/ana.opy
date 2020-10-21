#!mainFile "main.opy"
#!include "language.opy"

globalvar canAutoEscape
globalvar sleepDuration
globalvar ultPercentage
globalvar pickupRadius
globalvar positionArray
globalvar throwStrength
globalvar scale
globalvar moveSpeed
globalvar sleepCD
globalvar jumpSpeed

playervar playerCarried
playervar thrower
playervar i
playervar j

subroutine autoEscape

#Declare variables for new player.
rule "New Player Setup":
    @Event eachPlayer
    @Hero all
    @Condition isGameInProgress() == true
    
    setObjectiveDescription(eventPlayer, stringObjective, HudReeval.VISIBILITY)
    eventPlayer.startHoT(eventPlayer, 9999, 9999)
    eventPlayer.playerCarried = []
    eventPlayer.startScalingSize(scale/100, false)
    eventPlayer.startModifyingVoicelinePitch(((scale-100)/(-180))+1,false)
    eventPlayer.setMoveSpeed(moveSpeed)
    eventPlayer.setJumpVerticalSpeed(jumpSpeed)

#Create Workshop settings for Ana settings.
rule "Ana Initial Setup":
    sleepDuration = createWorkshopSetting(float<1:10>, "General", "Sleep Duration in Seconds (Default: 5)", 5)
    ultPercentage = createWorkshopSetting(int<0:100>, "General", "Ultimate Percentage Added per elimination (Default: 20%)", 20)
    pickupRadius = createWorkshopSetting(float<0.5:20>, "General", "Pickup Radius in Meters (Default: 1.5)", 1.5)
    canAutoEscape = createWorkshopSetting(bool, "General", "Auto escape from players (Default: disabled)", false)
    throwStrength = createWorkshopSetting(int<25:175>, "General", "Throw Strength Percentage (Default: 100%)", 100)
    scale = createWorkshopSetting(float<10:500>, "General", "Scale Percentage of Ana (Default: 100%)", 100)
    moveSpeed = createWorkshopSetting(float<10:500>, "General", "Move Speed Percentage of Ana (Default: 100%)", 100)
    sleepCD = createWorkshopSetting(float<0:20>, "General", "Sleep Dart Cooldown in Seconds (Default: 2)", 2)
    jumpSpeed = createWorkshopSetting(float<0:500>, "General", "Jump Speed Percentage (Default: 100%)", 100)

#Picks up a sleeping player. Player will be appended to the playerCarried array, and attached.
rule "Pickup player":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == false
    @Condition (entityExists((sorted([player for player in getAllPlayers() if player.hasStatusEffect(Status.ASLEEP) == true and player != eventPlayer and distance(eventPlayer, player) <= pickupRadius and entityExists(player.thrower) == false and player.isOnGround() == true], lambda i: distance(eventPlayer, i)))[0])) == true
    
    eventPlayer.playerCarried.append((sorted([player for player in getAllPlayers() if player.hasStatusEffect(Status.ASLEEP) == true and player != eventPlayer and eventPlayer.thrower == null], lambda i: distance(i, eventPlayer)))[0])
    eventPlayer.playerCarried.last().thrower = eventPlayer
    eventPlayer.playerCarried.last().attachTo(eventPlayer, vect(0, (2 + 1 * eventPlayer.playerCarried.index(eventPlayer.playerCarried.last()))*(scale/100), 0))
    playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 200)
    smallMessage(eventPlayer, "{0} {1}!".format(stringPick, eventPlayer.playerCarried.last()))
    wait(0.25)

#If event player is thrown and lands on ground, after 0.5 seconds the attacker value (thrower) is set to null.
rule "Reset Thrower":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.isOnGround() == true
    @Condition all([player != eventPlayer for player in eventPlayer.thrower.playerCarried]) == true
    
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    eventPlayer.thrower = null

#If event player is slept, drop all players that were attached and set them up.
rule "Sleep Setup With Player":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == true
    @Condition len(eventPlayer.playerCarried) > 0

    if len(eventPlayer.playerCarried) > 0:
        eventPlayer.playerCarried[0].detach()
        eventPlayer.playerCarried[0].thrower = null
        del eventPlayer.playerCarried[0]

#When slept, sleep dart cooldown is reset to 0 to allow for a revenge play once woken up.
rule "Sleep Setup":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == true
    
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)

#If event player is carrying multiple players, throw them with secondary fire. Clean playerCarried array.
rule "Throw player":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == false
    @Condition len(eventPlayer.playerCarried) > 0

    while eventPlayer.playerCarried != []:
        eventPlayer.playerCarried[0].detach()
        eventPlayer.playerCarried[0].applyImpulse(vect(eventPlayer.getFacingDirection().x, -0.1, eventPlayer.getFacingDirection().z), throwStrength*0.4, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        del eventPlayer.playerCarried[0]
        wait(0.05)

#If being carried and is awake, event player can escape, and will detach above players also being carried by their thrower.
rule "Escape from grasp":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition eventPlayer.thrower != null
    @Condition any([player == eventPlayer for player in eventPlayer.thrower.playerCarried]) == true
    
    eventPlayer.detach()
    eventPlayer.i = eventPlayer.thrower.playerCarried.index(eventPlayer)
    smallMessage(eventPlayer.thrower, "{0}{1}".format(eventPlayer, stringGraspEscape))
    del eventPlayer.thrower.playerCarried[eventPlayer.i]
    while len(eventPlayer.thrower.playerCarried) >= eventPlayer.i + 1:
        #Sometimes the array has a player that does not exist. This check will prevent a weird small message from being sent.
        if eventPlayer.thrower.playerCarried[eventPlayer.i] != null:
            smallMessage(eventPlayer.thrower, "{0}{1}".format(eventPlayer.thrower.playerCarried[eventPlayer.i], stringGraspEscape))
        eventPlayer.thrower.playerCarried[eventPlayer.i].detach()
        eventPlayer.thrower.playerCarried[eventPlayer.i].thrower = null
        del eventPlayer.thrower.playerCarried[eventPlayer.i]
        wait(0.05)
    eventPlayer.thrower = null

#When a player is below a certain part of the map, the player is automatically killed so a manual kill credit is properly applied. Also resets variables of event player for spawn.
rule "Too Far Gone kill credit":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.getPosition().y < -5
    
    kill(eventPlayer, eventPlayer.thrower)
    eventPlayer.thrower.setUltCharge(eventPlayer.thrower.getUltCharge() + ultPercentage)
    wait(0.25)
    eventPlayer.playerCarried = []
    eventPlayer.thrower = null

#Set the move speed to the proper value when ultimate is activated.
rule "Using Ultimate":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.isUsingUltimate() == true
    
    eventPlayer.setMoveSpeed(moveSpeed*1.4)

#When the ultimate no longer is active, revert settings.
rule "Is not using Ultimate":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.isUsingUltimate() == false
    
    eventPlayer.setMoveSpeed(moveSpeed)

#If the player is slept and presses the ultimate button, the player awakens and uses ult. If the player dies or is slept again during the sequence, the ult charge will still be removed.
rule "Ult Cancels Sleep":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.getUltCharge() == 100
    
    eventPlayer.clearStatusEffect(Status.ASLEEP)
    wait(0.8)
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    wait(1.2)
    if eventPlayer.getUltCharge() > 0:
        eventPlayer.setUltCharge(0)

#If the player is slept for too long, the player is respawned.
rule "Slept for too long":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == true
    @Condition eventPlayer.thrower == null
    
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.respawn()

#autoEscape Subroutine: press jump button.
def autoEscape():
    @Name "Auto Escape Subroutine"
    
    eventPlayer.forceButtonPress(Button.JUMP)

#If auto escape is turned on, the jump button is automatically pressed when the player is eligible for escape.
rule "Auto Escape":
    @Event eachPlayer
    @Hero all
    @Condition canAutoEscape == true
    @Condition entityExists(eventPlayer.thrower) == true
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == false
    
    autoEscape()

#Custom sleep status is applied when the player is slept by the sleep dart.
rule "Manual Sleep":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == true
    
    eventPlayer.setStatusEffect(null, Status.ASLEEP, sleepDuration)

#If player does not exist, their entry is cleared from the playerCarried array.
rule "Entity Check":
    @Event eachPlayer
    @Hero all
    @Condition len(eventPlayer.playerCarried) > 0
    @Condition any([entityExists(player) == false for player in eventPlayer.playerCarried]) == true
    
    for eventPlayer.j in range(len(eventPlayer.playerCarried)):
        if entityExists(eventPlayer.playerCarried[eventPlayer.j]) == false:
            del eventPlayer.playerCarried[eventPlayer.j]

#Sleep dart has a manually set cooldown depending on the setting chosen.
rule "Sleep Dart Manual CD":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0

    eventPlayer.setAbilityCooldown(Button.ABILITY_1, sleepCD)