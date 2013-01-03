//
//  Parser.m
//  RssReader
//



#import "Parser.h"
#import "Currency.h"

@implementation Parser

@synthesize responseData;  
@synthesize currentTitle;  
@synthesize currentDate;  
@synthesize currentSummary;  


// parseRssFeed method will take an url and create a NSURLConnection object
- (void)parseRssFeed:(NSString *)url withDelegate:(id)aDelegate {
	[self setDelegate:aDelegate];
	
	//TODO : no need of this arg-passing
	
	responseData = [[NSMutableData data] retain];        // variable for storing data : for further use whenever required
	NSURL *baseURL = [[NSURL URLWithString:url] retain];    // create a NSURL object from the given url
	
	
	NSURLRequest *request = [NSURLRequest requestWithURL:baseURL];     // create a request from the baseURL
	
	[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];    // create a connection using the request
}

// delegate methods of the NSURLConnection follow

// as soon as we receive some response we initialize the var responseData
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

// as soon we receive data, append that data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

// connection error method
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSString * errorString = [NSString stringWithFormat:@"Unable to download xml data (Error code %i )", [error code]];
	
    UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

// if the connection was success and we did finish loading the document, we have to parse it now
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:responseData];    // create a NSXMLParser object, initialize with the responseData we collected 
	
	[rssParser setDelegate:self];          // set the delegate calling the parser to self
	
	[rssParser parse];       // start the parser
}

#pragma mark rssParser methods

// parser methods called by the rssParser we just created

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	
	appDelegate = (RssReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//clear the database, so that the new refresed/parsed data can come in	
	[Currency clearParsedDB:appDelegate.dbPath];
	
	appDelegate.count = 0;  // for managing the addition of the baseCurrency, whose rss link we are parsing
}

/* When the NSXMLParser object traverses an element in an XML document, it sends at least three separate message to its delegate, in the following order:
  
 parser:didStartElement:namespaceURI:qualifiedName:attributes:
 
 parser:foundCharacters:
 
 parser:didEndElement:namespaceURI:qualifiedName: 
 
*/

// find the tag <item> in the xml file.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentElement = [elementName copy];
	
    if ([elementName isEqualToString:@"item"]) {
        self.currentTitle = [[NSMutableString alloc] init];
        self.currentDate = [[NSMutableString alloc] init];
        self.currentSummary = [[NSMutableString alloc] init];
    }
}

// store the data, create a Currency object, pass to the view if matching
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if ([elementName isEqualToString:@"item"]) {
		
		// Adding USD, our base currency for parsing, to DB
		if(appDelegate.count == 0) {
			appDelegate.count++;
			Currency *currencyObjForUSD = [[Currency alloc] init];
			currencyObjForUSD.currency = @"US Dollar";
			currencyObjForUSD.title = @"USD/USD";
			currencyObjForUSD.date = self.currentDate;
			currencyObjForUSD.USDratio = @"1.00000";
		    [Currency addParsedCurrency:currencyObjForUSD atDBPath:appDelegate.dbPath];
		/*	if([appDelegate.userCurrencies indexOfObject:currencyObjForUSD.currency] != NSNotFound) 
				[appDelegate.currencyArray addObject:currencyObjForUSD]; */
		}
		
		//TODO: above should/can be managed elsewhere also
		
		Currency *currencyObj = [[Currency alloc] init];
		currencyObj.title = self.currentTitle;
		currencyObj.date = self.currentDate;

		/* PARSING LINK SPECIFIC : formatting DATA */
		
		//TODO: create another function for this mess, clear this method
		
		// get currentCurrency and currentUSDratio here
		
		NSArray *tmp = [[NSArray alloc] initWithArray:[self.currentSummary componentsSeparatedByString:@" = "]];
		NSString *tmpstr = [[NSString alloc] initWithString:[tmp objectAtIndex:1]];
		NSArray *tmp1 = [[NSArray alloc] initWithArray:[tmpstr componentsSeparatedByString:@" "]];
		NSString *currentUSDratio = [[NSString alloc] initWithString:[tmp1 objectAtIndex:0]];
		NSString *currentCurrency = [[[NSString alloc] init] autorelease];
		for(NSInteger i =1; i<tmp1.count; i++)
		{
			currentCurrency = [currentCurrency stringByAppendingString:[tmp1 objectAtIndex:i]];
			currentCurrency = [currentCurrency stringByAppendingString:@" "];
		}
		currentCurrency = [currentCurrency substringToIndex:[currentCurrency length]-1];
		
		currencyObj.currency = currentCurrency;
		currencyObj.USDratio = currentUSDratio;
		
		[tmp release];
		[tmpstr release];
		[tmp1 release];
		[currentUSDratio release];
		
		/* 
		   // Parse date here if needed
		   NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		
		   [dateFormatter setDateFormat:@"E, d LLL yyyy HH:mm:ss Z"]; // Thu, 18 Jun 2010 04:48:09 -0700
		   NSDate *date = [dateFormatter dateFromString:self.currentDate];        // also store the data
		
		*/
				
	/*	if([appDelegate.userCurrencies indexOfObject:currentCurrency] != NSNotFound)
			[appDelegate.currencyArray addObject:currencyObj]; */
		
		// for each parsed item, call the addCurrency method of the class/model Currency, and store the data
		[Currency addParsedCurrency:currencyObj atDBPath:appDelegate.dbPath];
    }
}

// Handling attributes, as we go on finding attributes we go on appending in self.attribute, which we had already assigned memory in didStartElement
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([currentElement isEqualToString:@"title"]) {
        [self.currentTitle appendString:string];
    }else if ([currentElement isEqualToString:@"description"]) {
        [self.currentSummary appendString:string];
    } else if ([currentElement isEqualToString:@"pubDate"]) {
		[self.currentDate appendString:string];
		NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@" \n"];
		[self.currentDate setString: [self.currentDate stringByTrimmingCharactersInSet: charsToTrim]];
    }
}

// call receivedItems method of the delegate, which will be our viewController here becz of the if statement below, to send the parsed result to the view
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	if ([_delegate respondsToSelector:@selector(receivedItems)])
    {    
		[_delegate receivedItems];
	}
    else
    { 
        [NSException raise:NSInternalInconsistencyException
					format:@"Delegate doesn't respond to receivedItems:"];
    }
}

#pragma mark Delegate methods

- (id)delegate {
	return _delegate;
}

- (void)setDelegate:(id)new_delegate {
	_delegate = new_delegate;
}

- (void)dealloc {
	[responseData release];
	[super dealloc];
}

@end
