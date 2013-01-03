//
//  RootViewController.m
//  RssReader
//

#import "RootViewController.h"
#import "DetailController.h"
#import "Parser.h"
#import "Currency.h"
#import "AddViewController.h"
#import "RssReaderAppDelegate.h"

@interface RootViewController (PrivateMethods)
- (void)loadData;
@end

@implementation RootViewController

@synthesize activityIndicator, items, isBaseDefault, baseCurrencyChanged;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (RssReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  	indicator.hidesWhenStopped = YES;
  	[indicator stopAnimating];
  	self.activityIndicator = indicator;
  	[indicator release];
	
  	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:indicator];
  	self.navigationItem.leftBarButtonItem = leftButton;
  	[leftButton release];
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.title = @"Currency Converter";
}


/*
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}
*/
- (void)viewDidAppear:(BOOL)animated {
  	[self loadData];
	[super viewDidAppear:animated];
}

- (void)loadData {
	
	if(appDelegate.userCurrencies == nil)
		appDelegate.userCurrencies = [[NSMutableArray alloc] initWithArray:[Currency getCurrency:appDelegate.dbPath]];
	
  	if (appDelegate.currencyArray == nil) {
		NSMutableArray *tempArray = [[NSMutableArray alloc] init];
		appDelegate.currencyArray = tempArray;
		[tempArray release];
		
  		[activityIndicator startAnimating];
		
  		Parser *rssParser = [[Parser alloc] init];
		if(appDelegate.baseCurrency == nil || appDelegate.baseCurrency == @"US Dollar")
			isBaseDefault = YES;
		else 
		    isBaseDefault = NO;

		//parse
	    [rssParser parseRssFeed:@"http://themoneyconverter.com/rss-feed/USD/rss.xml" withDelegate:self];
  		[rssParser release];
  	} else 
	{   // small hack for ensuring that your baseCurrency value is always 1.00000 irrespective of the calculations taking place at the backend
		for(Currency *obj in appDelegate.currencyArray)
		{
			if( [obj.currency isEqualToString:appDelegate.baseCurrency] ) {
				obj.USDratio = @"1.00000"; 
			}
		}
		[self.tableView reloadData];
	}
}

/* the extra method we defined in parser.h */
- (void)receivedItems {
	NSLog(@"Done Parsing!");
	
	// create our appDelegate.currenncyArray from the parsed data 
	for(NSString *each in appDelegate.userCurrencies) {
	
		Currency *cObj = [Currency getCurrencyObject:each atDBPath:appDelegate.dbPath];
		[appDelegate.currencyArray addObject:cObj];
	}
			
	// Do manipulations on the generated currencyArray
	// check if the baseCurrency was nil or US, if NOT, do manipulations on the freshly parsed data for the view
	if(isBaseDefault)
	   appDelegate.baseCurrency = @"US Dollar";
	else {
		// get the Currency object from the current baseCurrency value
		Currency *baseCurrencyObj = [Currency getCurrencyObject:appDelegate.baseCurrency 
													   atDBPath:appDelegate.dbPath];
		
		// call updateBaseCurrencyRatio method of Currency model
		[Currency updateBaseCurrencyRatio:appDelegate.dbPath withRatio:baseCurrencyObj.USDratio];
		
		// update values for each in currencyArray
		for(Currency *obj in appDelegate.currencyArray)
		{
			if( [obj.currency isEqualToString:appDelegate.baseCurrency] ) { 
				obj.USDratio = @"1.00000"; 
			}
			else { 
				Currency *temp = [Currency getCurrencyObject:obj.currency atDBPath:appDelegate.dbPath];
				obj.USDratio = temp.USDratio;
				[temp release];
			}
		}
		
	}

  	[self.tableView reloadData];
  	[activityIndicator stopAnimating];
	
	// replace the indicator with a refresh button
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshData)];
	self.navigationItem.leftBarButtonItem = refreshButton;
	
	//auto-refresh timer set
	NSLog(@"autoRefreshing after %d secs", appDelegate.autoRefreshInterval);
    [NSTimer scheduledTimerWithTimeInterval:(appDelegate.autoRefreshInterval) target:self selector:@selector(refreshData) userInfo:nil repeats:FALSE];

	
}

- (void)refreshData {
	
	// switch on the indicator
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
  	self.navigationItem.leftBarButtonItem = leftButton;
  	[leftButton release];
	
	// make the currencyArray and userCurrencies as nil, call loadData
	[appDelegate.currencyArray removeAllObjects];
	appDelegate.currencyArray = nil;
	//[appDelegate.userCurrencies removeAllObjects];
	//appDelegate.userCurrencies = nil;
	NSLog(@"Refreshing data!");
	[self loadData];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:YES];
	
	//Do not let the user refresh if the app is in edit mode.
	if(editing)
		self.navigationItem.leftBarButtonItem.enabled = NO;
	else
		self.navigationItem.leftBarButtonItem.enabled = YES;
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	 int count = [appDelegate.currencyArray count];
	 count = count+1;
	 return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { //NSLog(@"items.count : %d  and indexPath.row : %d", [items count], indexPath.row);
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.showsReorderControl = YES;
	}
	
	
  	// Configure the cell.
	
	if (indexPath.row < [appDelegate.currencyArray count]) {
		
		Currency *currencyObj = [appDelegate.currencyArray objectAtIndex:indexPath.row];
  	    cell.textLabel.text = currencyObj.currency;
			
  	    /* If we have to show date
	     // Format date :
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
  	    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  	    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
  	     cell.detailTextLabel.text = [dateFormatter stringFromDate:[[items objectAtIndex:indexPath.row] objectForKey:@"date"]]; 
	    */

	   cell.detailTextLabel.text = currencyObj.USDratio;
  	   //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	 else {
		cell.textLabel.text = @"";
		cell.detailTextLabel.text = @"";
		//TODO:l check what exactly is happening here => NSLog(@"cell text of %d -th row: %@", indexPath.row, cell.textLabel.text);
	}

	return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row == [appDelegate.currencyArray count]) { 
		return UITableViewCellEditingStyleInsert;
	} 
	else {
		return UITableViewCellEditingStyleDelete;
	}
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		
		// get the currency object from the row clicked
		Currency *currencyObj = [appDelegate.currencyArray objectAtIndex:indexPath.row];

		// Call the removeCurrency method of appDelegate
		[appDelegate removeCurrency:currencyObj];

		//Delete the object from the table.
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];	
	}
	
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		[self add_Clicked];
		
    } 
}

- (void) add_Clicked { 
	
	if(avController == nil)
		avController = [[AddViewController alloc] initWithNibName:@"AddView" bundle:nil];
	
	if(addNavigationController == nil)
		addNavigationController = [[UINavigationController alloc] initWithRootViewController:avController];
	
	[self.navigationController presentModalViewController:addNavigationController animated:YES];
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
    Currency *objToMove = [[appDelegate.currencyArray objectAtIndex:fromIndexPath.row] retain];
	[appDelegate.currencyArray removeObjectAtIndex:fromIndexPath.row];
	[appDelegate.currencyArray insertObject:objToMove atIndex:toIndexPath.row];
	[objToMove release];
	
	NSString *currencyToMove = [[appDelegate.userCurrencies objectAtIndex:fromIndexPath.row] retain];
	[appDelegate.userCurrencies removeObjectAtIndex:fromIndexPath.row];
	[appDelegate.userCurrencies insertObject:currencyToMove atIndex:toIndexPath.row];
	[currencyToMove release];
	
	[Currency clearUserDB:appDelegate.dbPath];
	
	for(Currency *eachObj in appDelegate.currencyArray) {
	     [eachObj addCurrency:appDelegate.dbPath];
	}
	NSLog(@"Done updating the order!");
}




// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
	if (indexPath.row >= [appDelegate.currencyArray count]) // Don't move the first row
		return NO;
	
    return YES;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.row < [appDelegate.currencyArray count]) {
	// get the baseCurrencyObj value for the currency user taps on
	appDelegate.baseCurrencyObj = [appDelegate.currencyArray objectAtIndex:indexPath.row];

	
	// ADD a NOTIFICATION for Confirmation
	
	NSString *initStr = [[NSString alloc] initWithFormat:@"Change the baseCurrency to \"%@\"?", appDelegate.baseCurrencyObj.currency];
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:initStr delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
	}
	/*
	// IF we want the DetailController :
	Currency *currencyItem = [appDelegate.currencyArray objectAtIndex:indexPath.row];
	DetailController *nextController = [[DetailController alloc] initWithCurrency:currencyItem];
	[self.navigationController pushViewController:nextController animated:YES];
	[nextController release]; 
	 
	 */
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [actionSheet cancelButtonIndex]) {
		
			// check if the baseCurrency = clicked currency or not, If yes do Nothing
			
			if(appDelegate.baseCurrency != appDelegate.baseCurrencyObj.currency) {
				
				// set the new baseCurrency 
				appDelegate.baseCurrency = appDelegate.baseCurrencyObj.currency;
				
				// call updateBaseCurrencyRatio method of Currency model
				[Currency updateBaseCurrencyRatio:appDelegate.dbPath withRatio:appDelegate.baseCurrencyObj.USDratio];
				
				// update values for each in currencyArray
				for(Currency *obj in appDelegate.currencyArray)
				{
					if( [obj.currency isEqualToString:appDelegate.baseCurrency] ) { 
						obj.USDratio = @"1.00000"; 
					}
					else { 
						Currency *temp = [Currency getCurrencyObject:obj.currency atDBPath:appDelegate.dbPath];
						obj.USDratio = temp.USDratio;
						[temp release];
					}
				}
				
				[self.tableView reloadData];
			}
		
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
  	[activityIndicator release];
  	[items release];
	[super dealloc];
}

@end


