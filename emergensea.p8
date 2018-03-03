pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- add globals here
constants = {}
constants.armSpeed = 3
constants.bodySpeed = 2
constants.maxDistanceFromBody = 24

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
function init_arm()
  -- todo: add array of previous arms
  arm = {}
  arm.x = -10
  arm.y = 0
  arm.sprite = 3
  -- will be a list with key_events
  arm.key_events = {}
  add(arm.key_events, {time=0,keys=0})
  arm.event_counter = 0
end

level_time = 0
current_key = {}
print_msg = ""

function _init()
  init_arm()
end

function recordKeyEvents()
  last_key = arm.key_events[#arm.key_events].keys
  if current_key != last_key then
    add(arm.key_events, {keys=current_key, time=level_time})
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
end

function moveArmY(thisArm, y)
  thisArm.y += y
  if (thisArm.y > constants.maxDistanceFromBody) then
    thisArm.y = constants.maxDistanceFromBody
  elseif (thisArm.y < -constants.maxDistanceFromBody) then
    thisArm.y = -constants.maxDistanceFromBody
  end
end

function moveBody()
  local totalX = arm.x
  local totalY = arm.y
  if (totalX > 0) then
    body.x += constants.bodySpeed
    moveArmX(arm, -constants.bodySpeed)
    if #body.oldArms > 0 then
      for oldArm in all (body.oldArms) do
        moveArmX(oldArm, -constants.bodySpeed)
      end
  end
  elseif (totalX < 0) then
    body.x -= constants.bodySpeed
    moveArmX(arm, constants.bodySpeed)
    if #body.oldArms > 0 then
      for oldArm in all (body.oldArms) do
        moveArmX(oldArm, constants.bodySpeed)
      end
    end
  end
  if (totalY > 0) then
    body.y += constants.bodySpeed
    moveArmY(arm, -constants.bodySpeed)
    if #body.oldArms > 0 then
      for oldArm in all (body.oldArms) do
        moveArmY(oldArm, -constants.bodySpeed)
      end
    end
  elseif (totalY < 0) then
    body.y -= constants.bodySpeed
    moveArmY(arm, constants.bodySpeed)
    if #body.oldArms > 0 then
      for oldArm in all (body.oldArms) do
        moveArmY(oldArm, constants.bodySpeed)
      end
    end
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
  if checkCollide(body,goal) then Win() end
end

function Win()
 add(body.oldArms,arm)
 init_arm()
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

function _update()
  moveCheck()
  goalCheck()
  animateBody()
  level_time += 1
end

function _draw()
    cls()
    print(print_msg)
    spr(goal.sprite, goal.x, goal.y)
    spr(body.sprite, body.x, body.y)
    spr(arm.sprite, body.x+arm.x, body.y+arm.y)
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
