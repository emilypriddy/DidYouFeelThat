##Protocols in DYFT


**QuakesTableViewController**
1. `- (CLLocation *)currentLocationForQuakesTableViewController:(QuakesTableViewController *)controller`
    1. QuakesMapViewController.m

**AllQuakesTableViewController**
1. `- (CLLocation *)currentLocationForAllQuakesTableViewController:(AllQuakesTableViewController *)controller`
    1. AllQuakesMapViewController.m

**QuakeRegisterVC**
1. `- (CLLocation *)currentLocationForRegisterQuakeViewController:(QuakeRegisterVC *)controller`
    1. AllQuakesMapViewController.m
    2. DYFTMainTabBarController.m
    3. QuakesMapViewController.m

**SetupViewController**
1. `- (void)setupViewController:(SetupViewController *)controller didFinishSetupWithInfo:(NSDictionary *)setupInfo`
    1. AppDelegate.m
2. `- (void)setupViewControllerDidLogout:(SetupViewController *)controller`
    1. AppDelegate.m

**DYFTComms**
1. `- (void)dyftCommsDidLogin:(BOOL)loggedIn`
    1. 



