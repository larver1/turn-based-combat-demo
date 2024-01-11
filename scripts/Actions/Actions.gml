// Action Library
global.actionLibrary = {
	attack: {
		name: "Attack",
		description: "{0} attacks!",
		// Where action should be displayed
		subMenu: -1,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		// Which animation they should use
		userAnimation: "attack",
		effectSprite: sAttackBonk,
		// Should animation play on top of target
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets) {
			var _damage = ceil(_user.strength + random_range(-_user.strength * 0.25, _user.strength * 0.25));
			BattleChangeHP(_targets[0], -_damage, 0);
		}
	},
	ice: {
		name: "Ice",
		description: "{0} casts Ice!",
		mpCost: 4,
		// Where action should be displayed
		subMenu: "Magic",
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.VARIES,
		// Which animation they should use
		userAnimation: "cast",
		effectSprite: sAttackIce,
		// Should animation play on top of target
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets) {
			// Go through every selected target and apply damage
			for (var i = 0; i < array_length(_targets); i++) {
				var _damage = irandom_range(15, 20);
				if (array_length(_targets) > 1) _damage = ceil(_damage * 0.75);
				BattleChangeHP(_targets[i], -_damage);
			}
			BattleChangeMP(_user, -mpCost);
		}
	},
	haste: {
		name: "Haste",
		description: "{0} speeds {1} up!",
		mpCost: 4,
		// Where action should be displayed
		subMenu: "Magic",
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		// Which animation they should use
		userAnimation: "cast",
		effectSprite: sAttackHeal,
		// Should animation play on top of target
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets) {
			// Go through every selected target and apply damage
			for (var i = 0; i < array_length(_targets); i++) {
				_targets[i].statuses.hasteMult += 0.5;
			}
			BattleChangeMP(_user, -mpCost);
		}
	},
	hastega: {
		name: "Hastega",
		description: "{0} speeds all targets up!",
		mpCost: 10,
		// Where action should be displayed
		subMenu: "Magic",
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.ALWAYS,
		// Which animation they should use
		userAnimation: "cast",
		effectSprite: sAttackHeal,
		// Should animation play on top of target
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets) {
			// Go through every selected target and apply damage
			for (var i = 0; i < array_length(_targets); i++) {
				_targets[i].statuses.hasteMult += 0.5;
			}
			BattleChangeMP(_user, -mpCost);
		}
	},
	restore: {
		name: "Restore",
		description: "{0} restores the {1}'s energy!",
		mpCost: 4,
		// Where action should be displayed
		subMenu: "Magic",
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		// Which animation they should use
		userAnimation: "cast",
		effectSprite: sAttackHeal,
		// Should animation play on top of target
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets) {
			// Go through every selected target and apply damage
			for (var i = 0; i < array_length(_targets); i++) {
				BattleChangeMP(_targets[i], 10);
			}
			BattleChangeMP(_user, -mpCost);
		}
	},
	cure: {
		name: "Cure",
		description: "{0} heals {1}!",
		mpCost: 4,
		// Where action should be displayed
		subMenu: "Magic",
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		// Which animation they should use
		userAnimation: "cast",
		effectSprite: sAttackHeal,
		// Should animation play on top of target
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets) {
			// Go through every selected target and apply damage
			for (var i = 0; i < array_length(_targets); i++) {
				BattleChangeHP(_targets[i], 40);
			}
			BattleChangeMP(_user, -mpCost);
		}
	},
	defend: {
		name: "Defend",
		description: "{0} defends {1}!",
		mpCost: 0,
		subMenu: -1,
		// Where action should be displayed
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		// Which animation they should use
		userAnimation: "cast",
		effectSprite: sAttackSlash,
		// Should animation play on top of target
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets) {
			// Go through every selected target and apply damage
			_user.statuses.defenseMult += 0.5;
		}
	},
}

enum MODE {
	NEVER = 0,
	ALWAYS = 1,
	VARIES = 2
}