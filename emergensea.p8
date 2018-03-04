pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- add globals here
constants = {}
constants.armSpeed = 4
constants.bodySpeed = 3
constants.maxDistanceFromBody = 24
constants.minDistanceFromBody = 6
constants.windowSize = 128
constants.maxLevel = 8

state = {}
state.levelTime = 0
state.currentLevel = 1
state.currentKey = 0
state.lastKey = 0
state.betweenLevelCounter = 0
state.holdoffInputs = false
state.printMsg = ""
state.statePlaying = "PLAYING"
state.stateBetweenLevels = "BETWEEN_LEVELS"
state.stateGameOver = "GAME_OVER"
state.gameOverTime = 0.0
state.currentState = state.statePlaying

goal = {}
goal.x = 20
goal.y = 50
goal.w = 8
goal.h = 8
goal.sprite = 1

body = {}
body.oldArms = {}
body.x = 60
body.y = 50
body.w = 8
body.h = 8
body.sprite = 1
-- arm is current arm
function initArm()
  -- todo: add array of previous arms
  arm = {}
  arm.x = 10
  arm.y = 20
  arm.w = 8
  arm.h = 8
  arm.sprite = 3
  -- will be a list with keyEvents
  arm.keyEvents = {}
end

function addEvent()
  if #arm.keyEvents == 0 then
    arm.startTime = state.levelTime
  end
  add(arm.keyEvents, {time=state.levelTime-arm.startTime,keys=state.currentKey})
end

function sortQueue(q)
  for i = 1, #q do
    local j = i
    while j > 1 and q[j-1].value > q[j].value do
      q[j], q[j-1] = q[j-1], q[j]
      j = j - 1
    end
  end
end

local monster = {
	BIG_SPLASH = {32, 34, 36, 34},
	SMALL_SPLASH = {54, 55},
	LEFT = {18, 19, 20, 19},
	RIGHT = {2, 3, 4, 3},
	time = 0,
	submerge = 0,
  queue = {},
}

function monster:push(value, func)
  add(self.queue, {value = value, func = func})
end

function monster:draw_head(x, y)
  self:push(y, function()
    clip()
    pal()

    local frame = self.BIG_SPLASH[flr(5*self.time)%4 + 1]
    spr(frame, x - 8, y - 8, 2, 2)

    clip(0, 0, 128, y + 3)
    spr(0, x - 8, y - 13 + 16*self.submerge, 2, 2)
  end)
end

function monster:set_pal(active)
	pal()
	if active and self.time % 0.5 < 0.2 then
		pal(14, 8)
		pal(2 , 8)
	end
end

function monster:draw_tentacle(x, y, active)
  if x <= body.x then
    monster:draw_left_tentacle(x, y, active)
  else
    monster:draw_right_tentacle(x, y, active)
  end
end

function monster:draw_left_tentacle(x, y, active)
  self:push(y, function()
    clip()
    self:set_pal(active)

    local frame = self.SMALL_SPLASH[flr(2.5*self.time)%2 + 1]
    spr(frame, x + 1, y - 4)

    clip(0, 0, 128, y)
    local frame = self.LEFT[flr(6*self.time)%4 + 1]
    spr(frame, x, y - 8 + 8*self.submerge)
  end)
end

function monster:draw_right_tentacle(x, y, active)
  self:push(y, function()
    clip()
    self:set_pal(active)

    local frame = self.SMALL_SPLASH[flr(2.5*self.time)%2 + 1]
    spr(frame, x - 1, y - 4)

    clip(0, 0, 128, y)
    local frame = self.RIGHT[flr(6*self.time)%4 + 1]
    spr(frame, x, y - 8 + 8*self.submerge)
  end)
end

function monster:draw_target(x, y)
  self:push(y, function()
    clip()
    pal()

    local frame = self.BIG_SPLASH[flr(5*self.time)%4 + 1]
    spr(frame, x - 8, y - 8, 2, 2)

    spr(40, x - 8, y - 11, 2, 2)
  end)
end

function monster:flush()
  sortQueue(self.queue)
  for e in all(self.queue) do e.func() end

	self.time += 1/32
  self.queue = {}
end

function loadLevel(lvl)
  if (lvl ==  1) then
    body.x = 106
    body.y = 64
    goal.x = 20
    goal.y = 64
  elseif (lvl == 2) then
    body.x = 20
    body.y = 64
    goal.x = 108
    goal.y = 64
  elseif (lvl == 3) then
    body.x = 106
    body.y = 64
    goal.x = 20
    goal.y = 20
  elseif (lvl == 4) then
    body.x = 28
    body.y = 64
    goal.x = 100
    goal.y = 100
  elseif (lvl == 5) then
    body.x = 96
    body.y = 64
    goal.x = 20
    goal.y = 100
  elseif (lvl == 6) then
    body.x = 96
    body.y = 64
    goal.x = 90
    goal.y = 28
  elseif (lvl == 7) then
    body.x = 28
    body.y = 96
    goal.x = 28
    goal.y = 64
  elseif (lvl == 8) then
    body.x = 96
    body.y = 96
    goal.x = 28
    goal.y = 28
  end
end

function recordKeyEvents()
  if state.currentKey != state.lastKey then
    state.holdoffInputs=false
    state.lastKey = state.currentKey
    addEvent()
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
    keys = getButtonStateAtTimeIndex(oldArm.keyEvents, state.levelTime % oldArm.loopDuration)
    if state.levelTime % oldArm.loopDuration == 0 then
      oldArm.x = 10
      oldArm.y = 20
    else
      moveArm(oldArm, keys)
    end
  end
end

function interpretBtn(keys, n)
  keysShifted = shr(keys, n)
  keysMasked = band(keysShifted, 0x01)
  return keysMasked == 0x1
end

function moveCheck()
  state.currentKey = btn()
  if interpretBtn(state.currentKey, 0) then
    moveArmX(arm, -constants.armSpeed)
  end
  if interpretBtn(state.currentKey, 1) then
    moveArmX(arm, constants.armSpeed)
  end
  if interpretBtn(state.currentKey, 2) then
    moveArmY(arm, -constants.armSpeed)
  end
  if interpretBtn(state.currentKey, 3) then
    moveArmY(arm, constants.armSpeed)
  end
  if interpretBtn(state.currentKey, 5) then
    moveBody()
  end
  recordKeyEvents()
end

function moveArmX(thisArm, x)
  thisArm.x += x
  if (thisArm.x > constants.maxDistanceFromBody) then
    thisArm.x = constants.maxDistanceFromBody
  elseif (thisArm.x < -constants.maxDistanceFromBody - thisArm.w) then
    thisArm.x = -constants.maxDistanceFromBody - thisArm.w
  end
  if ((thisArm.x + body.x) > constants.windowSize - thisArm.w) then
    thisArm.x = constants.windowSize - body.x - thisArm.w
  elseif ((thisArm.x + body.x + thisArm.w) < thisArm.w) then
    thisArm.x = -(constants.minDistanceFromBody + body.x - thisArm.w)
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
  elseif ((thisArm.y + body.y + thisArm.h) < thisArm.h) then
    thisArm.y = -(constants.minDistanceFromBody + body.y - thisArm.h)
  end
end

function moveBody()
  local totalX = arm.x
  local totalY = arm.y
  for oldArm in all (body.oldArms) do
    totalX += oldArm.x
    totalY += oldArm.y
  end
  -- actually move the body (& arms)
  if (totalX > constants.minDistanceFromBody) then
    body.x += constants.bodySpeed
    moveArmX(arm, -constants.bodySpeed)
    for oldArm in all (body.oldArms) do
      moveArmX(oldArm, -constants.bodySpeed)
    end
  elseif (totalX < -(constants.minDistanceFromBody + arm.w)) then
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
  elseif (totalY < -(constants.minDistanceFromBody)) then
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
  state.currentLevel += 1
  if (state.currentLevel > constants.maxLevel) then
    showGameOver()
  else
    state.betweenLevelCounter = 0
    arm.loopDuration = state.levelTime - arm.startTime
    add(body.oldArms,arm)
    initArm()
    state.holdoffInputs = true
    setCurrentState(state.stateBetweenLevels)
    animateHead(function()
      loadLevel(state.currentLevel)
    end)
  end
end

function showGameOver()
  setCurrentState(state.stateGameOver)
  state.gameOverTime = time()
end

function animateBody()
  body.sprite += 1
  if body.sprite > 2 then
    body.sprite = 1
  end
end

function setCurrentState(newState)
  state.currentState = newState
end

function animateHead(betweenCallback)
  for i=0, 1, 0.1 do
    monster.submerge = i
    _draw()
    flip()
  end
  betweenCallback()
  for i=1, 0, -0.1 do
    monster.submerge = i
    _draw()
    flip()
  end
  setCurrentState(state.statePlaying)
end

function _init()
  initArm()
  loadLevel(1)
end

function _update()
  if state.currentState == state.statePlaying then
    moveCheck()
    goalCheck()
    animateBody()
    replayKeyEvents()
    state.levelTime += 1
  elseif state.currentState == state.stateBetweenLevels then
    -- anything?
  elseif state.currentState == state.stateGameOver then
    -- todo
  end
end

function _draw()
    cls(12)
  if state.currentState == state.stateGameOver then
    cls()
    print ("GAME OVER\n\nTIME: "..tostr(state.gameOverTime), 50, 50)
  else
    -- print(state.printMsg)

    monster:draw_head(body.x, body.y)
    for oldArm in all(body.oldArms) do
      monster:draw_tentacle(body.x+oldArm.x, body.y+oldArm.y, false)
      -- spr(oldArm.sprite, body.x+oldArm.x, body.y+oldArm.y)
    end
    monster:draw_tentacle(body.x+arm.x, body.y+arm.y, true)

    monster:draw_target(goal.x, goal.y)

    -- Reset clipping and palette
    clip()
    pal()

    monster:flush()
  end
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
00000000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005505500000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007777770000000000000000000000000000000044000000000000000000000000000000000000000000000000000
000000000000000000000777777000000007711111177000000000000000000000006670000ff000000000000000000000000000000000000000000000000000
00000777777000000007711111177000007110000001170000000000000000000000667000f88f00000000000000000000000000000000000000000000000000
00077111111770000071100000011700071000000000017000000000000000000000667000011000000000000000000000000000000000000000000000000000
00711000000117000710000000000170710000000000001700000000000000004444444444444444000000000000000000000000000000000000000000000000
00710000000017000710000000000170710000000000001700000000000000004499999999999944000000000000000000000000000000000000000000000000
00711000000117000710000000000170710000000000001700077000007777000444444444444440000000000000000000000000000000000000000000000000
00077111111770000071100000011700071000000000017000711700071111700449999999999440000000000000000000000000000000000000000000000000
00000777777000000007711111177000007110000001170007100170710000170044444444444400000000000000000000000000000000000000000000000000
00000000000000000000077777700000000771111117700000711700071111700004444444444000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007777770000000077000007777000000000000000000000000000000000000000000000000000000000000000000
