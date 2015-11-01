###App Launch (User Not Logged In)
-  Running **AppDelegate** 'application:didFinishLaunchingWithOptions:'
    -  Running **GroupsView** 'initWithNibName:bundle:'
    -  Running **MessagesView** 'initWithNibName:bundle:'
    -  Running **ProfileView** 'initWithNibName:bundle:'
    -  [HockeySDK] WARNING: Detecting crashes is NOT enabled due to running the app with a debugger attached.    
    -  Running **MessagesView** 'viewDidLoad'    
        **_called here because the tabbarcontroller's selectedIndex is set to 1 (the index of the Messages View)_**
-  Running **AppDelegate** 'applicationDidBecomeActive:'
-  Running **MessagesView** 'viewDidAppear:'
    -  Running **utilities.m** LoginUser:
-  Running **AppDelegate** 'application:didRegisterForRemoteNotificationsWithDeviceToken:'
-  Running **WelcomeView** 'viewDidLoad'    
   **_Welcome View controller created and presented from utilities.m's LoginUser:_**

###User Tapped 'Login' & Entered Credentials
-  Running **WelcomeView** 'actionLogin:'
    -  Running **LoginView** 'viewDidLoad'
    -  Running **LoginView** 'tableView:cellForRowAtIndexPath:' x 3
-  Running **LoginView** 'viewDidAppear:'
    -  Running **LoginView** 'actionLogin:'
        -  Running **pushnotification.m** ParsePushUserAssign:
-  Running **MessagesView** 'viewDidAppear:'    
    **_called here because the Login View was dismissed and tabbarcontroller's selectedIndex was set to 1 in the App Delegate (the index of the Messages View)_**
-  Running **MessagesView** 'loadMessages'
    -  Running **MessagesView** 'updateEmptyView'
    -  Running **MessagesView** 'updateTabCounter'
-  Running **MessagesCell** 'bindData:' x 4   
   **_called from Messages View's cellForRowAtIndexPath: method_**
    -  Running **utilities.m** TimeElapsed: x 4 (alternating with bindData:)

###App Launch (User Logged In Already)
-  Running **AppDelegate** 'application:didFinishLaunchingWithOptions:'
-  Running **GroupsView** 'initWithNibName:bundle:'
-  Running **MessagesView** 'initWithNibName:bundle:'
-  Running **ProfileView** 'initWithNibName:bundle:'
-  [HockeySDK] WARNING: Detecting crashes is NOT enabled due to running the app with a debugger attached.
-  Running **MessagesView** 'viewDidLoad'
-  Running **MessagesView** 'viewDidAppear:'
-  Running **MessagesView** 'loadMessages'
-  Running **AppDelegate** 'application:didRegisterForRemoteNotificationsWithDeviceToken:'
-  Running **MessagesView** 'updateEmptyView'
-  Running **MessagesView** 'updateTabCounter'
-  Running **AppDelegate** 'applicationDidBecomeActive:'
-  Running **MessagesCell** 'bindData:' x 4
-  Running **utilities.m** TimeElapsed: x 4 (alternating with bindData:)

###User (On 'Messages' Tab After App Launch) Tapped On MessagesCell
-  Running **MessagesView** 'tableView:didSelectRowAtIndexPath:'
-  Running **MessagesView** 'actionChat:'
-  Running **ChatView** 'initWith:'
-  Running **ChatView** 'viewDidLoad'
-  Running **ChatView** 'loadMessages'
-  Running **messages.m** ClearMessageCounter:
-  Running **ChatView** 'viewDidAppear:'
-  Running **ChatView** 'addMessage:' x 3
-  Running **ChatView** 'loadMessages'

###User Created New Message & Sent To Group, Then Hit Back Button To Go Back To Main Messages View
-  Running **ChatView** 'loadMessages'
-  Running **ChatView** 'didPressSendButton:withMessageText:senderId:senderDisplayName:date:'
-  Running **ChatView** 'sendMessage:Video:Picture:'
-  Running **pushnotification.m** SendPushNotification:
-  Running **messages.m** UpdateMessageCounter:
-  Running **ChatView** 'loadMessages'
-  Running **ChatView** 'addMessage:'
-  Running **ChatView** 'loadMessages' x 2
-  Running **ChatView** 'viewWillDisappear:'
-  Running **MessagesView** 'viewDidAppear:'
-  Running **MessagesView** 'loadMessages'
-  Running **MessagesView** 'updateEmptyView'
-  Running **MessagesView** 'updateTabCounter'
-  Running **MessagesCell** 'bindData:' x 2
-  Running **utilities.m** TimeElapsed:  x 2 (alternating with bindData:)

###User Tapped On A Single Group And Went To That Group's Messages
-  Running **GroupsView** 'viewDidLoad'
-  Running **GroupsView** 'viewDidAppear:'
-  Running **GroupsView** 'loadGroups'
-  Running **utilities.m** TimeElapsed: x 6
-  Running **GroupsView** 'tableView:didSelectRowAtIndexPath:'
-  Running **messages.m** CreateMessageItem:
-  Running **ChatView** 'initWith:'
-  Running **ChatView** 'viewDidLoad'
-  Running **ChatView** 'loadMessages'
-  Running **messages.m** ClearMessageCounter:
-  Running **ChatView** 'addMessage:' x 19
-  Running **ChatView** 'viewDidAppear:' x 5

###User Tapped Back Button To Go Back To GroupsView
-  Running **ChatView** 'viewWillDisappear:'
-  Running **GroupsView** 'viewDidAppear:'
-  Running **GroupsView** 'loadGroups'
-  Running **utilities.m** TimeElapsed: x 6

###User Tapped On 'Profile' Tab
-  Running **ProfileView** 'viewDidLoad'
-  Running **ProfileView** 'tableView:cellForRowAtIndexPath:' x 2
-  Running **ProfileView** 'viewDidAppear:'
-  Running **ProfileView** 'loadUser'

###User Logged Out
-  Running **ProfileView** 'actionLogout'
-  Running **ProfileView** 'actionSheet:clickedButtonAtIndex:'
-  Running **pushnotification.m** ParsePushUserResign:
-  Running **utilities.m** PostNotification:
-  Running **MessagesView** 'actionCleanup'
-  Running **ProfileView** 'actionCleanup'
-  Running **utilities.m** LoginUser:
-  Running **WelcomeView** 'viewDidLoad'

###User Tapped Digits Button To Login
-  Running **WelcomeView** 'actionDigits:'
-  Can't find keyplane that supports type 4 for keyboard iPhone-Portrait-NumberPad; using 1730230351_Portrait_iPhone-Simple-Pad_Default
-  Digits error: Error Domain=TwitterAPIErrorDomain Code=239 "Request failed: forbidden (403)" UserInfo=0x17427f2c0 {NSErrorFailingURLKey=https://api.twitter.com/1.1/device/register.json, NSLocalizedDescription=Request failed: forbidden (403), NSLocalizedFailureReason=Twitter API error : Bad guest token. (code 239)}
-  Can't find keyplane that supports type 4 for keyboard iPhone-Portrait-NumberPad; using 1730230351_Portrait_iPhone-Simple-Pad_Default x 2
-  Running **AppDelegate** 'applicationWillResignActive:'
-  Running **AppDelegate** 'applicationDidEnterBackground:'
-  Running **AppDelegate** 'applicationWillEnterForeground:'
-  Running **AppDelegate** 'applicationDidBecomeActive:'
-  Session returned authToken: 3118754762-2M6CQZ3YCSNqdW36bCd6Il2UhLAlcepeOVn5z6X, authTokenSecret: Qe8ttJnDVAGYyRoENGAPdzcDy9U0P7pL8gzhDiur1BcFe, userID: 3118754762, phoneNumber: +14052096598

###User Tapped 'Login' Button, Entered Email & Password, Then Tapped Login Button To Submit Credentials And Login
-  Running **WelcomeView** 'actionLogin:'
-  Running **LoginView** 'viewDidLoad'
-  Running **LoginView** 'tableView:cellForRowAtIndexPath:' x 3
-  Running **LoginView** 'viewDidAppear:'
-  plugin com.linecorp.LineEmoji.KeyboardExtension invalidated
-  Running **LoginView** 'actionLogin:'
-  Running **pushnotification.m** ParsePushUserAssign:
-  Running **ProfileView** 'viewDidAppear:'
-  Running **ProfileView** 'loadUser'
