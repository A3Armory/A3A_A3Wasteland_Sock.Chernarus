// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: FAR_HandleDamage_EH.sqf
//	@file Author: Farooq, AgentRev

#include "FAR_defines.sqf"
#include "gui_defines.hpp"

//private ["_unit", "_selection", "_damage", "_source", "_fatalHit", "_killerVehicle", "_oldDamage"];

_unit = _this select 0;
//_selection = _this select 1;
//_damage = _this select 2;
_source = _this select 3;
_ammo = _this select 4;

// a critical hit is if this type of selection can trigger death upon suffering damage >= 1 (usually all of them except "hands", "arms", and "legs")
// this is intercepted to prevent engine-triggered death and put the unit in revive mode instead; behavior and selections can change with game updates

_criticalHit = (_selection in ["","body","head","spine1","spine2","spine3","pelvis","neck","face_hub"]);
_fatalHit = (_damage >= 1 && alive _unit && _criticalHit);

// Find suspects
if (((_fatalHit && !isNull _source) || (_criticalHit && UNCONSCIOUS(_unit))) && isNil {_unit getVariable "FAR_killerVehicle"}) then
{
	[_unit, _source, _ammo] call FAR_setKillerInfo;
};

if (UNCONSCIOUS(_unit)) then
{
	//Headshot - tries to confirm result of injury was from headshot
	if(!FAR_NoHeadshot && alive _unit)then{
		if(_selection == "head") then{
			_killer = _unit call FAR_findKiller;
			if((_ammo splitString "_" select 0) == "B" && _damage >= 1 && isPlayer _killer)then{
				//Player was headshot from a player with a bullet projectile
				FAR_NoHeadshot = false;
				_unit setFatigue 0;
				_unit enableFatigue false;
				[_unit, _killer] spawn
				{
					_unit = _this select 0;
					_killer = _this select 1;
					_names = [toArray name _unit];
					if (!isNull _killer && { (_killer != _unit) && (vehicle _killer != vehicle _unit)}) then
					{
						_names set [1, toArray name _killer];
					};
					FAR_headshotMessage = [_names, netId _unit, netId _killer];
					publicVariable "FAR_headshotMessage";
					["FAR_headshotMessage", FAR_headshotMessage] call FAR_public_EH;
					_unit setDamage 1;
				};
			}
			else
			{
				//Player was not headshot
				_unit allowDamage false;
				FAR_NoHeadshot = true;
			};
		};
	};
	
	//if (_selection != "?") then
	//{
		_oldDamage = if (_selection == "") then { damage _unit } else { _unit getHit _selection };

		if (!isNil "_oldDamage") then
		{
			// Apply part of the damage without multiplier when below the stabilization threshold of 50% damage
			if (STABILIZED(_unit) && {_criticalHit && FAR_DamageMultiplier < 1}) then
			{
				_oldDamage = _damage min 0.5;
			};

			_damage = ((_damage - _oldDamage) * FAR_DamageMultiplier) + _oldDamage;

			if (_criticalHit) then
			{
				_unit setDamage _damage;
			};
		};

		if (_damage >= 1 && _criticalHit) then
		{
			diag_log format ["KILLED by [%1] with [%2]", _source, _ammo];
		};
	//};
}
else
{
	// Allow revive if unit is dead and not in exploded vehicle
	if (_fatalHit && alive vehicle _unit) then
	{
		_unit setVariable ["FAR_isUnconscious", 1, true];
		[] spawn fn_deletePlayerData;

		//_unit allowDamage false;
		FAR_NoHeadshot = false;
		//if (vehicle _unit == _unit) then { [_unit, "AinjPpneMstpSnonWrflDnon"] call switchMoveGlobal };
		_unit enableFatigue true;
		_unit setFatigue 1;

		if (!isNil "FAR_Player_Unconscious_thread" && {typeName FAR_Player_Unconscious_thread == "SCRIPT" && {!scriptDone FAR_Player_Unconscious_thread}}) then
		{
			terminate FAR_Player_Unconscious_thread;
		};

		closeDialog ReviveBlankGUI_IDD;
		closeDialog ReviveGUI_IDD;

		FAR_Player_Unconscious_thread = [_unit, _source] spawn FAR_Player_Unconscious;

		_damage = 0.5;

		diag_log format ["INCAPACITATED by [%1] with [%2]", _source, _ammo];
	};
};

//_damage
