property should_focus : false
property reopen_ignore : {"Finder", "Raycast"}

on resize_app_window(app_name, win_position, win_size)
	if application app_name is running then
		if my should_focus and app_name is not in my reopen_ignore then
			tell application app_name to reopen
		end if
		if my should_focus then
			tell application "System Events" to tell process app_name
				set frontmost to true
			end tell
			delay 0.05
		end if
		tell application "System Events" to tell process app_name
			set position of (every window) to {item 1 of win_position, item 2 of win_position}
			set size of (every window) to {item 1 of win_size, item 2 of win_size}
		end tell
	end if
end resize_app_window

on run argv
	# Check for --focus flag
	repeat with arg in argv
		if arg as text is "--focus" then set my should_focus to true
	end repeat

	# Remember which app is currently focused
	set originalApp to ""
	if should_focus then
		tell application "System Events"
			set originalApp to name of first application process whose frontmost is true
		end tell
	end if

	tell application "Finder"
		set screen_bounds to bounds of window of desktop
		set screen_width to item 3 of screen_bounds
		set screen_height to item 4 of screen_bounds
	end tell
	
	set max_laptop_width to 1800
	set min_widescreen_width to 3300
	
	set padding to 16
	
	if screen_width > max_laptop_width then
		# Monitor+
		set position_top to 31 + padding
		set full_height to screen_height - position_top - padding
	else
		# Laptop
		set position_top to 34 + padding # Account for The Notch.
		set full_height to screen_height - position_top - padding
	end if
	
	set one_third_height to full_height * 0.35
	set half_height to full_height / 2
	set two_thirds_height to full_height * 0.74
	
	if screen_width > min_widescreen_width then
		# Widescreen+
		set center_width to screen_width * 0.46
		set bottom_left_position to {padding, screen_height - one_third_height}
		set bottom_left_size to {(screen_width - center_width) / 2 - padding - padding, one_third_height - padding}
		set thin_left_size to {600, two_thirds_height}
	else if screen_width > max_laptop_width and screen_width < min_widescreen_width then
		# Monitor
		set center_width to screen_width * 0.6
		set bottom_left_position to {padding, screen_height - one_third_height}
		set bottom_left_size to {600, one_third_height - padding}
		set thin_left_size to {600, two_thirds_height}
	else
		# Laptop
		set center_width to screen_width - (padding * 2)
		set half_width to center_width / 2
		set bottom_left_position to {padding, screen_height - half_height - 1}
		set bottom_left_size to {half_width - 9, half_height - padding}
		set thin_left_size to {600, full_height}
	end if
	
	set center_position to {(screen_width - center_width) / 2, position_top}
	set center_half_position to {(screen_width - center_width) / 2, position_top + half_height}
	set center_size to {center_width, full_height}
	set narrow_half_size to {center_width, two_thirds_height}
	set thin_left_position to {padding, position_top}
	
	resize_app_window("1Password", center_position, center_size)
	resize_app_window("Calendar", center_position, center_size)
	resize_app_window("Chrome", center_position, center_size)
	resize_app_window("Claude", center_position, center_size)
	resize_app_window("Google Ads Editor", center_position, center_size)
	resize_app_window("iA Writer", center_position, center_size)
	resize_app_window("Missive", center_position, center_size)
	resize_app_window("Music", center_position, center_size)
	resize_app_window("NetNewsWire", center_position, center_size)
	resize_app_window("Photos", center_position, center_size)
	resize_app_window("Pixelmator Pro", center_position, center_size)
	resize_app_window("RadarScope", center_position, center_size)
	resize_app_window("Raycast", center_position, center_size)
	resize_app_window("Safari", center_position, center_size)
	resize_app_window("Spotify", center_position, center_size)
	resize_app_window("Weather", center_position, center_size)
	resize_app_window("zoom.us", center_position, narrow_half_size)
	
	resize_app_window("Finder", bottom_left_position, bottom_left_size)
	resize_app_window("TextEdit", bottom_left_position, bottom_left_size)
	
	resize_app_window("Ivory", thin_left_position, thin_left_size)
	resize_app_window("Messages", thin_left_position, thin_left_size)
	
	if screen_width > min_widescreen_width then
		# Widescreen
		resize_app_window("Slack", center_position, narrow_half_size)
		resize_app_window("Things", center_position, narrow_half_size)
	else if screen_width > max_laptop_width and screen_width < min_widescreen_width then
		# Monitor
		resize_app_window("Slack", center_position, narrow_half_size)
		resize_app_window("Things", center_position, narrow_half_size)
	else
		# Laptop
		resize_app_window("Slack", center_position, center_size)
		resize_app_window("Things", center_position, center_size)
	end if
	
	if should_focus then
		# Hide all other apps, then refocus the originally focused app
		tell application "System Events"
			set allProcesses to every process whose visible is true and name is not originalApp and name is not "Finder"
			repeat with proc in allProcesses
				set visible of proc to false
			end repeat
			set visible of every process whose name is "alacritty" to false
		end tell
		tell application "System Events" to tell process originalApp
			set frontmost to true
		end tell
	end if
end run

