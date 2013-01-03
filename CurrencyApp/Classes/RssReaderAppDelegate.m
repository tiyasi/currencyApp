//
//  RssReaderAppDelegate.m
//  RssReader
//

#import "RssReaderAppDelegate.h"
#import "RootViewController.h"
#import "Currency.h"

@implementation RssReaderAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize currencyArray;
@synthesize userCurrencies;
@synthesize baseCurrency;
@synthesize baseCurrencyObj;
@synthesize count;
@synthesize dbPath;
@synthesize autoRefreshInterval;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	
	//set the dbPath
	dbPath = [[NSString alloc] initWithString:@"/Users/Tiyasi/Documents/T/Documents/My-Github/currencyApp/CurrencyApp/CurrencyApp.sqlite"];
	
	self.autoRefreshInterval =	100;
	NSLog(@"auto : %d", autoRefreshInterval);
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (void) removeCurrency:(Currency *)currencyObj { 
	//Delete it from the User-database.
	[currencyObj deleteCurrency:dbPath];
	
	//Remove it from both the arrays.
	[currencyArray removeObject:currencyObj];
	[userCurrencies removeObject:currencyObj.currency];
}

- (void) insertCurrency:(Currency *)currencyObj {
	
	//Add it to the User-database.
	[currencyObj addCurrency:dbPath];
	
	//Add it to both the arrays.
	[currencyArray addObject:currencyObj];
	[userCurrencies addObject:currencyObj.currency];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[baseCurrency release];
	[baseCurrencyObj release];
	[currencyArray release];
	[userCurrencies release];
	[dbPath release];
	[super dealloc];
}


@end

