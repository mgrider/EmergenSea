pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- add globals here
constants = {}
constants.armSpeed = 3
constants.bodySpeed = 2
constants.maxDistanceFromBody = 24
constants.minDistanceFromBody = 6
constants.windowSize = 128
constants.maxLevel = 5

goal = {}
goal.x = 10
goal.y = 50
goal.w = 8
goal.h = 8
goal.sprite = 1

body = {}
body.oldArms = {}
body.x = 50
body.y = 50
body.w = 8
body.h = 8
body.sprite = 1
-- arm is current arm
function initArm()
  -- todo: add array of previous arms
  arm = {}
  arm.x = -10
  arm.y = 0
  arm.sprite = 3
  -- will be a list with keyEvents
  arm.keyEvents = {}
  add(arm.keyEvents, {time=0,keys=0})
  arm.eventCounter = 0
end

levelTime = 0
currentLevel = 1
currentKey = {}
printMsg = ""

function loadLevel(lvl)
  if (lvl ==  1) then
    body.x = 96
    body.y = 64
    goal.x = 10
    goal.y = 64
  elseif (lvl == 2) then
    body.x = 96
    body.y = 64
    goal.x = 10
    goal.y = 10
  elseif (lvl == 3) then
    body.x = 96
    body.y = 64
    goal.x = 110
    goal.y = 110
  elseif (lvl == 4) then
    body.x = 96
    body.y = 64
    goal.x = 10
    goal.y = 110
  elseif (lvl == 5) then
    body.x = 96
    body.y = 64
    goal.x = 110
    goal.y = 10
  end
end

function _init()
  initArm()
end

function recordKeyEvents()
  lastKey = arm.keyEvents[#arm.keyEvents].keys
  if currentKey != lastKey then
    add(arm.keyEvents, {keys=currentKey, time=levelTime})
  end
end

function moveArm(arm, buttons)
  if interpret_btn(buttons, 0) then
    moveArmX(arm, -constants.armSpeed)
  end
  if interpret_btn(buttons, 1) then
    moveArmX(arm, constants.armSpeed)
  end
  if interpret_btn(buttons, 2) then
    moveArmY(arm, -constants.armSpeed)
  end
  if interpret_btn(buttons, 3) then
    moveArmY(arm, constants.armSpeed)
  end
end

function getButtonStateAtTimeIndex(events, time_index)
  event_of_interest = {}
  for event in events do
    if time_index > events.time then
      event_of_interest = event
    end
  end
  return event_of_interest.keys
end

function replayKeyEvents()
  for arm in body.old_arms do
    keys = getButtonStateAtTimeIndex(level_time)
    moveArm(arm, event_of_interest.keys)
  end
end


function interpret_btn(keys, n)
  keys_shifted = shr(keys, n)
  keys_masked = band(keys_shifted, 0x01)
  return keys_masked == 0x1
end


function moveCheck()
  current_key = btn()
  if interpret_btn(current_key, 0) then
    moveArmX(arm, -constants.armSpeed)
  end
  if interpret_btn(current_key, 1) then
    moveArmX(arm, constants.armSpeed)
  end
  if interpret_btn(current_key, 2) then
    moveArmY(arm, -constants.armSpeed)
  end
  if interpret_btn(current_key, 3) then
    moveArmY(arm, constants.armSpeed)
  end
  if interpret_btn(current_key, 5) then
    moveBody()
  end
  recordKeyEvents()
end

function moveArmX(thisArm, x)
  thisArm.x += x
  if (thisArm.x > constants.maxDistanceFromBody) then
    thisArm.x = constants.maxDistanceFromBody
  elseif (thisArm.x < -constants.maxDistanceFromBody) then
    thisArm.x = -constants.maxDistanceFromBody
  end
  if ((thisArm.x + body.x) > constants.windowSize) then
    thisArm.x = constants.windowSize - body.x
  elseif ((thisArm.x + body.x) < 0) then
    thisArm.x = -constants.minDistanceFromBody
  end
end

function moveArmY(thisArm, y)
  thisArm.y += y
  if (thisArm.y > constants.maxDistanceFromBody) then
    thisArm.y = constants.maxDistanceFromBody
  elseif (thisArm.y < -constants.maxDistanceFromBody) then
    thisArm.y = -constants.maxDistanceFromBody
  end
  if ((thisArm.y + body.y) > constants.windowSize) then
    thisArm.y = constants.windowSize - body.y
  elseif ((thisArm.y + body.y) < 0) then
    thisArm.y = -constants.minDistanceFromBody
  end
end

function moveBody()
  local totalX = arm.x
  local totalY = arm.y
  if (totalX > constants.minDistanceFromBody) then
    body.x += constants.bodySpeed
    moveArmX(arm, -constants.bodySpeed)
    if #body.oldArms > 0 then
      for oldArm in all (body.oldArms) do
        moveArmX(oldArm, -constants.bodySpeed)
      end
    end
  elseif (totalX < -constants.minDistanceFromBody) then
    body.x -= constants.bodySpeed
    moveArmX(arm, constants.bodySpeed)
    if #body.oldArms > 0 then
      for oldArm in all (body.oldArms) do
        moveArmX(oldArm, constants.bodySpeed)
      end
    end
  end
  if (totalY > constants.minDistanceFromBody) then
    body.y += constants.bodySpeed
    moveArmY(arm, -constants.bodySpeed)
    if #body.oldArms > 0 then
      for oldArm in all (body.oldArms) do
        moveArmY(oldArm, -constants.bodySpeed)
      end
    end
  elseif (totalY < -constants.minDistanceFromBody) then
    body.y -= constants.bodySpeed
    moveArmY(arm, constants.bodySpeed)
    if #body.oldArms > 0 then
      for oldArm in all (body.oldArms) do
        moveArmY(oldArm, constants.bodySpeed)
      end
    end
  end
  -- check for OOB
  if (body.x > (constants.windowSize - constants.minDistanceFromBody)) then
    body.x = constants.windowSize - constants.minDistanceFromBody
  elseif (body.x < constants.minDistanceFromBody) then
    body.x = constants.minDistanceFromBody
  end
  if (body.y > (constants.windowSize - constants.minDistanceFromBody)) then
    body.y = constants.windowSize - constants.minDistanceFromBody
  elseif (body.y < constants.minDistanceFromBody) then
    body.y = constants.minDistanceFromBody
  end
end

function checkpointInBox(x,y,a)
  if (y < a.y + a.h and y >= a.y) then
    if (x < a.x + a.w and x >= a.x) then
      return true
    end
  end
  return false
end

function checkCollide(a,b)
  if checkpointInBox(a.x,a.y,b) then return true end
  if checkpointInBox(a.x+a.w,a.y,b) then return true end
  if checkpointInBox(a.x,a.y+a.h,b) then return true end
  if checkpointInBox(a.x+a.w,a.y+a.h,b) then return true end
  return false
end

function goalCheck()
  if checkCollide(body,goal) then
    winLevel()
  end
end

function winLevel()
  currentLevel += 1
  if (currentLevel > constants.maxLevel) then
    showGameOver()
  else
    loadLevel(currentLevel)
  end
end

function showGameOver()
  -- todo
  if checkCollide(body,goal) then Win() end
end

function Win()
 add(body.oldArms,arm)
 initArm()
 level_time = 0
 body.x = 50
 body.y = 50
end

function animateBody()
  body.sprite += 1
  if body.sprite > 2 then
    body.sprite = 1
  end
end

function _init()
  loadLevel(1)
end

function _update()
  moveCheck()
  goalCheck()
  animateBody()
  levelTime += 1
end

function _draw()
    cls(12)
    print(printMsg)
    circfill(body.x, body.y, 8, 14)
    circfill(goal.x, goal.y, 4, 4)
    circfill(body.x+arm.x, body.y+arm.y, 4, 14)
    -- spr(goal.sprite, goal.x, goal.y)
    -- spr(body.sprite, body.x, body.y)
    -- spr(arm.sprite, body.x+arm.x, body.y+arm.y)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000033330000333b0000333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000330030000b0033000300300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700030707300b07073000030330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003707030037070b00003b030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
