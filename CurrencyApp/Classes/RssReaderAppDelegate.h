//
//  RssReaderAppDelegate.h
//  RssReader
//

#import <UIKit/UIKit.h>

@class Currency;

@interface RssReaderAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	NSString *dbPath;
	NSMutableArray *currencyArray, *userCurrencies;
	NSString *baseCurrency;
	Currency *baseCurrencyObj;
	NSInteger *count;      // for keeping the count of the times the app was refreshed, after loading the app
	NSInteger autoRefreshInterval;
}

@property (retain, nonatomic) Currency *baseCurrencyObj;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) NSMutableArray *currencyArray, *userCurrencies;
@property (nonatomic, retain) NSString *baseCurrency, *dbPath;
@property (assign) NSInteger *count;
@property (assign) NSInteger autoRefreshInterval;

- (void) removeCurrency:(Currency *)currencyObj;
- (void) insertCurrency:(Currency *)currencyObj;
//- (void) setAutoRefreshInterval;

@end

