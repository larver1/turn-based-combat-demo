// This will be only instance running
instance_deactivate_all(true);

units = [];
turn = 0;
unitTurnOrder = [];
unitRenderOrder = [];
second = current_second;

// Make targetting cursor
cursor = {
	activeUser: noone,
	activeTarget: noone,
	activeAction: -1,
	// Targetting enemy or player side
	targetSide: -1,
	// Which member to target
	targetIndex: 0,
	targetAll: false,
	// Delay between select menu selection and listen for key press on a target selection
	confirmDelay: 0,
	active: false
}

turnCount = 0;
roundCount = 0;
battleWaitTimeFrames = 30;
battleWaitTimeRemaining = 0;
battleText = "";
currentUser = noone;
currentAction = -1;
currentTargets = noone;

// Make enemies
for(var i = 0; i < array_length(enemies); i++) {
	enemyUnits[i] = instance_create_depth(
		x + 250 + (i * 10), 
		y + 68 + (i * 20), 
		depth - 10, 
		oBattleUnitEnemy,
		enemies[i]
	);
	
	// Puts ID of each unit into list
	array_push(units, enemyUnits[i]);
}

// Make party
for(var i = 0; i < array_length(oGame.party); i++) {
	partyUnits[i] = instance_create_depth(
		x + 70 + (i * 10), 
		y + 68 + (i * 15), 
		depth - 10, 
		oBattleUnitPC,
		oGame.party[i]
	);
	
	// Puts ID of each unit into list
	array_push(units, partyUnits[i]);
}

array_copy(unitTurnOrder, 0, units, 0, array_length(units));

// Gives a random turn order
RefreshTurnOrder = function() {
	array_sort(unitTurnOrder, function(_1, _2) {
		return (_2.haste * _2.statuses.hasteMult) - (_1.haste * _1.statuses.hasteMult);	
	});
}


// Get render order
// Higher Y = further down = rendered closest to front
RefreshRenderOrder = function() {
	unitRenderOrder = [];
	// Copies contents of units array into unitRenderOrder, without copying reference
	array_copy(unitRenderOrder, 0, units, 0, array_length(units));
	
	// Sorts render order based on Y
	array_sort(unitRenderOrder, function(_1, _2) {
		// Negative int if elm1 goes before elm2, meaning elm1 is rendered first
		return _1.y - _2.y;
	});
}

RefreshTurnOrder();
RefreshRenderOrder();

// Player/Enemy chooses action from menu
function BattleStateSelectAction() {
	if(!instance_exists(oMenu)) {
		// Get current unit
		var _unit = unitTurnOrder[turn];
		
		// Check if unit can't act 
		if(!instance_exists(_unit)) || (_unit.hp <= 0) {
			battleState = BattleStateVictoryCheck;
			exit;
		}
		
		// If unit is player
		if (_unit.object_index == oBattleUnitPC) {
			// Compile action menu
			var _menuOptions = [];
			var _subMenus = {};
			
			var _actionList = _unit.actions;
			for(var i = 0; i < array_length(_actionList); i++) {
				var _action = _actionList[i];
				var _available = true;
				if(struct_exists(_action, "mpCost")) {
					if(_action.mpCost > _unit.mp) _available = false;
				}
				
				// Name of action, and how many you can use (in case action is an item)
				var _name = _action.name;
				var _option = {
					name: _name,
					func: MenuSelectAction,
					args: [_unit, _action],
					available: _available
				};
				
				// If no sub menu, push action to menu
				if(_action.subMenu == -1) {		
					array_push(_menuOptions, _option);
				} else {
					// Create or add sub menu
					if(is_undefined(_subMenus[$ _action.subMenu])) {
						variable_struct_set(_subMenus, _action.subMenu, [_option]);
					} else {
						array_push(_subMenus[$ _action.subMenu], _option);	
					}
				}
			}
			
			// Turn sub menus into array
			var _subMenusArray = variable_struct_get_names(_subMenus);
			for (var i = 0; i < array_length(_subMenusArray); i++) {
				// Sort submenu if needed		
				// Add back option
				array_push(_subMenus[$ _subMenusArray[i]], {
					name: "Back", 
					func: MenuGoBack, 
					args: -1,
					available: true
				});
					
				// Add submenu to main menu
				array_push(_menuOptions, {
					name: _subMenusArray[i], 
					func: SubMenu, 
					args: [_subMenus[$ _subMenusArray[i]]],
					available: true	
				});
				
			}
			
			Menu(x + 10, y + 110, _menuOptions, , 74, 60);
		} else {
			// Else if enemy
			var _enemyAction = _unit.AIscript();
			if (_enemyAction != -1) BeginAction(_unit.id, _enemyAction[0], _enemyAction[1]);
		}
	}
}

// Call directly from player menu or enemy
function BeginAction(_user, _action, _targets) {
	currentUser = _user;
	currentAction = _action;
	currentTargets = _targets;
	
	// Convert single target into array
	if(!is_array(currentTargets)) currentTargets = [currentTargets];
	battleText = string_ext(_action.description, [currentUser.name, currentTargets[0].name]);
	
	// Adds small delay between action finishing and game moving on
	battleWaitTimeRemaining = battleWaitTimeFrames;
	with (_user) {
		acting = true;
		// Play user animation
		// If userAnimation exists and sprite exists, play it
		// $ "userAnimation", checks if property exists in action struct before accessing it
		if (!is_undefined(_action[$ "userAnimation"])) && (!is_undefined(_user.sprites[$ _action.userAnimation])) {
			sprite_index = sprites[$ _action.userAnimation];
			image_index = 0;
		}
	}
	
	battleState = BattleStatePerformAction;
}

// Play animation/sounds/effects first
function BattleStatePerformAction() {
	// If animation is playing
	if (currentUser.acting) {
		// When ended, perform action effect
		if (currentUser.image_index >= currentUser.image_number - 1) {
			with(currentUser) {
				// Stop animation
				sprite_index = sprites.idle;
				image_index = 0;
				acting = false;
			}
			
			// Check if action has property before playing effect
			if (variable_struct_exists(currentAction, "effectSprite")) {
				// If animation is played on a target
				if ((currentAction.effectOnTarget == MODE.ALWAYS) || ((currentAction.effectOnTarget == MODE.VARIES) && (array_length(currentTargets) <= 1))) {
					for (var i = 0; i < array_length(currentTargets); i++) {
						// Display the effect where the target is
						instance_create_depth(
							currentTargets[i].x, 
							currentTargets[i].y, 
							currentTargets[i].depth - 1, 
							oBattleEffect, 
							{ sprite_index: currentAction.effectSprite}
						);	
					}
				// If animation is played in center of screen
				} else {
					var _effectSprite = currentAction.effectSprite;
					if (_variable_struct_exists(currentAction, "effectSpriteNoTarget")) _effectSprite = currentAction.effectSpriteNoTarget;
					instance_create_depth(
						x, 
						y, 
						depth - 100, 
						oBattleEffect,
						{ sprite_index: _effectSprite }
					);
				}
			}
			
			// Apply logic of action (e.g. deal damage)
			currentAction.func(currentUser, currentTargets);
		}
	// If animation done playing
	} else {
		// Wait for delay before ending turn
		if (!instance_exists(oBattleEffect)) {
			battleWaitTimeRemaining--;
			// After turn end, check if won
			if (battleWaitTimeRemaining == 0) {
				battleState = BattleStateVictoryCheck;	
			}
		}
	}
}

// Check if battle should end
function BattleStateVictoryCheck() {
	
	// Check if enemies dead
	var _partyDead = true;
	for(var i = 0; i < array_length(enemyUnits); i++) {
		if(enemyUnits[i].hp > 0) {
			_partyDead = false;
			break;
		}
	}

	// Check if party dead
	var _enemiesDead = true;
	for(var i = 0; i < array_length(partyUnits); i++) {
		if(partyUnits[i].hp > 0) {
			_enemiesDead = false;
			break;
		}
	}
	
	// If either side is dead, end battle
	if(_partyDead or _enemiesDead) {
		instance_activate_all();
		
		// Save HP and MP to game
		for(var i = 0; i < array_length(partyUnits); i++) {
			oGame.party[i].hp = partyUnits[i].hp;
			oGame.party[i].mp = partyUnits[i].mp;
		}
		
		instance_destroy();
	}
	
	battleState = BattleStateTurnProgression;
}

// If battle shouldn't end, progress to next turn
function BattleStateTurnProgression() {
	battleText = "";
	turnCount++;
	turn++;
	// Loop back to start of turn order once done
	if (turn > array_length(unitTurnOrder) - 1) {
		turn = 0;
		roundCount++;
		RefreshTurnOrder();
	}
	battleState = BattleStateSelectAction;
}

battleState = BattleStateSelectAction;