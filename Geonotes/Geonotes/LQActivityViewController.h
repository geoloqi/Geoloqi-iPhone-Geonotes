//
//  LQFirstViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQSTableViewController.h"
#import "LQActivityItemCellView.h"
#import <LQSDKUtils.h>
#import "LOLDatabase.h"
#import "LQActivityManager.h"

@interface LQActivityViewController : LQSTableViewController <LQActivityManagerDelegate> {
    IBOutlet LQActivityItemCellView *tableCellView;
}

@end
