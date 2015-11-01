#DYFT Data Model Planning
* What basic objects will my application be using?
    - Users
    - Installations
    - UserEvents
    - USGSQuakes
* What is the relationship between the different object types—one-to-one, one-to-many, or many-to-many?
    - Users <-||----------++-> UserEvents (1 User can have many UserEvents, and 1 UserEvent can have only 1 User)
    - Users <-||----------++-> Installations (1 User can have many Installations, and 1 Installation can have only 1 User)
* How often will new objects be added to the database?
* How often will objects be deleted from the database?
* How often will objects be changed?
* How often will objects be accessed?
* How will objects be accessed—by ID, property values, comparisons, or other?
* How will groups of object types be accessed—common ID, common property value, or other?

##Questions & Ops the DYFT app currently asks & performs:

####AppDelegate
1. -(void)handleDidntFeelItActionWithRemoteNotification
    1. Find USGSQuakes where the "usgsId" is equal to [quakeId].  
        1. Increment the "appNotFelt" key
        2. Add currentUser to the "notFeltByUsers" relation
        3. Save the USGSQuake in the background
2. -(void)handleFeltItActionWithRemoteNotification
    1. Find USGSQuakes where the "usgsId" is equal to [quakeId].
        1. Increment the "appFelt" key
        2. Add currentUser to the "feltByUsers" relation
        * Save the USGSQuake in the background
    2. Create new userEvent
        1. set currentUser to the userEvent's "user"
        2. set the user's current location as "userLocation"
        3. set "eventFound" to YES
        4. saveInBackground
    3. currentInstallation   
    **{{{{ DO NOT NEED THIS UNLESS PUBNUB IS USED IN A LATER RELEASE -- ALSO GETS OVERWRITTEN BY sendSavedUserPrefsToCloud _(below)_}}}}**
        1. addUniqueObject: quakeID to "channels"
        2. saveInBackground
3. -(void)application:didFinishLaunchingWithOptions:  *{ clears badge number }*
    1. saveInBackground currentInstallation
4. -(void)applicationDidBecomeActive:  *{ clears badge number }*
    1. saveInBackground currentInstallation
5. -(void)sendSavedUserPrefsToCloud
    1. currentInstallation 
        1. set "maxDistance"
        2. set "nearbyQuakes"  
        3. set "minMagnitude"  
        4. set "channels"
        5. saveInBackground
6. -(void)application:didRegisterForRemoteNotificationsWithDeviceToken:
    1. currentInstallation
        1. set currentUser as "user"  
        2. set deviceToken  
        3. saveInBackground

####DYFTComms
1. +(void)login:
    1. Fetch currentUser's <FBGraphUser> dictionary (*me) from Facebook
        2. set currentUser's "fbId" as me.objectID from the dictionary
        3. save in background

####FeltMapVC
1. - (void)updateLocations
    2. Using a USGSQuakes object, find all "relatedUserEvents"
        3. findObjectInBackgroundWithBlock

####FeltTableVC
1. -(PFQuery *)queryForTable
    1. Find USGSQuakes where currentUser is containedIn "feltByUsers" array key
        1. Sort createdAt in descending order

####HeatMapViewController
1. -(void)viewDidLoad
    1. Find USGSQuakes where the "place" key contains the string [state string]
        1. where the "timestamp" key is greaterThanOrEqualTo [date in past (currently using oneMonthAgoDate)]
        2. sort by "timestamp" in descending order
        3. select only the keys: "place", "timestamp", "location", "title"
        4. limit result to 1000
    2. Find USGSQuakes where the "place" key contains the string [state string]
        1. where the "timestamp" key is greaterThanOrEqualTo [date in past (currently using twoMonthsAgoDate)]
        2. where the "timestamp" key is lessThan [more recent date in the past (current using oneMonthAgoDate)]
        3. sort by "timestamp" in descending order
        4. select only the keys: "place", "timestamp", "location", "title"
        5. limit result to 1000
    3. Find USGSQuakes where the "place" key contains the string [state string]
        1. where the "timestamp" key is greaterThanOrEqualTo [date in past (currently using threeMonthsAgoDate)]
        2. where the "timestamp" key is lessThan [more recent date in the past (current using twoMonthsAgoDate)]
        3. sort by "timestamp" in descending order
        4. select only the keys: "place", "timestamp", "location", "title"
        5. limit results to 1000

####QuakeRegisterVC
1. -(IBAction)registerQuake:
    1. After creating and setting all fields on a new UserEvent object:
        1. saveInBackgroundWithBlock  

####QuakesTableVC
1. -(PFQuery *)queryForTable
    1. Find USGSQuakes where currentUser is containedIn "feltByUsers" array key
        1. Sort createdAt in descending order

####QuakesVC
1. -(void)fetchQuakeData --called from viewDidLoad   
**{{{{duplicate of QV2!}}}}**
    1. **QV1** - Find USGSQuakes where the "feltByUsers" key equals the currentUser 
        1. limit results to 1000
        2. findObjects
2. -(void)locationManager:didUpdateLocations:
    1. Get the user's currentLocationInBackground
        1. set currentInstallation's "location"
        2. saveInBackground
3. -(void)viewWillAppear:(BOOL)animated   
**{{{{need to delete this QV1 duplicate!}}}}**
    1. **QV2** - Find USGSQuakes where the "feltByUsers" key equals the currentUser
        1. limit results to 1000
        2. findObjectsInBackgroundWithBlock
    2. Find USGSQuakes where the "notFeltByUsers" key equals the currentUser
        1. limit results to 1000
        2. findObjectsInBackgroundWithBlock
4. -(void)updateLocations
    1. Find USGSQuakes where the "state" key equals   
    *[state string (currently hardcoded to 'Oklahoma')]*
    2. sort by "createdAt" in descending order
    3. limit results to 500 
    4. findObjectsInBackgroundWithBlock

####UserCreateNewVC
1. -(void)processFieldEntries
    1. Create new user with username and two password fields (one to enter pw again to verify correct)
        1. signUpInBackgroundWithBlock

####UserLoginVC
1. -(void)processFieldEntries
    1. loginWithUsernameInBackground:password:block 


Questions the DYFT app will ask a lot:

1. 
