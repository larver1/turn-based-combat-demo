// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function NewEncounter(_enemies, _bg) {
	
	instance_destroy(id);
	
	// Spawn instance where camera is positioned
	instance_create_depth(
		camera_get_view_x(view_camera[0]), 
		camera_get_view_y(view_camera[0]), 
		// Battle has to be front of screen
		-9999,
		oBattle,
		// Constructor values
		{
			enemies: _enemies,
			// Store ID of instance that called this function
			creator: id,
			battleBackground: _bg
		}
	);
}

function BattleCalcMagicDamage(_user, _target, _damage) {
	return max(1, ((_user.magic * _damage) - BattleCalcMagicalDefense(_target)));
}

function BattleCalcPhysicalDamage(_user, _target, _damage) {
	return max(1, ((_user.strength * _damage) - BattleCalcPhysicalDefense(_target)));
}

function BattleCalcPhysicalDefense(_target) {
	if(struct_exists(_target.statuses, "defenseMult")) {
		return _target.defense * _target.statuses.defenseMult;		
	}
	return _target.defense;
}

function BattleCalcMagicalDefense(_target) {
	if(struct_exists(_target.statuses, "defenseMult")) {
		return _target.magicDefense * _target.statuses.defenseMult;		
	}
	return _target.magicDefense;
}

function BattleCalcHaste(_target) {
	if(struct_exists(_target.statuses, "hasteMult")) {
		return _target.haste * _target.statuses.hasteMult;		
	}
	return _target.haste;
}

// _AliveDeadOrEither: 0 = alive only, 1 = dead only, 2 = any
function BattleChangeHP(_target, _amount, _AliveDeadOrEither = 0) {
	
	// Check fail states
	var _failed = false;
	if (_AliveDeadOrEither == 0) && (_target.hp <= 0) _failed = true;
	if (_AliveDeadOrEither == 1) && (_target.hp > 0) _failed = true;
	
	// Colour changes depending on amount
	var _col = c_white;
	if (_amount > 0) _col = c_lime;
	if (_failed) {
		_col = c_white;
		_amount = "failed";
	}
	
	// Show text
	instance_create_depth(
		_target.x,
		_target.y,
		_target.depth - 1,
		oBattleFloatingText,
		{ font: fnM5x7, col: _col, text: string(abs(_amount))}
	);
	
	// Value must be within range of min and max HP
	if(!_failed) _target.hp = clamp(_target.hp + _amount, 0, _target.hpMax);
}

// _AliveDeadOrEither: 0 = alive only, 1 = dead only, 2 = any
function BattleChangeMP(_target, _amount) {
	
	// Check fail states
	var _failed = false;
	if (_target.hp <= 0) _failed = true;
	
	// Colour changes depending on amount
	var _col = c_blue;
	if (_failed) {
		_col = c_white;
		_amount = "failed";
	}
	
	// Show text
	if(_amount > 0) {
		instance_create_depth(
			_target.x,
			_target.y,
			_target.depth - 1,
			oBattleFloatingText,
			{ font: fnM5x7, col: _col, text: string(abs(_amount))}
		);
	}
	
	// Value must be within range of min and max HP
	if(!_failed) _target.mp = clamp(_target.mp + _amount, 0, _target.mpMax);
}

function BattleGetStatusText(_target) {
	var _statuses = [];
	
	// Speed buff/debuff
	if(struct_exists(_target.statuses, "hasteMult")) {
		if(_target.statuses.hasteMult > 1) {
			array_push(_statuses, "HASTE");
		} else if(_target.statuses.hasteMult < 1) {
			array_push(_statuses, "SLOW"); 	
		}
	}
	
	if(struct_exists(_target.statuses, "defenseMult")) {
		if(_target.statuses.defenseMult > 1) {
			array_push(_statuses, "DEFEND");
		} else if(_target.statuses.defenseMult < 1) {
			array_push(_statuses, "BREAK"); 	
		}
	}
	
	return _statuses;
}