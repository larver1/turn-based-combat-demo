if (active) {
	hover += keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
	
	// If cursor hits either end, loop back around
	if (hover > array_length(options) - 1) hover = 0;
	if (hover < 0) hover = array_length(options) - 1;
	
	// Execute selected option
	if (keyboard_check_pressed(vk_enter)) {
		// If option is more than text entry, and option is available
		if (struct_exists(options[hover], "available") and options[hover].available) {
			// If option has a function, run it
			if (options[hover].func != -1) {
				var _func = options[hover].func;
				// script_execute_ext() allows passing of array of arguments to a function
				if (options[hover].args != -1) script_execute_ext(_func, options[hover].args);
				else _func();
			}
		}
	}
	
	// Go back up a level
	if (keyboard_check_pressed(vk_escape)) {
		if (subMenuLevel > 0) MenuGoBack();
	}
}