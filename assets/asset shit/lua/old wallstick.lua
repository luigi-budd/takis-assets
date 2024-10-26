	local noslopereset = false
	if car.slopetransfer
	--make sure we're "on" a wall
	and not P_IsObjectOnGround(car)
	--and that youre "sticking" onto it (running into it)
	and car.wallstick
		car.grounded = true
		noslopereset = true
		car.momx,car.momy = FixedMul($1,me.friction),FixedMul($2,me.friction)
	end
	
	local wallstickingang = nil
	if car.wallline and car.wallline.valid
		car.stickingtime = $+1
		print("HANDLE STICK")
		
		local wallline = lines[p.lastlinehit]
		local v1,v2 = wallline.v1,wallline.v2
		
		local whichside = P_PointOnLineSide(car.x,car.y,wallline)
		
		local lineang = R_PointToAngle2(v1.x,v1.y, v2.x,v2.y)
		local stickang = lineang
		if whichside
			lineang = $+ANGLE_180
		end
		
		wallstickingang = lineang
		local lx,ly = P_ClosestPointOnLine(car.x,car.y,wallline)
		local dist = R_PointToDist2(car.x,car.y,lx,ly)
		if false --do
			local lineleng = R_PointToDist2(v1.x,v1.y, v2.x,v2.y)
			local firstvleng = R_PointToDist2(v1.x,v1.y, lx,ly)
			local secondvleng = R_PointToDist2(v2.x,v2.y, lx,ly)
			
			if firstvleng > lineleng
				lx,ly = v2.x,v2.y
			end
			if secondvleng > lineleng
				lx,ly = v1.x,v1.y
			end
		
		end
		
		P_SpawnMobj(lx,ly,car.z,MT_THOK)
		P_SpawnMobj(
			v1.x,
			v1.y,
			car.z,MT_THOK
		)
		P_SpawnMobj(
			v2.x,
			v2.y,
			car.z,MT_THOK
		)
		
		--only stick if we're within the lines' verticies
		do
			local lineleng = R_PointToDist2(v1.x,v1.y,v2.x,v2.y)
			local firstvleng = R_PointToDist2(v1.x,v1.y,car.x,car.y)
			local secondvleng = R_PointToDist2(v2.x,v2.y,car.x,car.y)
			local angleto = R_PointToAngle2(car.x,car.y,lx,ly)
			
			if (firstvleng < lineleng + car.radius*2)
			and (secondvleng < lineleng + car.radius*2)
			or true
			and car.stickingtime < 5
				P_Thrust(car,
					angleto,
					5*car.scale
				)
				P_XYMovement(car)
			end
			
			takis.accspeed = abs(FixedHypot(FixedHypot(me.momx,me.momy) - car.radius/2,me.momz))
			takis.accspeed = FixedDiv($,me.scale)
		end
		
		--uncomment for antigrav
		car.flags = $|MF_NOGRAVITY
		car.momz = $*9/10
		if abs(car.momz) < FU/32
			car.momz = 0
		end
		
		--stay close to the wall
		if dist <= car.radius*3/2
		and not P_IsObjectOnGround(car)
			local flip = P_MobjFlip(car)
			me.pitch = FixedAngle(FixedMul(-90*FU*flip,cos(lineang+ANGLE_90)))
			me.roll = FixedAngle(FixedMul(-90*FU*flip,sin(lineang+ANGLE_90)))
		end
		car.wallstick = TR/4
		
		local aboveline = false
		do
			local frontsec = wallline.frontsector
			local backsec = wallline.backsector
			local nextsector = nil
			
			if frontsec ~= nil
			and frontsec ~= car.subsector.sector
				nextsector = frontsec
				print("FRONTSEC")
			elseif backsec ~= nil
			and backsec ~= car.subsector.sector
				nextsector = backsec
				print("BACKSECK")
			end
			
			if nextsector and nextsector.valid
			and (GetActorZ(car,me,1) > nextsector.floorheight)
				print("ABOVE")
				if car.wallunstick > 2
					aboveline = true
					P_Thrust(car,
						R_PointToAngle2(car.x,car.y,lx,ly),
						car.radius/2
					)
				end
				car.wallunstick = $+1
			else
				car.wallunstick = 0
			end
		end
		aboveline = false
		
		if P_IsObjectOnGround(car)
		or car.standingslope
		or aboveline
			car.wallstick = 0
			car.wallline = nil
			car.wallcooldown = 5
			if not aboveline
				print("THRUSTBACK")
				P_Thrust(car,
					R_PointToAngle2(car.x,car.y,lx,ly),
					-car.radius*3/2
				)
			else
				me.pitch,me.roll = 0,0
			end
			if car.standingslope
				P_SetObjectMomZ(car,5*FU)
			end
			
		end
	end
	
	if car.wallstick
		car.wallstick = $-1
		if car.wallstick == 0
			car.wallcooldown = 5
		end
	else
		car.wallunstick = 0
		car.slopetransfer = false
		car.wallline = nil
		car.stickingtime = 0
	end
	
	if car.wallcooldown then car.wallcooldown = $-1 end
