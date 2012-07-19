//
//  LQFirstViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STableViewController.h"
#import "LQActivityItemCellView.h"
#import <LQSDKUtils.h>
#import "LOLDatabase.h"

@interface LQActivityViewController : STableViewController {
    NSMutableArray *items;
	LOLDatabase *_itemDB;
    IBOutlet LQActivityItemCellView *tableCellView;
    NSDateFormatter *dateFormatter;
}

- (void)prependObjectFromDictionary:(NSDictionary *)item;
- (void)appendObjectFromDictionary:(NSDictionary *)item;
- (void)reloadDataFromDB;

@end
