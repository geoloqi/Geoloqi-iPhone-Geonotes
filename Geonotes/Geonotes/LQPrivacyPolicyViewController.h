//
//  LQPrivacyPolicyViewController.h
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/19/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const LQPrivacyPolicyURL = @"https://geoloqi.com/privacy";

@interface LQPrivacyPolicyViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end
