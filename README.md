Rock Dash

Started about 30 August 2020

Copyright:
Yoctoville - assets/aswitch.wav

ToDo:
1. When level is complete, don't show diamonds in stats message
2. Maybe have the bady do a big blow up is a switch pop up pops up on it
3. Maybe/hopefully have inbetween movements

Bugs:
1. Error when exiting

Fixed bugs (hopefully):
1. Can wipe out a rock on the bottom (maybe to do with diamond maker under there)
2. Rock missing after reload - was to do with position of player when reloading.

Remake of Rock Dash 5 (from Amstrad days)

Using Foxid layer: https://github.com/TodNaz/Foxid

Install:
You'll need to have Simple Direct Media Layer installed. Clone this and JMisc. Go into its root folder and run dub.
brew install dmd dub
brew install sdl2 sdl2_image sdl2_mixer sdl2_ttf

Keys:
E - to toggle from edit mode to game mode

Edit mode only:
B - change brush to what's in the cursor space
V - use brush (see green box bottom left)
Control+S - Save level
Control+L - Load level
Control+R - Rename level

Play mode only:
A - reload level (score and diamonds collected, get reset for that level)
Cursor keys - move Dasher
Return/Enter - In level completion, move onto next level (loops if you were on last level, and didn't start at the first level)

How to play:
Collect 10 diamonds to open the exit door.
The bady has to go directy at you to destroy you. So if you position yourself in the right places you can guide the bady to take different roots.
There is diamond makers, when you drop rocks into, but there has to be a gap underneath.
You clear away the mud to get to places, as well as guide the bady.
You can push rocks up, and push rocks diagonal left or right and down.
There can be a switch to trigger. The pop ups can blow up the bady, if it pops up on it. What the switch is done is worked out with the plot and what pops up, up to the right of the game screen.
You drop rocks onto the bady to blow holes in walls to get to diamonds and stuff.
The bady keeps respawning, if there's a bady maker, (it can be blown up, if the level allows it to be)

Trouble shooting:
To start game: Enter in eg. 'dub -- GameLearn 1 Joel' - name and start level, put your name instead of mine. It loops around, so you can still complete all the levels, in one game, even if you don't start on level 1.
When placing the start position (S), only have one, and save and load when you put it down.
When restarting a level, if there's something wrong, restart it again.
To add a comment to your score, edit halloffame.txt in the respective level set
