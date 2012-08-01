//
//  LQSecondViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STableViewController.h"
#import "LQGeonoteItemCellView.h"
#import "LOLDatabase.h"

@interface LQGeonotesViewController : STableViewController {
    NSMutableArray *items;
    LOLDatabase *_itemDB;
    IBOutlet LQGeonoteItemCellView *tableCellView;
    UIImage *placeholderImage;
    NSDateFormatter *dateFormatter;
}

//- (void)appendObjectFromDictionary:(NSDictionary *)item;
- (void)prependObjectFromDictionary:(NSDictionary *)item;
- (void)reloadDataFromDB;
- (void)fetchRemoteDataWithCallback:(void(^)(void))block;

@end
