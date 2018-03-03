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

goal = {}
goal.x = 10
goal.y = 50
goal.w = 8
goal.h = 8
goal.sprite = 1

body = {}
body.x = 50
body.y = 50
body.w = 8
body.h = 8
body.sprite = 1
-- arm is current arm
-- todo: add array of previous arms
arm = {}
arm.x = -10
arm.y = 0
arm.sprite = 3
-- will be a list with key_events
arm.key_events = {}
add(arm.key_events, {time=0,keys=0})
arm.event_counter = 0

level_time = 0
current_key = {}
print_msg = ""

function recordKeyEvents()
  last_key = arm.key_events[#arm.key_events].keys
  if current_key != last_key then
    add(arm.key_events, {keys=current_key, time=level_time})
    print_msg = "K"..current_key..", T"..level_time..", "..last_key
  end
end

function moveCheck()
  current_key = btn()
  if btn(0) then
    moveArmX(arm, -constants.armSpeed)
  end
  if btn(1) then
    moveArmX(arm, constants.armSpeed)
  end
  if btn(2) then
    moveArmY(arm, -constants.armSpeed)
  end
  if btn(3) then
    moveArmY(arm, constants.armSpeed)
  end
  if btn(5) then
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
  elseif (totalX < -constants.minDistanceFromBody) then
    body.x -= constants.bodySpeed
    moveArmX(arm, constants.bodySpeed)
  end
  if (totalY > constants.minDistanceFromBody) then
    body.y += constants.bodySpeed
    moveArmY(arm, -constants.bodySpeed)
  elseif (totalY < -constants.minDistanceFromBody) then
    body.y -= constants.bodySpeed
    moveArmY(arm, constants.bodySpeed)
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
  -- todo
  if checkCollide(body,goal) then WIN=true end
end

function animateBody()
  body.sprite += 1
  if body.sprite > 2 then
    body.sprite = 1
  end
end

function _update()
  moveCheck()
  goalCheck()
  animateBody()
  level_time += 1
end

function _draw()
    cls(12)
    print(print_msg)
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
