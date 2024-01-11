// Run state machine
battleState();

// Cursor control
if (cursor.active) {
	with (cursor) {
		// Inputs
		var _keyUp = keyboard_check_pressed(vk_up);
		var _keyDown = keyboard_check_pressed(vk_down);
		var _keyLeft = keyboard_check_pressed(vk_left);
		var _keyRight = keyboard_check_pressed(vk_right);
		var _keyToggle = false;
		var _keyConfirm = false;
		var _keyCancel = false;
		
		confirmDelay++;
		// Test enter input after 1 frame
		if(confirmDelay > 1) {
			_keyConfirm = keyboard_check_pressed(vk_enter);
			_keyCancel = keyboard_check_pressed(vk_escape);
			_keyToggle = keyboard_check_pressed(vk_shift);
		}
		
		var _moveH = _keyRight - _keyLeft;
		var _moveV = _keyDown - _keyUp;
		if(_moveH == -1) targetSide = oBattle.partyUnits;
		if(_moveH == 1) targetSide = oBattle.enemyUnits;
		
		// Only select targets that are alive
		if (targetSide == oBattle.enemyUnits) {
			targetSide = array_filter(targetSide, function(_element, _index) {
				return _element.hp > 0;
			});
		}
		
		// Only allow moving between targets in single target mode
		if (targetAll == false) {
			if (_moveV == 1) targetIndex++;
			if (_moveV == -1) targetIndex--;
			
			// Wrap around
			var _targets = array_length(targetSide);
			if (targetIndex < 0) targetIndex = _targets - 1;
			if (targetIndex > (_targets - 1)) targetIndex = 0;
			
			// Find active target
			activeTarget = targetSide[targetIndex];
			
			// Switch to all mode
			if (activeAction.targetAll == MODE.VARIES && _keyToggle) {
				targetAll = true;	
			}
		// Target all mode
		} else {
			activeTarget = targetSide;
			
			// Switch to single target mode
			if (activeAction.targetAll == MODE.VARIES && _keyToggle) {
				targetAll = false;	
			}
		}
		
		// If hit enter, start action
		if (_keyConfirm) {
			with (oBattle) BeginAction(cursor.activeUser, cursor.activeAction, cursor.activeTarget);
			with (oMenu) instance_destroy();
			active = false;
			confirmDelay = 0;
		}
		// If hit cancel, open up menu and deactivate cursor
		else if (_keyCancel) {
			with (oMenu) active = true;
			active = false;
			confirmDelay = 0;
		}
		
	}
}