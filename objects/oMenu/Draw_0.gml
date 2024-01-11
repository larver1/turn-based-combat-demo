draw_sprite_stretched(sBox, 0, x, y, widthFull, heightFull);
draw_set_color(c_white);
draw_set_font(fnM5x7);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _desc = description != -1;

// Calculate what index the first visible option will be
// The more you scroll down, the higher the index goes up from 0
var _scrollPush = max(0, hover - (visibleOptionsMax - 1));

for (l = 0; l < (visibleOptionsMax + _desc); l++) {
	// If number of remaining options is less than number of visible that can be shown
	if (l >= array_length(options)) break;
	
	draw_set_color(c_white);
	
	// If description, display it
	if (l == 0 && _desc) {
		draw_text(x + xmargin, y + ymargin, description);	
	} else {
		// Calculate index of option to show
		var _optionToShow = l - _desc + _scrollPush;
		// Name of action
		var _action = options[_optionToShow];
		var _str = options[_optionToShow].name;
		// If being hovered, highlight it
		if (hover == _optionToShow - _desc) {
			draw_set_color(c_yellow);
		}
		// If action unavailable, grey out
		if (!options[_optionToShow].available) draw_set_color(c_gray);
		
		draw_text(x + xmargin, y + ymargin + l * heightLine, _str);
	}
}

// Show pointer to hovered option
draw_sprite(sPointer, 0, x + xmargin + 8, y + ymargin + ((hover - _scrollPush) * heightLine) + 7);

// If more items to show, show a down arrow
if (visibleOptionsMax < array_length(options) && hover < array_length(options) - 1) {
	draw_sprite(sDownArrow, 0, x + widthFull * 0.5, y + heightFull - 7);	
}