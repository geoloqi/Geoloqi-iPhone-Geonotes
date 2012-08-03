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
    
    if ([[LQSession savedSession] isAnonymous]) {
        [(LQAppDelegate *)[[UIApplication sharedApplication] delegate] addUsingAnonymouslyBannerToView:self.view
                                                                                         withTableView:self.tableView];
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

@end
