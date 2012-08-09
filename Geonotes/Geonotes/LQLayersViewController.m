//
//  LQLayersViewController.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQLayersViewController.h"
#import "LQTableHeaderView.h"
#import "NSString+URLEncoding.h"

#import "LQAppDelegate.h"

@interface LQLayersViewController ()

@end

@implementation LQLayersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Layers", @"Layers");
        self.tabBarItem.image = [UIImage imageNamed:@"layers"];
    }

    placeholderImage = [UIImage imageNamed:@"defaultLayerIcon"];
    
    _itemDB = [[LOLDatabase alloc] initWithPath:[LQAppDelegate cacheDatabasePathForCategory:@"LQLayer"]];
	_itemDB.serializer = ^(id object){
		return [LQSDKUtils dataWithJSONObject:object error:NULL];
	};
	_itemDB.deserializer = ^(NSData *data) {
		return [LQSDKUtils objectFromJSONData:data error:NULL];
	};

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Layers View Loaded");

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
    [_itemDB accessCollection:LQLayerListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
        [accessor enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *object, BOOL *stop) {
            [self appendObjectFromDictionary:object];
        }];
    }];

    [self sortItemArrayAlphabetically];
}

- (void)fetchRemoteDataWithCallback:(void(^)(void))block
{
    NSURLRequest *request = [[LQSession savedSession] requestWithMethod:@"GET" path:@"/layer/app_list" payload:nil];
    [[LQSession savedSession] runAPIRequest:request completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error){
        
        items = [[NSMutableArray alloc] init];
        
        for(NSString *key in responseDictionary) {
            for(NSDictionary *item in [responseDictionary objectForKey:key]) {
                [_itemDB accessCollection:LQLayerListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
                    // Store in the database
                    [accessor setDictionary:item forKey:[item objectForKey:@"layer_id"]];
                    // Also add to the local array
                    [self appendObjectFromDictionary:item];
                }];
            }
        }
        
        [self sortItemArrayAlphabetically];
        
        if(block) {
            block();
        }
    }];
}

- (void)appendObjectFromDictionary:(NSDictionary *)item
{
    [items insertObject:item atIndex:items.count];
}

- (void)sortItemArrayAlphabetically {
    // Sort the items in the array by title
    [items sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *title1 = [obj1 objectForKey:@"name"];
        NSString *title2 = [obj2 objectForKey:@"name"];
        return [title1 localizedCaseInsensitiveCompare:title2];
    }];
}

- (void)subscribeWasTapped:(UISwitch *)sender
{
    NSString *path;
    if(sender.on) {
        path = @"subscribe";
    } else {
        path = @"unsubscribe";
    }
    
    [LQAppDelegate registerForPushNotificationsIfNotYetRegistered];
    
    NSDictionary *item = [items objectAtIndex:sender.tag];
    NSMutableURLRequest *request = [[LQSession savedSession] requestWithMethod:@"POST" path:[NSString stringWithFormat:@"/layer/%@/%@", path, [item objectForKey:@"layer_id"]] payload:nil];
    
    [[LQSession savedSession] runAPIRequest:request completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error){
        
        // Update the local cache
        [self fetchRemoteDataWithCallback:^{
            [self.tableView reloadData];
        }];
    }];
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
    return 77;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    LQLayerItemCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"LQLayerItemCellView" owner:self options:nil];
		cell = tableCellView;
	}
    
    id item = [items objectAtIndex:indexPath.row];
    if(item) {
        cell.layerID = [item objectForKey:@"layer_id"];
        cell.titleText.text = [item objectForKey:@"name"];
        cell.descriptionText.text = [item objectForKey:@"description"];
        cell.subscriptionSwitch.on = [[item objectForKey:@"subscribed"] boolValue];
        cell.subscriptionSwitch.tag = indexPath.row;
        [cell.subscriptionSwitch addTarget:self action:@selector(subscribeWasTapped:) forControlEvents:UIControlEventValueChanged];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; // TODO: Remove this to enable selecting rows again
        [cell setImageFromURL:[item objectForKey:@"icon"] placeholderImage:placeholderImage];
    }
    return cell;
}

#pragma mark -

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
