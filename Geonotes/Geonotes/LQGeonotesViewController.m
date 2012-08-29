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
#import "sqlite3.h"
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
    
    self.navigationItem.leftBarButtonItem = [self editButtonItem];
    self.navigationItem.leftBarButtonItem.action = @selector(editWasTapped:);
        
    // set the custom view for "pull to refresh". See LQTableHeaderView.xib
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LQTableHeaderView" owner:self options:nil];
    LQTableHeaderView *headerView = (LQTableHeaderView *)[nib objectAtIndex:0];
    self.headerView = headerView;

    // Provide an empty footer view to hide the separators between cells
    // http://stackoverflow.com/questions/1491033/how-to-display-a-table-with-zero-rows-in-uitableview
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    // Load the list from the local database
    [self reloadDataFromDB];
    
    // If there are no layers, then force an API call
    if(items.count == 0) {
        [self refresh];
    }
}

- (void)editWasTapped:(id)sender 
{
    if(self.tableView.editing) {
        [super setEditing:NO animated:YES];
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem.title = @"Edit";
    } else {
        [super setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.leftBarButtonItem.title = @"Done";
    }
}

#pragma mark - Data

- (void)reloadDataFromDB
{
    items = [[NSMutableArray alloc] init];
    [_itemDB accessCollection:LQGeonoteListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
        [accessor enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *object, BOOL *stop) {
//            [self appendObjectFromDictionary:object];
            [self prependObjectFromDictionary:object];
        }];
    }];
}

- (void)fetchRemoteDataWithCallback:(void(^)(void))block
{
    NSURLRequest *request = [[LQSession savedSession] requestWithMethod:@"GET" path:@"/geonote/list_set" payload:nil];
    [[LQSession savedSession] runAPIRequest:request completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error){
        
        items = [[NSMutableArray alloc] init];
        // Erase the Geonote list
        sqlite3 *db;
        if(sqlite3_open([[LQAppDelegate cacheDatabasePathForCategory:@"LQGeonotes"] UTF8String], &db) == SQLITE_OK) {
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM '%@'", LQGeonoteListCollectionName];
            sqlite3_exec(db, [sql UTF8String], NULL, NULL, NULL);
        }
        
        for(NSString *key in responseDictionary) {
            for(NSDictionary *item in [responseDictionary objectForKey:key]) {
                [_itemDB accessCollection:LQGeonoteListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
                    // Store in the database
                    [accessor setDictionary:item forKey:[item objectForKey:@"geonote_id"]];
                    // Also add to the local array
//                    [self appendObjectFromDictionary:item];
                    [self prependObjectFromDictionary:item];
                }];
            }
        }
        
        if(block) {
            block();
        }
    }];
}

//- (void)appendObjectFromDictionary:(NSDictionary *)item
//{
//    [items insertObject:item atIndex:items.count];
//}

- (void)prependObjectFromDictionary:(NSDictionary *)item
{
    [items insertObject:item atIndex:0];
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"Selected row: %d", indexPath.row);
//    
//    LQGeonoteItemViewController *itemViewController = [[LQGeonoteItemViewController alloc] init];
//    [itemViewController loadStory:[items objectAtIndex:indexPath.row]];
//    [self.navigationController pushViewController:itemViewController animated:YES];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74.0;
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
        cell.placeName.text = [item objectForKey:@"place_name"];
        cell.secondaryText.text = [item objectForKey:@"text"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; // TODO: Remove this to enable selecting rows again
        
        cell.dateText.text = [item objectForKey:@"display_date"];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}
   
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"Deleting item: %@", [items objectAtIndex:indexPath.row]);

        NSDictionary *item = [items objectAtIndex:indexPath.row];
        
        // Delete from Geoloqi API
        NSURLRequest *request = [[LQSession savedSession] requestWithMethod:@"POST" path:[NSString stringWithFormat:@"/trigger/delete/%@", [item objectForKey:@"geonote_id"]] payload:nil];
        [[LQSession savedSession] runAPIRequest:request completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
            NSLog(@"Deleted note: %@", responseDictionary);
        }];
        
        // Delete from sqlite cache
        [_itemDB accessCollection:LQGeonoteListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
            [accessor removeDictionaryForKey:[item objectForKey:@"geonote_id"]];
        }];
        
        // Delete from local array
        [items removeObjectAtIndex:indexPath.row];
        
        // Animate deletion
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
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
