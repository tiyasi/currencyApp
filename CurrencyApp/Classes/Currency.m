//
//  Currency.m
//  RssReader
//

#import "Currency.h"
#import "RssReaderAppDelegate.h"

@implementation Currency

static sqlite3 *database = nil;
static sqlite3_stmt *addStmt, *addStatement, *dltStmt, *getStmt, *updateStmt = nil;

@synthesize currency, title, date, USDratio;

// clearing the database to store the latest data, each time a new refresh call is made or app is started
+ (void) clearParsedDB:(NSString *)dbPath {

	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		NSString *dltquery = @"delete from Currency where rowid>0";
		char *errorMsg;
		
		if(sqlite3_exec(database, [dltquery UTF8String], nil, nil, &errorMsg) == SQLITE_OK) {
			
			NSLog(@"Database cleared! \n Storing refreshed data =>");
		}
	}
	else
		sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
}

+ (void) clearUserDB:(NSString *)dbPath {
	
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		NSString *dltqry = @"delete from currencies where rowid>0";
		char *errorMsg;
		
		if(sqlite3_exec(database, [dltqry UTF8String], nil, nil, &errorMsg) == SQLITE_OK) {
			
			NSLog(@"UserDatabase cleared!");
		}
	}
	else
		sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
}


+ (NSMutableArray *) getCurrency:(NSString *)dbPath {
	
	NSMutableArray *currencies = [[NSMutableArray alloc] init];
	
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		NSString *query = @"select * from currencies";
		sqlite3_stmt *statement;
		if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
			
			while(sqlite3_step(statement) == SQLITE_ROW && (sqlite3_column_text(statement, 0) != nil)) {

				NSString *currency = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
				[currencies addObject:currency];
			}
			sqlite3_finalize(statement);
		}
	}
	else
		sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
	return currencies;
	[currencies release];
}

+ (NSMutableDictionary *) getAllCurrencies:(NSString *)dbPath {
	
	NSMutableDictionary *currencyNames = [[NSMutableDictionary alloc] init];
	
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		NSString *query = @"select currency from Currency";
		sqlite3_stmt *stmt;
		if(sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) == SQLITE_OK) {
			
			while(sqlite3_step(stmt) == SQLITE_ROW && (sqlite3_column_text(stmt, 0) != nil)) {
				
				NSString *currencyName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
				NSString *key = [[NSString alloc] initWithString:[currencyName substringToIndex:1]];
				NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[currencyNames objectForKey:key]];
				[temp addObject:currencyName];
				[currencyNames setObject:temp forKey:[currencyName substringToIndex:1]];
				//[currencyNames addObject:currencyName];
				[key release];
				[temp release];
			}
		sqlite3_finalize(stmt);
		}
	}
	else
    sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
	NSLog(@"in getAllCurrencies, currencyNames : %@", currencyNames);
	return [currencyNames autorelease];
}

+ (Currency *) getCurrencyObject:(NSString *)currencyName atDBPath:(NSString *)dbPath {
		
	Currency *currencyObj = [[Currency alloc] init];

	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		if(getStmt == nil) {
			NSString *sql = @"select * from Currency where currency=?";
			if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &getStmt, nil) != SQLITE_OK)
				NSAssert1(0, @"Error while creating get statement. '%s'", sqlite3_errmsg(database));
		}	
		
		sqlite3_bind_text(getStmt, 1, [currencyName UTF8String], -1, SQLITE_TRANSIENT);
		
		while(sqlite3_step(getStmt) == SQLITE_ROW) {
			
			currencyObj.currency = [NSString stringWithUTF8String:(char *)sqlite3_column_text(getStmt, 0)];
			currencyObj.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(getStmt, 1)];
			float f = sqlite3_column_double(getStmt, 2);
			//possible rounding off technique using integers
/*			f = f*1000;
			int i = f;
			i=i+5;
			f = i/10;
			f=f/100;
 */
			// small hack for dealing if whole numbers appear instead of decimals
			NSMutableString *tmp = [[NSMutableString alloc] initWithString:[[NSNumber numberWithFloat:f] stringValue]]; 
			if([tmp rangeOfString:@"."].length == 0 )
				[tmp appendString:@".00000"];			
			currencyObj.USDratio = tmp;
			[tmp release];
			
			currencyObj.date =[NSString stringWithUTF8String:(char *)sqlite3_column_text(getStmt, 3)];
		}
				//NSLog(@"done fetching!"); 
		sqlite3_reset(getStmt); 

	}
	else
		sqlite3_close(database);
	return currencyObj;
}

+ (void) updateBaseCurrencyRatio:(NSString *)dbPath withRatio:(NSString *)ratio {
	
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		if(updateStmt == nil) {
			NSString *sql = @"update Currency set USDratio=USDratio/? where rowid>0";
			if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &updateStmt, nil) != SQLITE_OK)
				NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		}	
	    
		sqlite3_bind_double(updateStmt, 1, [ratio doubleValue]);
		
		if(SQLITE_DONE != sqlite3_step(updateStmt))
			NSAssert1(0, @"Error while updating data. '%s'", sqlite3_errmsg(database));
		
		NSLog(@"done updating the baseCurrencyRatios!"); 
		sqlite3_reset(updateStmt); 
	}
}


- (void) deleteCurrency:(NSString *)dbPath {
	
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		if(dltStmt == nil) {
			NSString *sql = @"delete from currencies where currency=?";
			if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &dltStmt, nil) != SQLITE_OK)
				NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
		}	
		
		sqlite3_bind_text(dltStmt, 1, [currency UTF8String], -1, SQLITE_TRANSIENT);
		
		if(SQLITE_DONE != sqlite3_step(dltStmt))
			NSAssert1(0, @"Error while deleting data. '%s'", sqlite3_errmsg(database));

			NSLog(@"done deleting!"); 
		sqlite3_reset(dltStmt); 
	}
}
- (void) addCurrency:(NSString *)dbPath {
	
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		if(addStatement == nil) {
			NSString *sql = @"insert into currencies values(?)";
			if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &addStatement, nil) != SQLITE_OK)
				NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
		}	
				sqlite3_bind_text(addStatement, 1, [currency UTF8String], -1, SQLITE_TRANSIENT);
		
		if(SQLITE_DONE != sqlite3_step(addStatement))
			NSAssert1(0, @"Error while adding data. '%s'", sqlite3_errmsg(database));
		
		
		sqlite3_reset(addStatement); 
	}
}


+ (void) addParsedCurrency:(Currency *)currencyObj atDBPath:(NSString *)dbPath {
	 
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		if(addStmt == nil) {
			NSString *sql = @"insert into Currency(currency, title, USDratio, date) Values(?, ?, ?, ?)";
			if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &addStmt, nil) != SQLITE_OK)
				NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
		}
		
		
		sqlite3_bind_text(addStmt, 1, [currencyObj.currency UTF8String], -1, SQLITE_TRANSIENT);   // to bind a string
	    sqlite3_bind_text(addStmt, 2, [currencyObj.title UTF8String], -1, SQLITE_TRANSIENT);
	    sqlite3_bind_text(addStmt, 4, [currencyObj.date UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(addStmt, 3, [currencyObj.USDratio floatValue]);                           // to bind a decimal 
		
		if(SQLITE_DONE != sqlite3_step(addStmt))
			NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		else
			//SQLite provides a method to get the last primary key inserted by using sqlite3_last_insert_rowid
			//currencyID = sqlite3_last_insert_rowid(database);
		
		//Reset the add statement.
		//	NSLog(@"done adding the parsed currency!"); 
		sqlite3_reset(addStmt); 
	}
}

+ (void) finalizeStatements {
	
	if(database) sqlite3_close(database);
	if(addStmt) sqlite3_finalize(addStmt);
	if(addStatement) sqlite3_finalize(addStatement);
	if(dltStmt) sqlite3_finalize(dltStmt);
	if(getStmt) sqlite3_finalize(getStmt);
	if(updateStmt) sqlite3_finalize(updateStmt);
}

- (void) dealloc {
	
	[currency release];
	[date release];
	[title release];
	[USDratio release];
	[super dealloc];
}

@end

