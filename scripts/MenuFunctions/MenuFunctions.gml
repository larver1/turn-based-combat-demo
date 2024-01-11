function Menu(_x, _y, _options, _description = -1, _width = undefined, _height = undefined) {
	with (instance_create_depth(_x, _y, -99999, oMenu)) {
		options = _options;
		description = _description;
		var _optionsCount = array_length(_options);
		visibleOptionsMax = _optionsCount;
		
		xmargin = 10;
		ymargin = 8;
		draw_set_font(fnM5x7);
		heightLine = 12;
		
		if(_width == undefined) {
			width = 1;
			// Will be as wide as longest string in menu
			if(description != -1) width = max(width, string_width(_description));
			for(var i = 0; i < _optionsCount; i++) {
				width = max(width, string_width(_options[i].name));	
			}
			// Add margin
			widthFull = width + xmargin * 2;
		} else {
			widthFull = _width;	
		}
		
		if (_height == undefined) {
			// Will be as long as number of options multiplied by constant
			height = heightLine * (_optionsCount + (description != -1));
			heightFull = height + ymargin * 2;
		} else {
			heightFull = _height;
			// Check if too big to store everything
			if (heightLine * (_optionsCount + (description != -1)) > _height - (ymargin * 2)) {
				scrolling = true;
				visibleOptionsMax = (_height - ymargin * 2) div heightLine;
			}
		}
	}
}

function SubMenu(_options) {
	// Store old options in array and increase submenu level
	optionsAbove[subMenuLevel] = options;
	subMenuLevel++;
	options = _options;
	hover = 0;
}

function MenuGoBack() {
	subMenuLevel--;	
	options = optionsAbove[subMenuLevel];
	hover = 0;
}

function MenuSelectAction(_user, _action) {
	// Hide menu
	with (oMenu) active = false;
	
	// Activate target if needed
	with (oBattle) {
		if(_action.targetRequired) {
			with (cursor) {
				active = true;
				activeAction = _action;
				targetAll = _action.targetAll;
				if (targetAll == MODE.VARIES) targetAll = true;
				activeUser = _user;
				
				// Which side to target by default
				if(_action.targetEnemyByDefault) {
					targetIndex = 0;
					targetSide = oBattle.enemyUnits;
					activeTarget = oBattle.enemyUnits[targetIndex];
				} else {
					// Else hover over yourself by default
					targetSide = oBattle.partyUnits;
					activeTarget = activeUser;
					var _findSelf = function(_element) {
						return (_element == activeTarget);	
					}
					targetIndex = array_find_index(oBattle.partyUnits, _findSelf);
				}
			}
		} else {
			// If no target needed, begin action and end menu
			BeginAction(_user, _action, -1);
			with (oMenu) instance_destroy();
		}
	}
	
}