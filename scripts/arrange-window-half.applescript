on run argv
	tell application "Finder"
		set screen_bounds to bounds of window of desktop
		set screen_width to item 3 of screen_bounds
		set screen_height to item 4 of screen_bounds
	end tell
	
	# Get position argument (default to "top" if not provided)
	if (count of argv) > 0 then
		set position_arg to item 1 of argv
	else
		set position_arg to "top"
	end if
	
	set max_laptop_width to 1800
	set min_widescreen_width to 3300
	
	set padding to 17
	
	if screen_width > max_laptop_width then
		# Monitor+
		set position_top to 31 + padding
		set full_height to screen_height - position_top - padding
	else
		# Laptop
		set position_top to 38 + padding # Account for The Notch.
		set full_height to screen_height - position_top - padding
	end if
	
	# Calculate half height accounting for the gap between windows
	# We want a 16px gap, so subtract 8px from each window (16/2)
	set half_height to (full_height - padding) / 2
	
	if screen_width > min_widescreen_width then
		# Widescreen+
		set center_width to screen_width * 0.46
		set window_size to {center_width, half_height}
	else if screen_width > max_laptop_width and screen_width < min_widescreen_width then
		# Monitor
		set center_width to screen_width * 0.6
		set window_size to {center_width, half_height}
	else
		# Laptop
		set center_width to screen_width - (padding * 2)
		set window_size to {center_width, half_height}
	end if
	
	# Set position based on argument
	if position_arg is "bottom" then
		# Position at bottom half with 16px gap from top window
		set window_position to {(screen_width - center_width) / 2, position_top + half_height + padding}
	else
		# Default to top half of usable area
		set window_position to {(screen_width - center_width) / 2, position_top}
	end if
	
	# Get the currently focused application and resize its front window
	tell application "System Events"
		set frontApp to name of first application process whose frontmost is true
		tell process frontApp
			if exists window 1 then
				set position of window 1 to window_position
				set size of window 1 to window_size
			end if
		end tell
	end tell
end run
