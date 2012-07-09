//
//  LQFirstViewController.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQActivityViewController.h"
#import "LQTableHeaderView.h"
#import "LQTableFooterView.h"

#import "LQAppDelegate.h"

#import "NSString+URLEncoding.h"

@interface LQActivityViewController ()

@end

@implementation LQActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Activity", @"Activity");
        self.tabBarItem.image = [UIImage imageNamed:@"activity"];
    }
    
	_itemDB = [[LOLDatabase alloc] initWithPath:[LQAppDelegate cacheDatabasePathForCategory:@"LQActivity"]];
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
    NSLog(@"Activity View Loaded");

    [self.tableView setBackgroundColor:[UIColor colorWithWhite:249.0/255.0 alpha:1.0]];

    // set the custom view for "pull to refresh". See LQTableHeaderView.xib
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LQTableHeaderView" owner:self options:nil];
    LQTableHeaderView *headerView = (LQTableHeaderView *)[nib objectAtIndex:0];
    self.headerView = headerView;
    
    // set the custom view for "load more". See LQTableFooterView.xib
    nib = [[NSBundle mainBundle] loadNibNamed:@"LQTableFooterView" owner:self options:nil];
    LQTableFooterView *footerView = (LQTableFooterView *)[nib objectAtIndex:0];
    self.footerView = footerView;

    // Load the stored notes from the local database
    items = [[NSMutableArray alloc] init];
    [_itemDB accessCollection:LQActivityListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
        [accessor enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *object, BOOL *stop) {
            [self prependObjectFromDictionary:object];
        }];
    }];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)prependObjectFromDictionary:(NSDictionary *)item
{
    [items insertObject:item atIndex:0];
}

- (void)appendObjectFromDictionary:(NSDictionary *)item
{
    [items insertObject:item atIndex:items.count];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Pull to Refresh

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) pinHeaderView
{
    [super pinHeaderView];
    
    // do custom handling for the header view
    LQTableHeaderView *hv = (LQTableHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = @"Loading...";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) unpinHeaderView
{
    [super unpinHeaderView];
    
    // do custom handling for the header view
    [[(LQTableHeaderView *)self.headerView activityIndicator] stopAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Update the header text while the user is dragging
// 
- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    LQTableHeaderView *hv = (LQTableHeaderView *)self.headerView;
    if (willRefreshOnRelease)
        hv.title.text = @"Release to refresh...";
    else
        hv.title.text = @"Pull down to refresh...";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// refresh the list. Do your async calls here.
// Retrieve newer entries for the top of the list
//
- (BOOL) refresh
{
    if (![super refresh])
        return NO;
    
    NSDictionary *item = [items objectAtIndex:0];
    NSLog(@"Newest entry is: %@", item);
    NSString *date;
    if(item && [item objectForKey:@"published"])
        date = [[item objectForKey:@"published"] urlEncodeUsingEncoding:NSUTF8StringEncoding];
    else
        date = @"";
    
    // Do your async call here
    NSURLRequest *request = [[LQSession savedSession] requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/timeline/messages?after=%@", date] payload:nil];
    [[LQSession savedSession] runAPIRequest:request completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error){
        NSLog(@"Got API Response: %d items", [[responseDictionary objectForKey:@"items"] count]);
        NSLog(@"%@", responseDictionary);

        for(NSDictionary *item in [[responseDictionary objectForKey:@"items"] reverseObjectEnumerator]) {
            [_itemDB accessCollection:LQActivityListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
                // Store in the database
                [accessor setDictionary:item forKey:[item objectForKey:@"published"]];
                // Also add to the top of the local array
                [self prependObjectFromDictionary:item];
            }];
        }

        // Tell the table to reload
        [self.tableView reloadData];
        
        // Call this to indicate that we have finished "refreshing".
        // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
        [self refreshCompleted];
    }];

    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Load More

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// The method -loadMore was called and will begin fetching data for the next page (more). 
// Do custom handling of -footerView if you need to.
//
- (void) willBeginLoadingMore
{
    LQTableFooterView *fv = (LQTableFooterView *)self.footerView;
    [fv.activityIndicator startAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Do UI handling after the "load more" process was completed. In this example, -footerView will
// show a "No more items to load" text.
//
- (void) loadMoreCompleted
{
    [super loadMoreCompleted];
    
    LQTableFooterView *fv = (LQTableFooterView *)self.footerView;
    [fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by: [self setFooterViewVisibility:NO];
        
        // Just show a textual info that there are no more items to load
        fv.infoLabel.hidden = NO;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) loadMore
{
    if (![super loadMore])
        return NO;
    
    NSDictionary *item = [items objectAtIndex:items.count-1];
    NSLog(@"Oldest entry is: %@", item);
    NSString *date;
    if(item && [item objectForKey:@"published"])
        date = [[item objectForKey:@"published"] urlEncodeUsingEncoding:NSUTF8StringEncoding];
    else
        date = @"";
    
    // Do your async call here
    NSURLRequest *request = [[LQSession savedSession] requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/timeline/messages?before=%@", date] payload:nil];
    [[LQSession savedSession] runAPIRequest:request completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error){
        NSLog(@"Got API Response: %d items", [[responseDictionary objectForKey:@"items"] count]);
        NSLog(@"%@", responseDictionary);
        
        for(NSDictionary *item in [responseDictionary objectForKey:@"items"]) {
            [_itemDB accessCollection:LQActivityListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
                // Store in the database
                [accessor setDictionary:item forKey:[item objectForKey:@"published"]];
                // Also add to the bottom of the local array
                [self appendObjectFromDictionary:item];
            }];
        }
        
        // Tell the table to reload
        [self.tableView reloadData];
        
        if ([[responseDictionary objectForKey:@"paging"] objectForKey:@"next_offset"])
            self.canLoadMore = YES;
        else
            self.canLoadMore = NO; // signal that there won't be any more items to load
        
        // Inform STableViewController that we have finished loading more items
        [self loadMoreCompleted];
    }];
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Standard TableView delegates

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
    
    LQActivityItemCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"LQActivityItemCellView" owner:self options:nil];
		cell = tableCellView;
	}
    
    id item = [items objectAtIndex:indexPath.row];
    if(item) {
        if([item respondsToSelector:@selector(objectForKey:)]) {
            cell.headerText.text = [item objectForKey:@"title"];
            cell.secondaryText.text = [[item objectForKey:@"object"] objectForKey:@"summary"];
            cell.dateText.text = [item objectForKey:@"displayDate"];
            
            NSString *imageURL;
            if(![[[[item objectForKey:@"actor"] objectForKey:@"image"] objectForKey:@"url"] isEqualToString:@""]) {
                imageURL = [[[item objectForKey:@"actor"] objectForKey:@"image"] objectForKey:@"url"];
            } else if(![[[[item objectForKey:@"generator"] objectForKey:@"image"] objectForKey:@"url"] isEqualToString:@""]) {
                imageURL = [[[item objectForKey:@"generator"] objectForKey:@"image"] objectForKey:@"url"];
            }
            if(![imageURL isEqualToString:@""]) {
                [cell setImageFromURL:imageURL];
            }
        } else {
            cell.secondaryText.text = item;
        }
    }
    return cell;
}

@end
