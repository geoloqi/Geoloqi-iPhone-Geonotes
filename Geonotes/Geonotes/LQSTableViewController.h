//
//  LQSTableViewController.h
//  Geonotes
//
//  Created by Kenichi Nakamura on 8/3/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "STableViewController.h"

//#define kLQAnonymousBannerOriginX  10
//#define kLQAnonymousBannerOriginY  10
#define kLQAnonymousBannerHeight   44
//#define kLQAnonymousBannerWidth    300

#define kLQAnonymousBannerBackgroundRed   (232.0 / 255.0)
#define kLQAnonymousBannerBackgroundGreen (136.0 / 255.0)
#define kLQAnonymousBannerBackgroundBlue  ( 70.0 / 255.0)

#define kLQAnonymousBannerBackgroundAlpha 1.0

@interface LQSTableViewController : STableViewController {
    UIButton *anonymousBanner;
}

- (void)addAnonymousBanner;
- (void)removeAnonymousBanner;

@end
