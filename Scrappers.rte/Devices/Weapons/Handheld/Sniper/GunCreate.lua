--package.path = package.path..";"..ScrappersData.Module .."/?.lua";
--require("Devices/Weapons/Handheld/GunReloads")

ScrappersSniperData = {}

--[[
Fire Modes:
	0 - full-auto,
	1 - semi-auto,
	2 - burst A
	3 - burst B
	4 - burst C
	
VariantTableCost = { {thing, Cost = x}, {thing, Cost = x}, {thing, Cost = x} }
VariantTable = { thing, thing, thing }

ReceiverObject:
	Name- String
	Cost- Int
	Mass- Float
	Mode- Int or VariantTable
	RateOfFire- Int or VariantTable
	BurstCount- Int (default - 3)
	BurstDelay- Int or VariantTable (in MS, default - (60 000 / RateOfFire) + 100)
	
	FrameStart- Int
	FrameEnd- Int
	FrameIntermediatePosition- Int (default - 0)
	
	Calibers- String or VariantTable
	
	JointOffset- Vector (default - ini offset)
	StanceOffset- Vector (default - ini offset)
	SharpStanceOffset- Vector (default - ini offset)
	SupportOffset- Vector (default - ini offset)
	SharpLength- Vector (default - ini offset)
	
	SightOffset- Vector
	BarrelOffset- Vector
	StockOffset- Vector
	MagazineOffset- Vector
	ModOffset- Vector (side mod offset, for example: laser)
	
	MechSound- String or VariantTable
	PreSound- String or VariantTable
	PreDelay- Int or VariantTable
	
	ReloadSoundSet
	
	OnCreate- Function(self, parent)
	OnUpdate- Function(self, parent, firedFrame, activated)
	
BarrelObject
	Cost- Int (default - calculated)
	Length- Int
	Mass- Float (default - calculated)
	Density- Float
	Bonus- String
	
ForegripObject
	Cost- Int (default - calculated)
	Mass- Float
	RecoilReductionStrength- Float
	RecoilReductionPowStrength- Float
	RecoilReductionDamping- Float
	
StockObject
	Cost- Int (default - calculated)
	Mass- Float
	RecoilReductionStrength- Float
	RecoilReductionPowStrength- Float
	RecoilReductionDamping- Float
	
MagazineObject
	Cost- Int
	RoundCount- Int
	Calibers- String or VariantTable
	
	EjectVelocity- Vector
	
	ReloadSoundSet- String
]]

-- Constants
ScrappersSniperData.BarrelAlloyLight = 0.075
ScrappersSniperData.BarrelAlloyMedium = 0.2
ScrappersSniperData.BarrelAlloyHeavy = 0.4

ScrappersSniperData.StockLight = 0.6
ScrappersSniperData.StockMedium = 1.25
ScrappersSniperData.StockHeavy = 2.15

ScrappersSniperData.GripLight = 0.5
ScrappersSniperData.GripMedium = 1.0
ScrappersSniperData.GripHeavy = 2.5

ScrappersSniperData.QualityBad = 1
ScrappersSniperData.QualityAverage = 2
ScrappersSniperData.QualityGood = 3

ScrappersSniperData.Budget = 20


ScrappersSniperData.Receivers = {}

ScrappersSniperData.Receivers[#ScrappersSniperData.Receivers + 1] = {
	Name = "Boltie",
	Cost = 2,
	Mass = 3.5,
	Mode = 0,
	RateOfFire = 250,
	
	FrameStart = 1,
	FrameIntermediate = 2,
	FrameEnd = 8,
	
	Calibers = "762x54",
	MagazineType = {"Straight", "RoundLoad", "Stripper"},
	
	JointOffset = Vector(-4, 2),
	SupportOffset = Vector(5, 1),
	EjectionOffset = Vector(1, -1.5),
	EjectionVelocity = Vector(-6, -3),
	SharpLength = 170,
	
	SightOffset = Vector(0, -3),
	BarrelOffset = Vector(5, -1),
	StockOffset = Vector(-6, -1),
	MagazineOffset = Vector(3, 0),
	ModOffset = Vector(5, 0),
	
	GunRattleType = 2,
	
	MechSound = {"Fire Mech Large Single Rifle A"},
	PreSound = {"Fire Pre Large Single Rifle A"},
	PreDelay = {35, 60},
	
	ReloadSoundSet = "Reload Bolt Large Single Rifle A",
	
	OnCreate = ScrappersReloadsData.BoltActionCreate,
	OnUpdate = ScrappersReloadsData.BoltActionUpdate
}

ScrappersSniperData.Magazines = {}
-- Test mag
ScrappersSniperData.Magazines[#ScrappersSniperData.Magazines + 1] = {
	Frame = 1,
	Cost = 3,
	RoundCount = 5,
	Calibers = "762x54",
	
	SoundType = "Rifle Metal",
	Type = "Straight",
	
	ReloadSoundSet = {"Reload Magazine Large Rifle E", "Reload Magazine Large Rifle G"}
}
-- Test Rounds
ScrappersSniperData.Magazines[#ScrappersSniperData.Magazines + 1] = {
	Internal = true,
	Cost = 0,
	RoundCount = 5,
	Calibers = {{"762x54", Cost = 0}},
	
	Type = "RoundLoad",
	
	ReloadSoundSet = "Reload RoundLoad Medium Single Round Stripper A"
}
-- Test Rounds + stripper
ScrappersSniperData.Magazines[#ScrappersSniperData.Magazines + 1] = {
	Internal = true,
	Cost = 0,
	RoundCount = 5,
	Calibers = {{"762x54", Cost = 0}},
	
	Type = "Stripper",
	
	ReloadSoundSet = "Reload RoundLoad Medium Rifle Stripper A"
}


ScrappersSniperData.Barrels = {}
-- 000
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 0,
	Length = 9,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 001
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 1,
	Length = 12,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 002
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 2,
	Length = 15,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 003
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 3,
	Cost = 0,
	Length = 6,
	Density = ScrappersSniperData.BarrelAlloyHeavy
}
-- 004
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 4,
	Cost = 0,
	Length = 8,
	Density = ScrappersSniperData.BarrelAlloyHeavy
}
-- 005
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 5,
	Cost = 0,
	Length = 8,
	Density = ScrappersSniperData.BarrelAlloyHeavy
}
-- 006
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 6,
	Length = 9,
	Density = ScrappersSniperData.BarrelAlloyLight
}
-- 007
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 7,
	Length = 7,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 008
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 8,
	Length = 8,
	Density = ScrappersSniperData.BarrelAlloyLight
}
-- 009
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 9,
	Length = 7,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 010
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 10,
	Length = 15,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 011
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 11,
	Length = 14,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 012
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 12,
	Length = 18,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 013
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 13,
	Length = 16,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 014
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 14,
	Length = 15,
	Density = ScrappersSniperData.BarrelAlloyHeavy
}
-- 015
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 15,
	Length = 16,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 016
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 16,
	Length = 14,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 017
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 17,
	Length = 16,
	Density = ScrappersSniperData.BarrelAlloyLight
}
-- 018
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 18,
	Length = 12,
	Density = ScrappersSniperData.BarrelAlloyHeavy
}
-- 019
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 19,
	Length = 17,
	Density = ScrappersSniperData.BarrelAlloyHeavy
}
-- 020
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 20,
	Length = 9,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 021
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 21,
	Length = 12,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 022
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 22,
	Length = 10,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 023
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 23,
	Length = 8,
	Density = ScrappersSniperData.BarrelAlloyLight
}
-- 024
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 24,
	Length = 12,
	Density = ScrappersSniperData.BarrelAlloyLight
}
-- 025
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 25,
	Length = 7,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 026
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 26,
	Length = 10,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 027
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 27,
	Length = 8,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 028
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 28,
	Length = 11,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 029
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 29,
	Length = 17,
	Density = ScrappersSniperData.BarrelAlloyMedium
}
-- 030
ScrappersSniperData.Barrels[#ScrappersSniperData.Barrels + 1] = {
	Frame = 30,
	Length = 13,
	Density = ScrappersSniperData.BarrelAlloyHeavy
}


ScrappersSniperData.BarrelMods = {}
-- 000
ScrappersSniperData.BarrelMods[#ScrappersSniperData.BarrelMods + 1] = {
	Frame = 0,
	Cost = 0,
	Length = 4,
	RecoilReduction = 0,
	MuzzleGFX = ScrappersGunFunctions.SpawnMuzzleGFXSide,
	MuzzleFlash = "Scrapper Muzzle Flash Side"
}
-- 001
ScrappersSniperData.BarrelMods[#ScrappersSniperData.BarrelMods + 1] = {
	Frame = 1,
	Cost = 0,
	Length = 4,
	RecoilReduction = 0,
	MuzzleGFX = ScrappersGunFunctions.SpawnMuzzleGFXUpDown,
	MuzzleFlash = "Scrapper Muzzle Flash Up Down"
}
-- 002
ScrappersSniperData.BarrelMods[#ScrappersSniperData.BarrelMods + 1] = {
	Frame = 2,
	Cost = 2,
	Length = 4,
	RecoilReduction = 0.02,
	MuzzleGFX = ScrappersGunFunctions.SpawnMuzzleGFXUpDown,
	MuzzleFlash = "Scrapper Muzzle Flash Up Down"
}
-- 003
ScrappersSniperData.BarrelMods[#ScrappersSniperData.BarrelMods + 1] = {
	Frame = 3,
	Cost = 2,
	Length = 5,
	RecoilReduction = 0.02,
	MuzzleGFX = ScrappersGunFunctions.SpawnMuzzleGFXUp,
	MuzzleFlash = "Scrapper Muzzle Flash Up"
}
-- 004
ScrappersSniperData.BarrelMods[#ScrappersSniperData.BarrelMods + 1] = {
	Frame = 4,
	Cost = 4,
	Length = 6,
	RecoilReduction = 0.075,
	MuzzleGFX = ScrappersGunFunctions.SpawnMuzzleGFXSide,
	MuzzleFlash = "Scrapper Muzzle Flash Side"
}
-- 005
ScrappersSniperData.BarrelMods[#ScrappersSniperData.BarrelMods + 1] = {
	Frame = 5,
	Cost = 3,
	Length = 5,
	RecoilReduction = 0.05,
	MuzzleGFX = ScrappersGunFunctions.SpawnMuzzleGFXSide,
	MuzzleFlash = "Scrapper Muzzle Flash Side"
}
-- 006
ScrappersSniperData.BarrelMods[#ScrappersSniperData.BarrelMods + 1] = {
	Frame = 6,
	Cost = 1,
	Length = 6,
	IsSupressor = true
}
-- 007
ScrappersSniperData.BarrelMods[#ScrappersSniperData.BarrelMods + 1] = {
	Frame = 7,
	Cost = 1,
	Length = 7,
	IsSupressor = true
}
-- 008
ScrappersSniperData.BarrelMods[#ScrappersSniperData.BarrelMods + 1] = {
	Frame = 8,
	Cost = 1,
	Length = 10,
	IsSupressor = true
}


ScrappersSniperData.Foregrips = {}
-- 000
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 0,
	Length = 7,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityGood
}
-- 001
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 1,
	Length = 11,
	Mass = ScrappersSniperData.GripHeavy,
	Quality = ScrappersSniperData.QualityGood
}
-- 002
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 2,
	Length = 9,
	Mass = ScrappersSniperData.GripLight,
	Quality = ScrappersSniperData.QualityGood
}
-- 003
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 3,
	Length = 7,
	Mass = ScrappersSniperData.GripHeavy,
	Quality = ScrappersSniperData.QualityGood
}
-- 004
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 4,
	Length = 8,
	Mass = ScrappersSniperData.GripLight,
	Quality = ScrappersSniperData.QualityBad
}
-- 005
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 5,
	Length = 8,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 006
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 6,
	Length = 8,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityBad
}
-- 007
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 7,
	Length = 10,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 008
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 8,
	Length = 4,
	Mass = ScrappersSniperData.GripLight,
	Quality = ScrappersSniperData.QualityBad
}
-- 009
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 9,
	Length = 6,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 010
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 10,
	Length = 12,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityGood
}
-- 011
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 11,
	Length = 7,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityGood
}
-- 012
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 12,
	Length = 7,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityGood
}
-- 013
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 13,
	Length = 7,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 014
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 14,
	Length = 6,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 015
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 15,
	Length = 5,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityBad
}
-- 016
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 16,
	Length = 6,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 017
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 17,
	Length = 8,
	Mass = ScrappersSniperData.GripHeavy,
	Quality = ScrappersSniperData.QualityAverage
}
-- 018
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 18,
	Length = 12,
	Mass = ScrappersSniperData.GripHeavy,
	Quality = ScrappersSniperData.QualityAverage
}
-- 019
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 19,
	Length = 7,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 020
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 20,
	Length = 7,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityBad
}
-- 021
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 21,
	Length = 9,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 022
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 22,
	Length = 10,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 023
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 23,
	Length = 6,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityBad
}
-- 024
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 24,
	Length = 7,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 025
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 25,
	Length = 9,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 026
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 26,
	Length = 5,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 027
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 27,
	Length = 7,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 028
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 28,
	Length = 7,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 029
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 29,
	Length = 5,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 030
ScrappersSniperData.Foregrips[#ScrappersSniperData.Foregrips + 1] = {
	Frame = 30,
	Length = 8,
	Mass = ScrappersSniperData.GripMedium,
	Quality = ScrappersSniperData.QualityAverage
}


ScrappersSniperData.Stocks = {}
-- 000
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 0,
	Mass = ScrappersSniperData.StockLight,
	Quality = ScrappersSniperData.QualityBad
}
-- 001
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 1,
	Mass = ScrappersSniperData.StockLight,
	Quality = ScrappersSniperData.QualityAverage
}
-- 002
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 2,
	Mass = ScrappersSniperData.StockLight,
	Quality = ScrappersSniperData.QualityAverage
}
-- 003
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 3,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 004
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 4,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 005
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 5,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityGood
}
-- 006
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 6,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityBad
}
-- 007
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 7,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityBad
}
-- 008
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 8,
	Mass = ScrappersSniperData.StockLight,
	Quality = ScrappersSniperData.QualityGood
}
-- 009
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 9,
	Mass = ScrappersSniperData.StockLight,
	Quality = ScrappersSniperData.QualityAverage
}
-- 010
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 10,
	Mass = ScrappersSniperData.StockLight,
	Quality = ScrappersSniperData.QualityGood
}
-- 011
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 11,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityGood
}
-- 012
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 12,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 013
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 13,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 014
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 14,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityGood
}
-- 015
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 15,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityGood
}
-- 016
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 16,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 017
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 17,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityBad
}
-- 018
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 18,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityAverage
}
-- 019
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 19,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityGood
}
-- 020
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 20,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityGood
}
-- 021
ScrappersSniperData.Stocks[#ScrappersSniperData.Stocks + 1] = {
	Frame = 21,
	Mass = ScrappersSniperData.StockMedium,
	Quality = ScrappersSniperData.QualityAverage
}


ScrappersSniperData.Sights = {}
-- 000
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 0,
	Cost = 2,
	SharpLength = 200
}
-- 001
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 1,
	Cost = 2,
	SharpLength = 200
}
-- 002
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 2,
	Cost = 2,
	SharpLength = 200
}
-- 003
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 3,
	Cost = 1,
	SharpLength = 100
}
-- 004
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 4,
	Cost = 1,
	SharpLength = 100
}
-- 005
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 5,
	Cost = 1,
	SharpLength = 100
}
-- 006
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 6,
	Cost = 1,
	SharpLength = 100
}
-- 007
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 7,
	Cost = 0,
	SharpLength = 65
}
-- 008
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 8,
	Cost = 0,
	SharpLength = 65
}
-- 009
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 9,
	Cost = 0,
	SharpLength = 65
}
-- 010
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 10,
	Cost = 0,
	SharpLength = 65
}
-- 011
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 11,
	Cost = 0,
	SharpLength = 65
}
-- 012
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 12,
	Cost = 0,
	SharpLength = 65
}
-- 013
ScrappersSniperData.Sights[#ScrappersSniperData.Sights + 1] = {
	Frame = 13,
	Cost = 0,
	SharpLength = 65
}

function Create(self)

	
	self.Budget = ScrappersSniperData.Budget + math.random(0,7)
	
	---- Randomization
	self.soundFireForceFullAuto = false -- Force caliber sound picking function to only use full auto sounds 
	self.soundFireForceSemi = false -- Force caliber sound picking function to only use semi sounds 
	
	local presetName = "Scrapper Assault Rifle"
	self.magazinePresetName = presetName.." Magazine"
	
	ScrappersGunFunctions.PickReceiver(self, ScrappersSniperData.Receivers)
	ScrappersGunFunctions.PickMagazine(self, ScrappersSniperData.Magazines)
	ScrappersGunFunctions.PickBarrel(self, ScrappersSniperData.Barrels, presetName.." Barrel")
	-- Optional
	ScrappersGunFunctions.PickForegrip(self, ScrappersSniperData.Foregrips, presetName.." Foregrip")
	ScrappersGunFunctions.PickStock(self, ScrappersSniperData.Stocks, presetName.." Stock")
	if math.random(0, 100) < 50 then -- 50% chance
		ScrappersGunFunctions.PickSight(self, ScrappersSniperData.Sights, presetName.." Sight")
	end
	if math.random(0, 100) < 40 then -- 40% chance
		ScrappersGunFunctions.PickBarrelMod(self, ScrappersSniperData.BarrelMods, presetName.." Barrel Mod")
	end
	
	ScrappersGunFunctions.SetupReloadSoundSets(self)
	
	-- Final tacticoolness
	if (not self.Receiver.ReleaseNotAllowed) and self.Budget > 0 and math.random(0, 100) < 50 then
		self.boltRelease = true;
	end
	
end