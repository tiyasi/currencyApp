//
//  Parser.h
//  RssReader
//

#import <Foundation/Foundation.h>
#import "RssReaderAppDelegate.h"

@protocol ParserDelegate <NSObject>
- (void)receivedItems;
@end

@class Currency;

@interface Parser : NSObject <NSXMLParserDelegate> {
	
	RssReaderAppDelegate *appDelegate;
	id _delegate;
	
	NSMutableData *responseData;
	
	NSString *currentElement;
	NSMutableString * currentTitle, * currentDate, * currentSummary;
}

@property (retain, nonatomic) NSMutableData *responseData;
@property (retain, nonatomic) NSMutableString *currentTitle;
@property (retain, nonatomic) NSMutableString *currentDate;
@property (retain, nonatomic) NSMutableString *currentSummary;

- (void)parseRssFeed:(NSString *)url withDelegate:(id)aDelegate;

// methods for managing delegates for the NSXMLParser
- (id)delegate;
- (void)setDelegate:(id)new_delegate;

@end
