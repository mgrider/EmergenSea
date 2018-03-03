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
  elseif (totalX < 0) then
    body.x -= constants.bodySpeed
    moveArmX(arm, constants.bodySpeed)
  end
  if (totalY > 0) then
    body.y += constants.bodySpeed
    moveArmY(arm, -constants.bodySpeed)
  elseif (totalY < 0) then
    body.y -= constants.bodySpeed
    moveArmY(arm, constants.bodySpeed)
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
