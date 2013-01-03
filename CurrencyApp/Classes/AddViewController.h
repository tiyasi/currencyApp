//
//  AddViewController.h
//  RssReader
//

#import <UIKit/UIKit.h>
#import "RssReaderAppDelegate.h"

@class Currency;

@interface AddViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	
	RssReaderAppDelegate *appDelegate;
	NSMutableString *currencyName;
	NSMutableDictionary *names; 
	NSArray	*keys;
}

@property (nonatomic, retain) NSMutableDictionary *names; 
@property (nonatomic, retain) NSArray *keys; 
@property (nonatomic, retain) NSMutableString *currencyName;

@end
