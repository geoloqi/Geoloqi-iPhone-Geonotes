//
//  LQNewGeonoteMapViewController.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/27/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQNewGeonoteMapViewController.h"
#import "MTLocation/MTLocateMeBarButtonItem.h"

@interface LQNewGeonoteMapViewController ()

@end

@implementation LQNewGeonoteMapViewController

@synthesize toolbar, locateMeButton,
            navigationBar, cancelButton, pickButton,
            geonotePin, geonotePinShadow, geonoteTarget;

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
    // Do any additional setup after loading the view from its nib.
    self.locateMeButton = [[MTLocateMeBarButtonItem alloc] initWithMapView:mapView];
    [self.toolbar setItems:[NSArray arrayWithObject:self.locateMeButton] animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

#pragma mark -

- (IBAction)cancelWasTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
