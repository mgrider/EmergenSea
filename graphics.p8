pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
local time = 0

function _draw()
	cls(12)
	spr(0, 56, 56, 2, 2)
	
	spr(2, 80 + 4*cos(time), 64)
	spr(3, 40 + 4*cos(time + 0.3), 64)
	time += 1/32
end

__gfx__
00005555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005555555500000000ee000eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000555555550000000ee200002ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005577777777550000ee20000002ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000555555555500000e200000002ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000eeeeeeeee00000e2000000002ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000eee77ee77ee000ee2000000002ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000eee71ee17ee000ee2000000002ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eee111111eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ee81111111eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ee88111111eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eee81888eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002ee8ee8eeee2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002eeeeeee220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000