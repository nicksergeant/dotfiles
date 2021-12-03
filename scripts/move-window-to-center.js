// Menu: Move window to center
// Description: Move the active app's window to the center of the screen
// Author: Nick Sergeant
// Twitter: @nicksergeant
// Shortcut: cmd option control up

import "@johnlindquist/kit";

const MENU_BAR_HEIGHT = 25;

const { workArea: screen } = await getActiveScreen();
const window = await getActiveAppBounds();

const windowHeight = window.bottom - window.top;
const windowWidth = window.right - window.left;

setActiveAppBounds({
  top: (screen.height - windowHeight) / 2 + MENU_BAR_HEIGHT,
  left: (screen.width - windowWidth) / 2,
});
