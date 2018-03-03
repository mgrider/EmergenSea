pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- add globals here
constants = {}
constants.speed = 3
constants.maxDistanceFromBody = 24

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
-- todo: add array of previous arms later
arm = {}
arm.x = -10
arm.y = 0
arm.sprite = 3

function moveCheck()
  if btn(0) then
    arm.x -= constants.speed
    arm.x = (abs(arm.x) <= constants.maxDistanceFromBody) and arm.x or -constants.maxDistanceFromBody
  end
  if btn(1) then
    arm.x += constants.speed
    arm.x = (arm.x <= constants.maxDistanceFromBody) and arm.x or constants.maxDistanceFromBody
  end
  if btn(2) then
    arm.y -= constants.speed
    arm.y = (abs(arm.y) <= constants.maxDistanceFromBody) and arm.y or -constants.maxDistanceFromBody
  end
  if btn(3) then
    arm.y += constants.speed
    arm.y = (arm.y <= constants.maxDistanceFromBody) and arm.y or constants.maxDistanceFromBody
  end
end

function checkpointInBox(x,y,a)
  if (y <= a.y + a.h and y >= a.y) then
    if (x <= a.x + a.w and x >= a.x) then
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
end

function _draw()
    cls()
    if WIN then print("WIN") end
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
