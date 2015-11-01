#DYFT App Architecture
##Screens

1. **AllQuakesMapViewController** ~~*QuakesVC*~~
    1. Opens to map view containing all quakes within 100 miles of user's location
        1. Limit to quakes that have occured during the past 3 months
    2. Left navBarButton switches to list view of all quakes within 100 miles of user's location (flip-screen-over-type animation?)
        1. ~~*Need to make an AllQuakesTableVC*~~
        2. User taps on left navBarButton calls method 'listViewButtonSelected:'
            1. Calls 'displayAllQuakesTableViewController' method
                1. Calls `[self showViewController:self.allQuakesTableViewController sender:self]` and then `[self.allQuakesTableViewController didMoveToParentViewController:self]`
    3. Right navBarButton displays a settingsVC that filters the quakes displayed ~~ONLY on the QuakesVC~~ on both the AllQuakesMapViewController as well as the AllQuakesTableViewController.
        1. The available filters and options are listed below in **User Configurable Settings**
        2. ~~*Need to make a QuakeSettingsVC and use it in both contexts*~~
    4. ~~_Need to rename this from QuakesVC to AllQuakesMapVC_~~
    5. Would **LOVE** to have an option to show (drop) pins on the map as an animation over a time period.
2. **AllQuakesTableViewController**
3. **FeltTableVC**
    1. Opens to list view of all quakes from any time in the past that the user has reported feeling (based on response to a DYFT? notification, which is sent out to users that are within X miles of the epicenter -- the number of miles is configurable and set by users in their notification settings)
    2. left navBarButton switches to a map view of the same Felt Quakes that are shown on the list view screen (flip-screen-over-type animation?)
        1. _**Need to make a FeltQuakesMapVC**_
    3. right navBarButton displays a settingsVC that filter the quakes displayed ONLY on the QuakesVC
        1. The available filters and options are listed below in **User Configurable Settings**
        2. _**Need to make a QuakeSettingsVC and use it in both contexts -- same as above**_
    4. Tapping on a tableViewCell pushes the **FeltMapVC**, which displays the locations of all of the users that reported feeling the same quake (might be a heatmap view controller if not simple pins)
    5. _~~Need to rename this from FeltTableVC to FeltQuakesTableVC~~_
    6. Would **LOVE** to have an option to show (drop) pins on the map as an animation over a time period.
4. **RegisterQuakeVC**
    1. Screen asks if the user wants to register an earthquake they felt
    2. If yes, it asks if they want to share this with any of their connected social media accounts
5. **HeatMapVC**
    1. Users can choose to show the quakes that have occured over 30 day increments and can choose if that is the past 30 days, the previous 30 days, etc.
    2. Would **LOVE** to animate this eventually.
6. **SettingsVC**
    1. This needs to be a tableViewController with multiple sections:
        1. Push Notifications
            1. Users can set the maximum distance away from their current location and the minimum magnitude required to receive a push notification from DYFT? alerting them of a recent earthquake. They also have the option of turning this type of notification off.
            2. Users can set the maximum distance away from their current location required to receive a push notification from DYFT? asking them if the felt a recent earthquake. They also have the option of turning this type of notification off.
        2. Profile
            1. User Name
            2. Email (required for login -- must be unique)
            3. Password
            4. User Picture (not required)
        5. Linked Accounts*
            1. Can then see different pins (colors?) for users they are friends with on social media that also felt the same earthquakes
        6. Disposal Wells
            1. Users can choose to overlay the maps with known disposal well locations
7. **NewsVC**
    1. *This will be added later.*
    2. Include any relevant USA-related (for now) earthquake news


##User Configurable Settings
####Filter Earthquakes Displayed on QuakesVC and FeltQuakesVC by...:
1. Date
    1. All days (begins April 14, 2015 -- currently what is saved on Parse database)
    2. 1 day
    3. 7 days (1 week)
    4. 30 days (1 month)
    5. 60 days (2 months)
2. Magnitude
    1. All Magnitudes
    2. 2.0 and higher
    3. .... 8.0 and higher
3. Distance from User's Location
    1. All Distances
    2. 50 miles
    3. 100 miles
    4. 150 miles
    5. 300 miles
    6. 500 miles
    7. 750 miles


