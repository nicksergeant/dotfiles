# shows all url+titles of Chrome along with front window+tab url+title
set titleString to ""

tell application "Chromium"
	set the_url to the URL of active tab of front window # grab the URL
	set the_title to the title of active tab of front window # grab the title
	set titleString to titleString & the_title & "
" & the_url & "
" # concatenate
	set the clipboard to titleString
end tell
