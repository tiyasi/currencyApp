//
//  RootViewController.h
//  RssReader
//

#import <UIKit/UIKit.h>
#import "RssReaderAppDelegate.h"

@class Currency, AddViewController;

@interface RootViewController : UITableViewController <UIActionSheetDelegate> {
	
	RssReaderAppDelegate *appDelegate;
	AddViewController *avController;
	UINavigationController *addNavigationController;
	
  	UIActivityIndicatorView *activityIndicator;
  	NSMutableArray *items;
	BOOL isBaseDefault;
	BOOL baseCurrencyChanged;
}

@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) NSMutableArray *items;
@property (nonatomic, readwrite) BOOL isBaseDefault, baseCurrencyChanged;

- (void) loadData;
- (void) add_Clicked;
- (void) refreshData;

@end

