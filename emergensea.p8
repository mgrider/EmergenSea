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

local monster = {
	BIG_SPLASH = {32, 34, 36, 34},
	SMALL_SPLASH = {54, 55},
	LEFT = {18, 19, 20, 19},
	RIGHT = {2, 3, 4, 3},
	time = 0,
	submerge = 0
}

function monster:tick()
	self.time += 1/32
end

function monster:draw_head(x, y)
	clip()
	pal()
	
	local frame = self.BIG_SPLASH[flr(5*self.time)%4 + 1]
	spr(frame, x - 8, y - 8, 2, 2)
	
	clip(0, 0, 128, y + 3)
	spr(0, x - 8, y - 13 + 16*self.submerge, 2, 2)
end

function monster:set_pal(active)
	pal()
	if active and self.time % 0.5 < 0.2 then
		pal(14, 8)
		pal(2 , 8)
	end
end

function monster:draw_left_tentacle(x, y, active)
	clip()
	self:set_pal(active)
	
	local frame = self.SMALL_SPLASH[flr(2.5*self.time)%2 + 1]
	spr(frame, x + 1, y - 4)
	
	clip(0, 0, 128, y)
	local frame = self.LEFT[flr(6*self.time)%4 + 1]
	spr(frame, x, y - 8 + 8*self.submerge)
end

function monster:draw_right_tentacle(x, y, active)
	clip()
	self:set_pal(active)
	
	local frame = self.SMALL_SPLASH[flr(2.5*self.time)%2 + 1]
	spr(frame, x - 1, y - 4)
	
	clip(0, 0, 128, y)
	local frame = self.RIGHT[flr(6*self.time)%4 + 1]
	spr(frame, x, y - 8 + 8*self.submerge)
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

function recordKeyEvents()
  lastKey = arm.keyEvents[#arm.keyEvents].keys
  if currentKey != lastKey then
    add(arm.keyEvents, {keys=currentKey, time=levelTime})
  end
end

function moveArm(arm, buttons)
  if interpretBtn(buttons, 0) then
    moveArmX(arm, -constants.armSpeed)
  end
  if interpretBtn(buttons, 1) then
    moveArmX(arm, constants.armSpeed)
  end
  if interpretBtn(buttons, 2) then
    moveArmY(arm, -constants.armSpeed)
  end
  if interpretBtn(buttons, 3) then
    moveArmY(arm, constants.armSpeed)
  end
end

function getButtonStateAtTimeIndex(events, timeIndex)
  eventOfInterest = {}
  for event in all(events) do
    if timeIndex > event.time then
      eventOfInterest = event
    end
  end
  return eventOfInterest.keys
end

function replayKeyEvents()
  for oldArm in all(body.oldArms) do
    keys = getButtonStateAtTimeIndex(oldArm.keyEvents, levelTime)
    moveArm(oldArm, keys)
  end
end


function interpretBtn(keys, n)
  keysShifted = shr(keys, n)
  keysMasked = band(keysShifted, 0x01)
  return keysMasked == 0x1
end


function moveCheck()
  currentKey = btn()
  if interpretBtn(currentKey, 0) then
    moveArmX(arm, -constants.armSpeed)
  end
  if interpretBtn(currentKey, 1) then
    moveArmX(arm, constants.armSpeed)
  end
  if interpretBtn(currentKey, 2) then
    moveArmY(arm, -constants.armSpeed)
  end
  if interpretBtn(currentKey, 3) then
    moveArmY(arm, constants.armSpeed)
  end
  if interpretBtn(currentKey, 5) then
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
  for oldArm in all (body.oldArms) do
    totalX += oldArm.x
    totalY += oldArm.y
  end

  if (totalX > constants.minDistanceFromBody) then
    body.x += constants.bodySpeed
    moveArmX(arm, -constants.bodySpeed)
    for oldArm in all (body.oldArms) do
      moveArmX(oldArm, -constants.bodySpeed)
    end
  elseif (totalX < -constants.minDistanceFromBody) then
    body.x -= constants.bodySpeed
    moveArmX(arm, constants.bodySpeed)
    for oldArm in all (body.oldArms) do
      moveArmX(oldArm, constants.bodySpeed)
    end
  end
  if (totalY > constants.minDistanceFromBody) then
    body.y += constants.bodySpeed
    moveArmY(arm, -constants.bodySpeed)
    for oldArm in all (body.oldArms) do
      moveArmY(oldArm, -constants.bodySpeed)
    end
  elseif (totalY < -constants.minDistanceFromBody) then
    body.y -= constants.bodySpeed
    moveArmY(arm, constants.bodySpeed)
    for oldArm in all (body.oldArms) do
      moveArmY(oldArm, constants.bodySpeed)
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
  add(body.oldArms,arm)
  initArm()
  levelTime = 0
end

function showGameOver()
  -- todo
end

function animateBody()
  body.sprite += 1
  if body.sprite > 2 then
    body.sprite = 1
  end
end

function _init()
  initArm()
  loadLevel(1)
end

function _update()
  moveCheck()
  goalCheck()
  animateBody()
  replayKeyEvents()
  levelTime += 1
end

function _draw()
    cls(12)
    print(printMsg)
    
    -- circfill(body.x, body.y, 8, 14)
    -- circfill(body.x+arm.x, body.y+arm.y, 4, 14)
    
    circfill(goal.x, goal.y, 4, 4)
    monster:draw_head(body.x, body.y)
    for oldArm in all(body.oldArms) do
      monster:draw_left_tentacle(body.x+oldArm.x, body.y+oldArm.y, false)
      -- spr(oldArm.sprite, body.x+oldArm.x, body.y+oldArm.y)
    end
    monster:draw_right_tentacle(body.x+arm.x, body.y+arm.y, true)
    
    -- Reset clipping and palette
    clip()
    pal()
    
    monster:tick()
end


__gfx__
00005555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005555555500000000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000555555550000000ee200000eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005577777777550000ee200000ee220000eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000555555555500000e2000000e2000000e22e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000eeeeeeeee00000e2000000e2000000e202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000eee77ee77ee000ee200000ee200000ee200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000eee71ee17ee000ee200000ee200000ee200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eee171711eeee00eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ee81111111eee0002ee0000eeee00000eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ee88171711eee00002ee000222ee000e22ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eee88888eeee000002ee000002ee000e02ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002ee8ee8eeee20000002ee000002ee002002ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002eeeeeee2200000002ee000002ee000002ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000022222220000000002ee000002ee000002ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000077777700000000771111117700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777777000000007711111177000007110000001170000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077111111770000071100000011700071000000000017000000000000000000000000000000000000000000000000000000000000000000000000000000000
00711000000117000710000000000170710000000000001700000000000000000000000000000000000000000000000000000000000000000000000000000000
00710000000017000710000000000170710000000000001700000000000000000000000000000000000000000000000000000000000000000000000000000000
00711000000117000710000000000170710000000000001700077000007777000000000000000000000000000000000000000000000000000000000000000000
00077111111770000071100000011700071000000000017000711700071111700000000000000000000000000000000000000000000000000000000000000000
00000777777000000007711111177000007110000001170007100170710000170000000000000000000000000000000000000000000000000000000000000000
00000000000000000000077777700000000771111117700000711700071111700000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007777770000000077000007777000000000000000000000000000000000000000000000000000000000000000000
