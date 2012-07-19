//
//  LQSecondViewController.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQGeonotesViewController.h"
#import "LQTableHeaderView.h"
#import "NSString+URLEncoding.h"

#import "LQAppDelegate.h"

@interface LQGeonotesViewController ()

@end

@implementation LQGeonotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Geonotes", @"Geonotes");
        self.tabBarItem.image = [UIImage imageNamed:@"geonote"];
    }

    _itemDB = [[LOLDatabase alloc] initWithPath:[LQAppDelegate cacheDatabasePathForCategory:@"LQGeonotes"]];
	_itemDB.serializer = ^(id object){
		return [LQSDKUtils dataWithJSONObject:object error:NULL];
	};
	_itemDB.deserializer = ^(NSData *data) {
		return [LQSDKUtils objectFromJSONData:data error:NULL];
	};

    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Geonotes View Loaded");

    [self.tableView setBackgroundColor:[UIColor colorWithWhite:249.0/255.0 alpha:1.0]];
    
    // set the custom view for "pull to refresh". See LQTableHeaderView.xib
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LQTableHeaderView" owner:self options:nil];
    LQTableHeaderView *headerView = (LQTableHeaderView *)[nib objectAtIndex:0];
    self.headerView = headerView;
    
    // Load the list from the local database
    [self reloadDataFromDB];
    
    // If there are no layers, then force an API call
    if(items.count == 0) {
        [self refresh];
    }
}

#pragma mark - Data

- (void)reloadDataFromDB
{
    items = [[NSMutableArray alloc] init];
    [_itemDB accessCollection:LQGeonoteListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
        [accessor enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *object, BOOL *stop) {
            [self appendObjectFromDictionary:object];
        }];
    }];
}

- (void)fetchRemoteDataWithCallback:(void(^)(void))block
{
    NSURLRequest *request = [[LQSession savedSession] requestWithMethod:@"GET" path:@"/geonote/list_set" payload:nil];
    [[LQSession savedSession] runAPIRequest:request completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error){
        
        items = [[NSMutableArray alloc] init];
        
        for(NSString *key in responseDictionary) {
            for(NSDictionary *item in [responseDictionary objectForKey:key]) {
                [_itemDB accessCollection:LQGeonoteListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
                    // Store in the database
                    [accessor setDictionary:item forKey:[item objectForKey:@"geonote_id"]];
                    // Also add to the local array
                    [self appendObjectFromDictionary:item];
                }];
            }
        }
        
        if(block) {
            block();
        }
    }];
}

- (void)appendObjectFromDictionary:(NSDictionary *)item
{
    [items insertObject:item atIndex:items.count];
}

#pragma mark - Pull to Refresh

- (void) pinHeaderView
{
    [super pinHeaderView];
    
    // do custom handling for the header view
    LQTableHeaderView *hv = (LQTableHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = @"Loading...";
}

- (void) unpinHeaderView
{
    [super unpinHeaderView];
    
    // do custom handling for the header view
    [[(LQTableHeaderView *)self.headerView activityIndicator] stopAnimating];
}

- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    LQTableHeaderView *hv = (LQTableHeaderView *)self.headerView;
    if (willRefreshOnRelease)
        hv.title.text = @"Release to refresh...";
    else
        hv.title.text = @"Pull down to refresh...";
}

- (BOOL) refresh
{
    if (![super refresh])
        return NO;
    
    // Do your async call here
    [self fetchRemoteDataWithCallback:^{
        // Tell the table to reload
        [self.tableView reloadData];
        
        // Call this to indicate that we have finished "refreshing".
        // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
        [self refreshCompleted];
    }];
    
    return YES;
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    LQGeonoteItemCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"LQGeonoteItemCellView" owner:self options:nil];
		cell = tableCellView;
	}
    
    id item = [items objectAtIndex:indexPath.row];
    if(item) {
        cell.headerText.text = @"";
        cell.secondaryText.text = [item objectForKey:@"text"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; // TODO: Remove this to enable selecting rows again
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"date_created_ts"] doubleValue]];
        cell.dateText.text = [dateFormatter stringFromDate:date];
    }
    return cell;
}

#pragma mark -


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
