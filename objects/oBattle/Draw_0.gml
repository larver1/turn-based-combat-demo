/// @description Insert description here
// You can write your code in this editor

draw_sprite(battleBackground, 0, x, y);

// Draw units in depth order

// Get ID of unit with current turn
var _unitWithCurrentTurn = unitTurnOrder[turn].id;
for (var i = 0; i < array_length(unitRenderOrder); i++) {
	// Use 'with' to perform complex code actions on other instances
	with (unitRenderOrder[i]) {
		draw_self();
	}
}

// Draw UI
draw_sprite_stretched(sBox, 0, x + 75, y + 120, 245, 60);
draw_sprite_stretched(sBox, 0, x, y + 120, 74, 60);

// Positions
#macro COLUMN_ENEMY 15
#macro COLUMN_NAME 90
#macro COLUMN_HP 140
#macro COLUMN_MP 190
#macro COLUMN_STATUS 240

// Draw headings
draw_set_font(fnM3x6);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_gray);

draw_text(x + COLUMN_ENEMY, y + 120, "ENEMY");
draw_text(x + COLUMN_NAME, y + 120, "NAME");
draw_text(x + COLUMN_HP, y + 120, "HP");
draw_text(x + COLUMN_MP, y + 120, "MP");
draw_text(x + COLUMN_STATUS, y + 120, "STATUS");

// Draw enemy stats
draw_set_font(fnM5x7);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
var _drawLimit = 3;
var _drawn = 0;

// Only display up to 3 enemies at once
for (var i = 0; (i < array_length(enemyUnits)) && (_drawn < _drawLimit); i++) {
	var _char = enemyUnits[i];
	if (_char.hp > 0)
	{
		_drawn++;
		draw_set_halign(fa_left);
		draw_set_color(c_white);
		
		// Display enemy name, and highlight if current turn
		if (_char.id == _unitWithCurrentTurn) draw_set_color(c_yellow);
		draw_text(x + COLUMN_ENEMY, y + 130 + (i * 12), _char.name);
	}
}

// Draw party info
for (var i = 0; i < array_length(partyUnits); i++) {
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	
	var _char = partyUnits[i];
	
	// Display party member's name, and highlight if current turn
	if(_char.id == _unitWithCurrentTurn) draw_set_color(c_yellow);
	if(_char.hp <= 0) draw_set_color(c_red);
	draw_text(x + COLUMN_NAME, y + 130 + (i * 12), _char.name);
	
	// Display HP
	draw_set_halign(fa_right);
	draw_set_color(c_white);
	// Color is orange if low, red if 0
	if (_char.hp < (_char.hpMax * 0.5)) draw_set_color(c_orange);
	if (_char.hp <= 0) draw_set_color(c_red);
	draw_text(x + COLUMN_HP + 30, y + 130 + (i * 12), string(_char.hp) + "/" + string(_char.hpMax));
	
	// Display MP
	draw_set_color(c_white);
	// Color is orange if low, red if 0
	if (_char.mp < (_char.mpMax * 0.5)) draw_set_color(c_orange);
	if (_char.hp <= 0) draw_set_color(c_red);
	draw_text(x + COLUMN_MP + 30, y + 130 + (i * 12), string(_char.mp) + "/" + string(_char.mpMax));

	// Display Status
	draw_set_color(c_white);
	var _statusText = "NONE";
	var _statusEffects = BattleGetStatusText(_char);
	
	// Second has passed
	if(current_second != second) {
		if(array_length(_statusEffects) > 1) {
			if(_char.statuses.statusIndex >= array_length(_statusEffects) - 1) {
				_char.statuses.statusIndex = 0;	
			} else {
				_char.statuses.statusIndex++;	
			}
		};
		
	}
	
	if(array_length(_statusEffects) > 0)
		_statusText = _statusEffects[_char.statuses.statusIndex];

	draw_text(x + COLUMN_STATUS + 30, y + 130 + (i * 12), _statusText);
}

if(current_second != second) {
	second = current_second;	
}

// Draw target cursor
if (cursor.active) {
	with (cursor) {
		if (activeTarget != noone) {
			// If only one target, display one pointer on target
			if (!is_array(activeTarget)) {
				draw_sprite(sPointer, 0, activeTarget.x, activeTarget.y);	
			} else {
				// Flicker on and off
				draw_set_alpha(sin(get_timer() / 50000) + 1);
				// If multiple targets, draw a sprite on all
				for(var i = 0; i < array_length(activeTarget); i++) {
					draw_sprite(sPointer, 0, activeTarget[i].x, activeTarget[i].y);	
				}
				draw_set_alpha(1.0);
			}
		}
	}
}

// Draw battle text
if (battleText != "") {
	var _w = string_width(battleText) + 20;
	draw_sprite_stretched(sBox, 0, x + 160 - (_w * 0.5), y + 5, _w, 25);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_text(x + 160, y + 10, battleText);
}