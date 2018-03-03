pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- add globals here
constants = {}
constants.armSpeed = 3
constants.bodySpeed = 2
constants.maxDistanceFromBody = 24

body = {}
body.x = 50
body.y = 50
body.sprite = 1
-- arm is current arm
-- todo: add array of previous arms
arm = {}
arm.x = -10
arm.y = 0
arm.sprite = 3

function moveCheck()
  if btn(0) then
    arm.x -= constants.armSpeed
    arm.x = (abs(arm.x) <= constants.maxDistanceFromBody) and arm.x or -constants.maxDistanceFromBody
  end
  if btn(1) then
    arm.x += constants.armSpeed
    arm.x = (arm.x <= constants.maxDistanceFromBody) and arm.x or constants.maxDistanceFromBody
  end
  if btn(2) then
    arm.y -= constants.armSpeed
    arm.y = (abs(arm.y) <= constants.maxDistanceFromBody) and arm.y or -constants.maxDistanceFromBody
  end
  if btn(3) then
    arm.y += constants.armSpeed
    arm.y = (arm.y <= constants.maxDistanceFromBody) and arm.y or constants.maxDistanceFromBody
  end
  if btn(5) then
    moveBody()
  end
end

function moveBody()
  local totalX = arm.x
  local totalY = arm.y
  if (totalX > 0) then
    body.x += constants.bodySpeed
  elseif (totalX < 0) then
    body.x -= constants.bodySpeed
  end
  if (totalY > 0) then
    body.y += constants.bodySpeed
  elseif (totalY < 0) then
    body.y -= constants.bodySpeed
  end
end

function goalCheck()
  -- todo
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
