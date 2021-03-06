// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.2
//	@file Name: playerActions.sqf
//	@file Author: [404] Deadbeat, [404] Costlyy, [GoT] JoSchaap, AgentRev
//	@file Created: 20/11/2012 05:19

{ [player, _x] call fn_addManagedAction } forEach
[
	["Holster Weapon", { player action ["SwitchWeapon", player, player, 100] }, [], -11, false, false, "", "vehicle player == player && currentWeapon player != '' && (stance player != 'CROUCH' || currentWeapon player != handgunWeapon player)"], // A3 v1.58 bug, holstering handgun while crouched causes infinite anim loop
	["Unholster Primary Weapon", { player action ["SwitchWeapon", player, player, 0] }, [], -11, false, false, "", "vehicle player == player && currentWeapon player == '' && primaryWeapon player != ''"],

	["Heal Self", "addons\scripts\healSelf.sqf",0,0,false,false,"","((damage player)>0.01 && (damage player)<0.25499) && ('FirstAidKit' in (items player)) && (vehicle player == player)"],

	[format ["<img image='client\icons\playerMenu.paa' color='%1'/> <t color='%1'>[</t>Player Menu<t color='%1'>]</t>", "#FF8000"], "client\systems\playerMenu\init.sqf", [], -10, false],

	["Track Beacons", "addons\beacondetector\beacondetector.sqf",0,-10,false,false,"","('ToolKit' in (items player)) && !BeaconScanInProgress"],
	["<img image='\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa'/> <t color='#FFFFFF'>Cancel tracking.</t>", "Beaconscanstop = true",0,-10,false,false,"","BeaconScanInProgress"],

	["<img image='client\icons\money.paa'/> Pickup Money", "client\actions\pickupMoney.sqf", [], 1, false, false, "", "{_x getVariable ['owner', ''] != 'mission'} count (player nearEntities ['Land_Money_F', 5]) > 0"],

	["<img image='\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa'/> <t color='#FFFFFF'>Cancel Action</t>", { doCancelAction = true }, [], 1, false, true, "", "mutexScriptInProgress"],

	["<img image='client\icons\repair.paa'/> Salvage", "client\actions\salvage.sqf", [], 1.1, false, false, "", "!isNull cursorTarget && !alive cursorTarget && {cursorTarget isKindOf 'AllVehicles' && !(cursorTarget isKindOf 'Man') && player distance cursorTarget <= (sizeOf typeOf cursorTarget / 3) max 2}"],

	["<img image='client\icons\r3f_unlock.paa'/> Pick Lock", "addons\scripts\lockPick.sqf", [cursorTarget], 1, false, false, "", "!isNull cursorTarget && alive cursorTarget && {{ cursorTarget isKindOf _x } count ['LandVehicle', 'Ship', 'Air'] > 0 ;} && ('ToolKit' in (items player)) && cursorTarget getVariable ['ownerUID',''] != getPlayerUID player && locked cursorTarget >= 2 && cursorTarget distance player < 5"],

	["[0]"] call getPushPlaneAction,
	["Push vehicle", "server\functions\pushVehicle.sqf", [2.5, true], 1, false, false, "", "[2.5] call canPushVehicleOnFoot"],
	["Push vehicle forward", "server\functions\pushVehicle.sqf", [2.5], 1, false, false, "", "[2.5] call canPushWatercraft"],
	["Push vehicle backward", "server\functions\pushVehicle.sqf", [-2.5], 1, false, false, "", "[-2.5] call canPushWatercraft"],

	["<t color='#FF0000'>Emergency eject</t>",  { [[], fn_emergencyEject] execFSM "call.fsm" }, [], -9, false, true, "", "(vehicle player) isKindOf 'Air' && !((vehicle player) isKindOf 'ParachuteBase')"],
	["<t color='#FF00FF'>Open magic parachute</t>", { [[], fn_openParachute] execFSM "call.fsm" }, [], 20, true, true, "", "vehicle player == player && (getPos player) select 2 > 2.5"],

	["<t color='#FF66CC'>Give up!</t>",  "addons\Surrender\fn_surrender_request.sqf", [], 1,false,false,"","(isPlayer cursorTarget) && {[cursorTarget] call canSuggestToSurrender}"],	
	["<t color='#47B247'>Surrender</t>",  "addons\Surrender\fn_surrender_confirm.sqf", [], 1,false,false,"","(isPlayer cursorTarget) && {[] call wasSuggestedToSurrender}"],	
	["<t color='#FF0000'>Extort</t>",  "addons\Surrender\fn_surrender_actions.sqf", [cursorTarget,"extort"], 1,false,false,"","(isPlayer cursorTarget) && {(cursorTarget getVariable ['sur_isSurrendering',false]) && {(player distance cursorTarget) < 5}}"],	
	["<t color='#FF0000'>Look in pockets</t>",  "addons\Surrender\fn_surrender_actions.sqf", [cursorTarget,"money"], 1,false,false,"","(isPlayer cursorTarget) && {(cursorTarget getVariable ['sur_isSurrendering',false]) && {(player distance cursorTarget) < 5}}"],	
	["<t color='#FF0000'>Release</t>",  "addons\Surrender\fn_surrender_actions.sqf", [cursorTarget,"release"], 1,false,false,"","(isPlayer cursorTarget) && {(cursorTarget getVariable ['sur_isSurrendering',false]) && {(player distance cursorTarget) < 5}}"]
	
	//["Airdrop Menu", "addons\APOC_Airdrop_Assistance\APOC_cli_menu.sqf",[], -100, false, false]
];


// Hehehe...
if !(288520 in getDLCs 1) then
{
	[player, ["<t color='#00FFFF'>Get in as Driver</t>", "client\actions\moveInDriver.sqf", [], 6, true, true, "", "cursorTarget isKindOf 'Kart_01_Base_F' && player distance cursorTarget < 3.4 && isNull driver cursorTarget"]] call fn_addManagedAction;
};

// Morehehe...
if !(304380 in getDLCs 1) then 
{
	[player, ["<img image='client\icons\driver.paa'/> Get in as Pilot", "client\actions\moveInDriver.sqf", [], 6, true, true, "", "(locked cursorTarget != 2) && ((cursorTarget isKindOf 'B_Heli_Transport_03_F') or (cursorTarget isKindOf 'B_Heli_Transport_03_unarmed_F') or (cursorTarget isKindOf 'Heli_Transport_04_base_F')) && player distance cursorTarget < 10 && isNull driver cursorTarget"]] call fn_addManagedAction;
	[player, ["<img image='client\icons\gunner.paa'/> Get in as Copilot", "client\actions\moveInTurret.sqf", [0], 6, true, true, "", "(locked cursorTarget != 2) && ((cursorTarget isKindOf 'B_Heli_Transport_03_F') or (cursorTarget isKindOf 'B_Heli_Transport_03_unarmed_F') or (cursorTarget isKindOf 'Heli_Transport_04_base_F')) && player distance cursorTarget < 10 && isNull (cursorTarget turretUnit [0])"]] call fn_addManagedAction;
	[player, ["<img image='client\icons\gunner.paa'/> Get in as Left door gunner", "client\actions\moveInTurret.sqf", [1], 6, true, true, "", "(locked cursorTarget != 2) && ((cursorTarget isKindOf 'B_Heli_Transport_03_F') or (cursorTarget isKindOf 'B_Heli_Transport_03_unarmed_F')) && player distance cursorTarget < 10 && isNull (cursorTarget turretUnit [1])"]] call fn_addManagedAction;
	[player, ["<img image='client\icons\gunner.paa'/> Get in as Right door gunner", "client\actions\moveInTurret.sqf", [2], 6, true, true, "", "(locked cursorTarget != 2) && ((cursorTarget isKindOf 'B_Heli_Transport_03_F') or (cursorTarget isKindOf 'B_Heli_Transport_03_unarmed_F')) && player distance cursorTarget < 10 && isNull (cursorTarget turretUnit [2])"]] call fn_addManagedAction;
};

if (["A3W_purchasedVehicleSaving"] call isConfigOn) then
{
	[player, ["<img image='client\icons\save.paa'/> Save Vehicle", "addons\vsave\vehicleSave.sqf", [], -9.5, false, true, "", "call SaveVehicleCheck"]] call fn_addManagedAction;
	[player, ["<img image='client\icons\save.paa'/> Re\Save Vehicle", "addons\vsave\vehicleReSave.sqf", [], -9.5, false, true, "", "call ReSaveVehicleCheck"]] call fn_addManagedAction;
	[player, ["<img image='client\icons\save.paa'/> Save Weapon", "addons\vsave\weaponSave.sqf", [], -9.5, false, true, "", "call SaveWeaponCheck"]] call fn_addManagedAction;  
	[player, ["<img image='client\icons\save.paa'/> Re\Save Weapon", "addons\vsave\weaponReSave.sqf", [], -9.5, false, true, "", "call ReSaveWeaponCheck"]] call fn_addManagedAction;
};
