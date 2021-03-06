function AddCutoff(timeMS, duration, baseVolume)
	baseVolume = 1 - baseVolume
	return (math.cos(math.min(timeMS / duration, 1) * math.pi) + ((1 / baseVolume) - 1)) * baseVolume
end

function Create(self)
	self.ReceiverCreate = true
	
	self.parent = nil
	self.parentSet = false;
	
	self.firstShot = false;
	self.firingFirstShot = false;
	self.fireSoundFadeTimer = Timer()
	
	self.experimentalFullAutoSounds = true
	self.experimentalFullAutoMech = true
	self.experimentalFullAutoVolume = 0.67
	
	-- Animation
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(math.abs(self.SharpStanceOffset.X), self.SharpStanceOffset.Y)
	self.originalSharpLength = self.SharpLength
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 7
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = self.RotAngle
	
	--- Recoil system and calculation
	
	self.recoilAcc = 0 -- for sinous
	self.recoilStr = 0 -- for accumulator
	
	self.recoilStrength = 0 -- multiplier for base recoil added to the self.recoilStr when firing
	self.recoilPowStrength = 0.5 -- multiplier for self.recoilStr when firing
	self.recoilRandomUpper = 2 -- upper end of random multiplier (1 is lower)
	self.recoilDamping = RangeRand(0.9,1.0)
	
	self.recoilMax = 35 -- in deg.
	
	-- Calculate recoil
	local mass = CreateMOPixel(self.Caliber.ProjectilePresetName, ScrappersData.Module).Mass
	local velocity = self.Caliber.ProjectileVelocity
	
	self.recoilStrength = math.pow(mass * velocity / 4.25, 0.45) * 4
	
	if self:IsOneHanded() then
		self.recoilStrength = self.recoilStrength * 1.5
		self.recoilPowStrength = self.recoilPowStrength * 1.125
		self.recoilDamping = self.recoilDamping * 0.6
	end
	
	if self.recoilMode then
		if self.recoilMode == 1 then -- Shotgun
			self.recoilStrength = self.recoilStrength * 2.5
			self.recoilPowStrength = self.recoilPowStrength * 1.125
			self.recoilDamping = self.recoilDamping * 0.6
		elseif self.recoilMode == 2 then -- Sniper
			self.recoilStrength = self.recoilStrength * 3.25
			self.recoilPowStrength = self.recoilPowStrength * 1.125
			self.recoilDamping = self.recoilDamping * 0.4
		end
	end
	
	--
	self.fireVelocity = self.Caliber.ProjectileVelocity * 0.7 + (self.Caliber.ProjectileVelocity * 0.2 * self.BarrelLength / 10)
	self.fireMuzzleGFX = ScrappersGunFunctions.SpawnMuzzleGFXDefault
	if self.BarrelMod then
		if self.BarrelMod.MuzzleGFX then
			self.fireMuzzleGFX = self.BarrelMod.MuzzleGFX
		end
		if self.BarrelMod.RecoilReduction then
			self.recoilStrength = self.recoilStrength * (1 - self.BarrelMod.RecoilReduction)
		end
	end
	
	if self.Stock then
		self.recoilStrength = self.recoilStrength / (1 + (self.Stock.Quality / 24))
	end
	
	if self.Foregrip then
		self.recoilDamping = self.recoilDamping * (1 + (self.Foregrip.Quality / 24))
	end
	
	self.burstCoolDownDelay = (60000/self.RateOfFire)
	self.shotsPerBurst = (self.Receiver.BurstCount and self.Receiver.BurstCount or 3)
	self.burstShotCounter = 0
	
	self.preFireTimer = Timer()
	self.preFire = false
	self.preFireFired = false
	self.preFireActive = false
	
	self.fireTimer = Timer()
	self.fireTimerFired = false
	
	self.isIdle = false
	self.idleDelayTimer = Timer()
	self.idleDelay = 100
	
	-- sharpaiming, rattle sounds
	
	self.sharpAiming = false;
	
	self.sharpAimTimer = Timer();
	self.sharpAimDelay = 500;
	
	-- Broken UID fixer stuff
	self.checkBrokenUIDTimer = Timer()
	self.checkBrokenUIDDuration = 14 * 5 -- a few frames
	
	local actor = self:GetRootParent()
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	end
	
end

function Update(self)
	if not self.Receiver then return end
	
	self.rotationTarget = 0
	
	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = self:GetRootParent()
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
		
		-- Worth checking the UID!
		self.checkBrokenUIDTimer:Reset()
	end
	
	-- Idle animation, sharpaim rattling
	if self.parent then

		local controller = self.parent:GetController();
		local sharpAim = controller:IsState(Controller.AIM_SHARP) and not controller:IsState(Controller.MOVE_LEFT) and not controller:IsState(Controller.MOVE_RIGHT)
		
		if sharpAim and self.sharpAiming == false then
			self.sharpAiming = true;
			if self.sharpAimTimer:IsPastSimMS(self.sharpAimDelay) then
				self.rattleSound:Play(self.Pos);
				self.sharpAimTimer:Reset();
			end
		elseif (not sharpAim) and self.sharpAiming == true then
			self.sharpAiming = false;
			if self.sharpAimTimer:IsPastSimMS(self.sharpAimDelay) then
				self.rattleSound:Play(self.Pos);
				self.sharpAimTimer:Reset();
			end
			self.sharpAimTimer:Reset();
		end	

		if (not self.parent:IsPlayerControlled() and self.parent:NumberValueExists("Chatting") and not self.parent:NumberValueExists("InCombat")) then
			self.isIdle = true
			self.idleDelayTimer:Reset()
			self:Deactivate()
		elseif not self.idleDelayTimer:IsPastSimMS(self.idleDelay) then
			self:Deactivate()
			self.isIdle = false
		else
			self.isIdle = false
		end
	end
	
	
	-- Frame clamping
	--self.Frame = math.min(self.Receiver.FrameStart + math.max(self.FrameLocal, 0), self.Receiver.FrameChargeEnd or self.Receiver.FrameEnd)
	-- useless piece of shit code causing issues, for God's sake
	self.Frame = self.Receiver.FrameStart + math.max(self.FrameLocal and self.FrameLocal or 0, 0)
	
	-- "Reload" function create and update
	if self.ReceiverCreate and self.Receiver.OnCreate then
		self.Receiver.OnCreate(self, self.parent)
		self.ReceiverCreate = false
		
		--ScrappersGunFunctions.MagazineIn(self)
	end
	if not self.ReceiverCreate and self.Receiver.OnUpdate then
		self.Receiver.OnUpdate(self, self.parent, self:IsActivated())
	end
	
	-- Prefire (delayed fire)
	if (self.Magazine and self.Magazine.RoundCount > 0 and not self:IsReloading()) and self.soundFirePre and self.preDelay > 0 then
		local active = self:IsActivated() and not self.Chamber and not self.Deploy
		--if (active or self.preFire) and (self.fireTimer:IsPastSimMS(60000/self.RateOfFire) or self.preFireTimer:IsPastSimMS(self.preDelay)) then
		if active or self.preFire then
			if not self.preFireActive then
				self.soundFirePre:Play(self.Pos)
				self.preFire = true
				self.preFireActive = true
			end
			
			if self.preFireTimer:IsPastSimMS(self.preDelay) then
				if self.FiredFrame or self.burstCoolDownTimer then
					self.preFireFired = false
					self.preFire = false
				elseif not self.preFireFired then
					self:Activate()
				end
				
			else
				self:Deactivate()
			end
		else
			self.preFireActive = active
			self.preFireTimer:Reset()
		end
	end
	
	-- Idle animation
	if self.isIdle and self.parent then
		local ang = -40
		if self:IsOneHanded() then
			ang = 80
		end
		self.rotationTarget = self.rotationTarget - 40 - math.deg(self:GetParent().RotAngle) * self.FlipFactor
		self.parent:GetController():SetState(Controller.AIM_SHARP, false)
	end
	
	if self.Chamber or self.Deploy then
		self:Deactivate()
	end
	
	-- fake mag UID mismatch fixer
	if self.checkBrokenUIDTimer:IsPastSimMS(14) and not self.checkBrokenUIDTimer:IsPastSimMS(self.checkBrokenUIDDuration) then
		if self.MagazineData.MO then -- RTE engine never fails to surprise me
			-- Sometimes fake magazine parent's UID does not match it's intended/actual parent's UID, delete the broken bastard and replace it with a brand new working model
			-- fil 1, rte 0
			local magParent = self.MagazineData.MO:GetParent()
			if magParent and magParent.UniqueID ~= self.UniqueID then
				--print("wtf magazine bug has been fixed")
				self.MagazineData.MO.ToDelete = true
				self.MagazineData.MO = nil
				
				ScrappersGunFunctions.MagazineIn(self)
			end
		end
	end
	
	-- Magazine detach and attach
	if self:IsReloading() then
		-- Just in case!
		self.preFireFired = false
		self.preFire = false
		
		self.fireTimer:Reset()
		self.fireTimerFired = false
		
		if self:NumberValueExists("MagRemoved") then
			ScrappersGunFunctions.MagazineOut(self)
			--self:RemoveNumberValue("MagRemoved");
		else
			ScrappersGunFunctions.MagazineIn(self)
		end
		
		-- Worth checking the UID!
		self.checkBrokenUIDTimer:Reset()
	end
	
	-- Fire Mode (bursts, etc.)
	if self.FireMode == 2 then -- Burst A
		if self:IsReloading() then
			self.burstShotCounter = 0;
			self.burstActivated = false
		end
		if self.Magazine then
			if self.burstCoolDownTimer then
				if self.parent and self.parent:IsPlayerControlled() then
					self.burstCoolDownDelay = (30000 / self.RateOfFire); -- much shorter delay for players, otherwise gets stuck and is sucky
				else
					self.burstCoolDownDelay = (200000 / self.RateOfFire);
				end
				if self.burstCoolDownTimer:IsPastSimMS(self.burstCoolDownDelay) and self.parent and not (self:IsActivated() and self.parent:IsPlayerControlled()) then
					self.burstCoolDownTimer = nil;
				end
				
				self:Deactivate();
			elseif not self.burstActivated and (self.FiredFrame or self:IsActivated()) then
				self.burstActivated = true
				if self.FiredFrame then
					self.burstShotCounter = self.burstShotCounter + 1;
				end
			elseif self.burstActivated then
				self:Activate()
				if self.FiredFrame then
					self.burstShotCounter = self.burstShotCounter + 1;
					if self.burstShotCounter >= self.shotsPerBurst then
						self.burstCoolDownTimer = Timer();
						self.burstShotCounter = 0;
						self.burstActivated = false
					end
				end
			end
		else
			self.burstCoolDownTimer = nil;
			self.burstActivated = false
		end
	elseif self.FireMode == 3 then -- Burst B
		if self.Magazine then
			if self.burstCoolDownTimer then
				if self.parent and self.parent:IsPlayerControlled() then
					self.burstCoolDownDelay = (30000 / self.RateOfFire); -- much shorter delay for players, otherwise gets stuck and is sucky
				else
					self.burstCoolDownDelay = (200000 / self.RateOfFire);
				end
				if self.burstCoolDownTimer:IsPastSimMS(self.burstCoolDownDelay) and self.parent and not (self:IsActivated() and self.parent:IsPlayerControlled()) then
					self.burstCoolDownTimer = nil;
				else
					self:Deactivate();
				end
			elseif self:IsActivated() or self.burstActivated then
				self.burstActivated = true;
				if self.FiredFrame then
					self.burstShotCounter = self.burstShotCounter + 1;
					if self.burstShotCounter >= self.shotsPerBurst then
						self.burstCoolDownTimer = Timer();
						self.burstShotCounter = 0;
					end
				end
				if not self:IsActivated() then
					self.burstCoolDownTimer = Timer();
					self.burstActivated = false;
				end
			end
		else
			self.burstCoolDownTimer = nil;
			self.burstActivated = false
		end
	elseif self.FireMode == 4 then -- Burst C
		
	end
	
	-- Test
	--if UInputMan:KeyPressed(22) then
	--	self.experimentalFullAutoSounds = not self.experimentalFullAutoSounds
	--end
	--PrimitiveMan:DrawTextPrimitive(self.Pos, (self.experimentalFullAutoSounds and "Yes" or "No"), true, 0);
	
	-- Animation and recoil system
	if self.parent then
		
		-- Up/down left/right movement
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-3,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,7) * self.verticalAnim -- Vertical animation
		-- Up/down left/right movement
		
		
		-- Aim sway/smoothing
		--self.rotationTarget = self.rotationTarget - (self.angVel * 4)
		-- Aim sway/smoothing
		
		
		-- Progressive recoil update
		local dampMultiplier = 1 / (self.Mass / 10)
		self.recoilStr = math.floor(self.recoilStr / (1 + TimerMan.DeltaTimeSecs * 8.0 * math.min(self.recoilDamping * dampMultiplier, 2)) * 1000) / 1000
		self.recoilAcc = (self.recoilAcc + self.recoilStr * TimerMan.DeltaTimeSecs) % (math.pi * 4)
		
		self:SetNumberValue("recoilStrengthCurrent", self.recoilStr)
		
		local recoilA = (math.sin(self.recoilAcc) * self.recoilStr) * 0.05 * self.recoilStr
		local recoilB = (math.sin(self.recoilAcc * 0.5) * self.recoilStr) * 0.01 * self.recoilStr
		local recoilC = (math.sin(self.recoilAcc * 0.25) * self.recoilStr) * 0.05 * self.recoilStr
		
		local recoilFinal = math.max(math.min(recoilA + recoilB + recoilC, self.recoilMax), -self.recoilMax)
		
		-- Sharp length animation
		self.SharpLength = math.max(self.originalSharpLength - (self.recoilStr * 3 + math.abs(recoilFinal)), 0)
		
		self.rotationTarget = self.rotationTarget + recoilFinal -- apply the recoil
		-- Progressive recoil update
		
		
		-- Final rotation
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation)
		
		self.InheritedRotAngleOffset = total
		
		self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
		self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
	end
	
	--- Firing
	if self.experimentalFullAutoSounds and (self.FullAuto and (not self.firstShot or not self.FiredFrame) and not self.firingFirstShot) then -- EXPERIMENTAL FULL AUTO SOUNDS
		self.soundFireAdd.Volume = AddCutoff(self.fireSoundFadeTimer.ElapsedSimTimeMS, self.experimentalFullAutoCutOffTime or 50, self.experimentalFullAutoVolume or 0.67)
	end
	
	if self.FiredFrame then -- Fire sounds and bullet spawning
		self.Pos = self.Pos + Vector(1 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		self.fireTimer:Reset()
		self.fireTimerFired = true
		local muzzlePos = self.MuzzlePos
		
		-- Bullet
		ScrappersGunFunctions.SpawnBullet(self, muzzlePos)
		--
		
		-- Muzzle GFX
		self.fireMuzzleGFX(self, muzzlePos)
		--
		
		-- Recoil
		local recoilAdd = ((math.random(10, self.recoilRandomUpper * 10) / 10) * 0.5 * self.recoilStrength) -- Base
		recoilAdd = recoilAdd + (self.recoilStr * 0.6 * self.recoilPowStrength) -- Pow
		recoilAdd = recoilAdd / math.sqrt(self.Mass / 10) -- Mass influence
		self.recoilStr = self.recoilStr + recoilAdd
		--self:SetNumberValue("recoilStrengthBase", math.pow(self.recoilStrength * (1 + self.recoilPowStrength) / self.recoilDamping, 1.25))
		self:SetNumberValue("recoilStrengthBase", 30 / (1 + self.recoilPowStrength) * self.recoilDamping * ((2 + (self.recoilStrength / 12)) / 3))
		
		-- Sounds
		
		if self.experimentalFullAutoSounds and self.FullAuto then -- EXPERIMENTAL FULL AUTO SOUNDS
			self.fireSoundFadeTimer:Reset()
			
			if self.firstShot then
				self.firingFirstShot = true
				
				
				if self.experimentalFullAutoMech then
				 -- Two variants for mech modulation
					if self.UniqueID % 2 == 0 then -- Quieter mech, higher pitch
						self.soundFireMech.Pitch = self.soundFireMechBasePitch * 1.15
						self.soundFireMech.Volume = self.soundFireMechBaseVolume * 0.5
					else -- Louder mech, lower pitch
						self.soundFireMech.Pitch = self.soundFireMechBasePitch * 0.975
						self.soundFireMech.Volume = self.soundFireMechBaseVolume * 2.0
					end
				end
				
				-- Louder Bbss
				self.soundFireBass.Pitch = self.soundFireBassBasePitch * 1.1
				self.soundFireBass.Volume = self.soundFireBassBaseVolume * 1.2
				
				-- No changes here
				self.soundFireAdd.Pitch = self.soundFireAddBasePitch
				self.soundFireAdd.Volume = self.soundFireAddBaseVolume
			else
				self.firingFirstShot = false
				
				self.soundFireAdd:Stop(-1)
				
				-- No changes here
				self.soundFireMech.Pitch = self.soundFireMechBasePitch
				self.soundFireMech.Volume = self.soundFireMechBaseVolume
				
				-- No changes here
				self.soundFireBass.Pitch = self.soundFireBassBasePitch
				self.soundFireBass.Volume = self.soundFireBassBaseVolume
				
				-- Cutoff?
				self.soundFireAdd.Pitch = self.soundFireAddBasePitch
				self.soundFireAdd.Volume = AddCutoff(self.fireSoundFadeTimer.ElapsedSimTimeMS, 50, 0.67)
			end
		else -- Normal
			self.soundFireMech.Pitch = self.soundFireMechBasePitch
			self.soundFireMech.Volume = self.soundFireMechBaseVolume
			
			self.soundFireBass.Pitch = self.soundFireBassBasePitch
			self.soundFireBass.Volume = self.soundFireBassBaseVolume
			
			self.soundFireAdd.Pitch = self.soundFireAddBasePitch
			self.soundFireAdd.Volume = self.soundFireAddBaseVolume
		end

		self.soundFireMech:Play(self.Pos)
		self.soundFireAdd:Play(self.Pos)
		self.soundFireBass:Play(self.Pos)
		
		self.soundFireNoiseOutdoors:Stop(-1)
		self.soundFireNoiseIndoors:Stop(-1)
		self.soundFireNoiseBigIndoors:Stop(-1)
		
		self.soundFireNoiseSemiOutdoors:Stop(-1)
		self.soundFireNoiseSemiIndoors:Stop(-1)
		self.soundFireNoiseSemiBigIndoors:Stop(-1)
		
		local outdoorRays = 0;
		local indoorRays = 0;
		local bigIndoorRays = 0;

		if self.parent and self.parent:IsPlayerControlled() then
			self.rayThreshold = 2; -- this is the first ray check to decide whether we play outdoors
			local Vector2 = Vector(0,-700); -- straight up
			local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
			local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
			local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
			local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
			self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
		else
			self.rayThreshold = 1; -- has to be different for AI
			local Vector2 = Vector(0,-700); -- straight up
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg		
			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray};
		end
		
		for _, rayLength in ipairs(self.rayTable) do
			if rayLength < 0 then
				outdoorRays = outdoorRays + 1;
			elseif rayLength > 170 then
				bigIndoorRays = bigIndoorRays + 1;
			else
				indoorRays = indoorRays + 1;
			end
		end
		
		if outdoorRays >= self.rayThreshold then
			self.soundFireNoiseOutdoors:Play(self.Pos)
			if not self.FullAuto then
				self.soundFireNoiseSemiOutdoors:Play(self.Pos)
			end
			if self.firstShot then
				self.reflectionSemiSound:Stop()
				self.reflectionSemiSound = self.soundFireReflectionSemi
				self.reflectionSemiSound:Play(self.Pos)
			else
				self.reflectionSound:Stop()
				self.reflectionSemiSound:Stop()
				self.reflectionSound = self.soundFireReflection
				self.reflectionSound:Play(self.Pos)
			end
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.soundFireNoiseIndoors:Play(self.Pos)
			if not self.FullAuto then
				self.soundFireNoiseSemiIndoors:Play(self.Pos)
			end
		else -- bigIndoor
			self.soundFireNoiseBigIndoors:Play(self.Pos)
			if not self.FullAuto then
				self.soundFireNoiseSemiBigIndoors:Play(self.Pos)
			end
		end
		
		self.firstShot = false
		
	end
	
	if not (self:IsActivated() or self.preFire) then
		self.firstShot = true
		--self.firingFirstShot = false;
	end
	if self.animatedBolt then
		ScrappersGunFunctions.AnimateBolt(self, self.firedFrameFrame) -- Animate the bolt
	end
end

function OnAttach(self)
	if self.Receiver.OnAttach then
		self.Receiver.OnAttach(self, self.parent)
	end
end

function OnDetach(self)
	self.preFireFired = false
	self.preFire = false
	self.burstShotCounter = 0;
	self.burstActivated = false
	--self.rotation = 80
	self.fireTimer:Reset()
	self.fireTimerFired = false
	
	if self.Receiver.OnDetach then
		self.Receiver.OnDetach(self, self.parent)
	end
end