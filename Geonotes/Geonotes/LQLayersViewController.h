//
//  LQLayersViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQSTableViewController.h"
#import "LQLayerItemCellView.h"
#import "LOLDatabase.h"

@interface LQLayersViewController : LQSTableViewController {
    NSMutableArray *items;
	LOLDatabase *_itemDB;
    IBOutlet LQLayerItemCellView *tableCellView;
    UIImage *placeholderImage;
}

- (void)appendObjectFromDictionary:(NSDictionary *)item;
- (void)reloadDataFromDB;
- (void)fetchRemoteDataWithCallback:(void(^)(void))block;

@end
