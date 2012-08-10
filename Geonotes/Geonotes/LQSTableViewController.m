//
//  LQSTableViewController.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 8/3/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQSTableViewController.h"
#import "LQAppDelegate.h"

@interface LQSTableViewController ()

@end

@implementation LQSTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    LQSession *session = [LQSession savedSession];
    if (!session || [session isAnonymous]) {
        [self addAnonymousBanner];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

- (void)addAnonymousBanner
{
    CGRect _tvf = self.tableView.frame;
    CGRect tvf = CGRectMake(_tvf.origin.x,
                            (_tvf.origin.y + kLQAnonymousBannerHeight),
                            _tvf.size.width,
                            (_tvf.size.height - kLQAnonymousBannerHeight));
    CGRect bannerFrame = CGRectMake(_tvf.origin.x, _tvf.origin.y, _tvf.size.width, kLQAnonymousBannerHeight);
    anonymousBanner = [UIButton buttonWithType:UIButtonTypeCustom];
    anonymousBanner.frame = bannerFrame;
    anonymousBanner.backgroundColor = [UIColor colorWithRed:kLQAnonymousBannerBackgroundRed
                                                      green:kLQAnonymousBannerBackgroundGreen
                                                       blue:kLQAnonymousBannerBackgroundBlue
                                                      alpha:kLQAnonymousBannerBackgroundAlpha];
    [anonymousBanner setTitle:@"You are using Geonotes anonymously" forState:UIControlStateNormal];
    [anonymousBanner setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    anonymousBanner.titleLabel.font = [UIFont systemFontOfSize:12];
    [anonymousBanner setUserInteractionEnabled:YES];
    [anonymousBanner addTarget:[[UIApplication sharedApplication] delegate]
                        action:@selector(selectSetupAccountView)
              forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.frame = tvf;
    [self.view addSubview:anonymousBanner];
}

- (void)removeAnonymousBanner
{
    if (anonymousBanner) {
        [anonymousBanner removeFromSuperview];
        CGRect frame = self.tableView.frame;
        frame.origin.y -= kLQAnonymousBannerHeight;
        frame.size.height += kLQAnonymousBannerHeight;
        self.tableView.frame = frame;
        anonymousBanner = nil;
    }
}

@end
