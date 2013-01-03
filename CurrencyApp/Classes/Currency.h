//
//  Currency.h
//  RssReader
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface Currency : NSObject {
	NSString *currency;
	NSString *title;
	NSString *date;
	NSString *USDratio;
}

@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *USDratio;

//Static methods.
+ (NSMutableArray *) getCurrency:(NSString *)dbPath;   // returns user specific 'currencies'
+ (NSMutableDictionary *) getAllCurrencies:(NSString *)dbPath;   // return all the currencyNames in the database
+ (void) addParsedCurrency:(Currency *)currencyObj atDBPath:(NSString *)dbPath;    // adds currency into the Parser-Database
+ (void) clearParsedDB:(NSString *)dbPath;
+ (void) clearUserDB:(NSString *)dbPath;
+ (Currency *) getCurrencyObject:(NSString *)currencyName atDBPath:(NSString *)dbPath; // returns the objecy for the currency name provided
+ (void) updateBaseCurrencyRatio:(NSString *)dbPath withRatio:(NSString *)ratio;  // takes care of the baseCurrency for the UserView
+ (void) finalizeStatements;

//Instance methods.
- (void) deleteCurrency:(NSString *)dbPath;    //deletes currency from the User-Database
- (void) addCurrency:(NSString *)dbPath;       //adds currency from the User-Database

@end