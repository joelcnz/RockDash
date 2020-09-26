Rock Dash

ToDo:
1. When level is complete, don't show diamonds in stats message
2. Maybe have the bady do a big blow up is a switch pop up pops up on it
3. Maybe/hopefully have inbetween movements

Bugs:
1. A rock popped up after loading level and went through a diamond maker.

Fixed bugs (hopefully):
1. Can wipe out a rock on the bottom (maybe to do with diamond maker under there)
2. Rock missing after reload - was to do with position of player when reloading.

Remake of Rock Dash 5 (from Amstrad days)

Using Foxid layer: https://github.com/TodNaz/Foxid

Install:
You'll need to have Simple Direct Media Layer installed. Clone this and JMisc. Go into its root folder and run dub.

Keys:
E - to toggle from edit mode to game mode

Edit mode only:
B - change brush to what's in the cursor space
V - use brush (see green box bottom left)
S - Save level
L - Load level

Play mode only:
A - reload level (score gets reset for that level)
Cursor keys - move Dasher
Return/Enter - In level completion, move onto next level (loops if you were on last level)

Trouble shooting:
To start game: Enter in eg. 'dub -- Joel 1' - name and start level. It loops around, so you can still complete all the levels - even if you don't start on level 1.
When placing the start position (S), only have one, and save and load when you put it down.
When restarting a level, if there's something wrong, restart it again.
To add a comment to your score, edit halloffame.txt
