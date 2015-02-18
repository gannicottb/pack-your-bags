# pack-your-bags
Course project for CMU iOS Game Development Course

Objective

You're heading off on your next big trip, and it's time to pack your bags! Drag and drop your items into the bag - they'll all fit if you're clever! The plane/train/boat leaves soon, so you've got to hurry! 

Game Mechanics

Players drag items from the right into the "Bag" on the left. The "Bag" is a grid of squares, and the "Items" are all laid out in squares. Items must be placed in valid locations (not overlapping other items or the borders of the bag). The items can be rotated on 90 degree increments and moved again once placed into the bag. Each level is timed. Once all the items have been placed OR the time runs out, the top of the bag closes and the user is given their score (based on completion of their packing and time taken)

Level Design

Each level is themed based on your destination (Train to Moscow, Boat to Hawaii, Plane to Paris, etc)
Each level is based on figuring out how the items fit into the bag. Difficulty can be raised by strangely shaped items and bulky items. A simple level would be a 6x4 bag with 3 2x4 items. The solution is to line them up next to each other.

Technical
---------

Scenes

* Start screen 
* Level(Trip) Select
* Gameplay
* Level results

Controls

* Touch - drag 'n' drop item into bag
* Two-finger twist - rotate items in the bag

Classes

* Item
* Bag 
* Lid?
* Item tray

Milestones
----------

Week 1 (2/17)
Completed GDD (this document)

Week 2 (2/24)
Playable build of Pack Your Bags!