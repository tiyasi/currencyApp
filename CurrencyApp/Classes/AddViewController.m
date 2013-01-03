//
//  AddViewController.m
//  RssReader
//

#import "AddViewController.h"
#import "Currency.h"
#import "RootViewController.h"

@implementation AddViewController

@synthesize names, keys;
@synthesize currencyName;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	appDelegate = (RssReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	self.title = @"Add Currency";
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self action:@selector(cancel_Clicked:)] autorelease];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self action:@selector(save_Clicked:)] autorelease];
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor]; 
	
	NSMutableDictionary *arr = [Currency getAllCurrencies:appDelegate.dbPath];
	names = [[NSMutableDictionary alloc] initWithDictionary:arr];
	//NSLog(@"names : %@", names);
	
	NSArray *array = [[names allKeys] sortedArrayUsingSelector:@selector(compare:)];
	self.keys = array;
   // NSLog(@"keys : %@", keys);
}


- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}
/*

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	
	[theTextField resignFirstResponder];
	return YES;
}
*/
- (void) cancel_Clicked:(id)sender {
	
	//Dismiss the controller.
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void) save_Clicked:(id)sender {
	
	Currency *currencyObj = [[Currency alloc] init];
	currencyObj = [Currency getCurrencyObject:self.currencyName atDBPath:appDelegate.dbPath];

	//Call the insertCurrency method of the delegate
	[appDelegate insertCurrency:currencyObj];
	[currencyObj release];

    //Dismiss the controller.
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *key = [keys objectAtIndex:section];
	NSArray *nameSection = [names objectForKey:key];
	return [nameSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	NSString *key = [keys objectAtIndex:section];
	NSArray *nameSection = [names objectForKey:key];
	
	static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SectionsTableIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SectionsTableIdentifier] autorelease];
	}
	
	cell.textLabel.text = [nameSection objectAtIndex:row];
	NSLog(@"%@", cell.textLabel.text);
	return cell;						
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *key = [keys objectAtIndex:section];
	return key;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView { 
	return keys;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	NSString *key = [keys objectAtIndex:section];
	NSArray *nameSection = [names objectForKey:key];
	self.currencyName = [nameSection objectAtIndex:row];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[names release];
	[keys release];
	[currencyName release];
	[keys release];
    [super dealloc];
}

@end
