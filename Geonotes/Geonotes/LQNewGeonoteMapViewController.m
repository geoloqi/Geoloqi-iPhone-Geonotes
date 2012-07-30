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
            geonotePin, geonotePinShadow, geonoteTarget;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.rightBarButtonItem = [self pickButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.locateMeButton = [[MTLocateMeBarButtonItem alloc] initWithMapView:mapView];
    [self.toolbar setItems:[NSArray arrayWithObjects:self.locateMeButton, nil] animated:NO];
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

- (UIBarButtonItem *)pickButton
{
    UIBarButtonItem *pick = [[UIBarButtonItem alloc] initWithTitle:@"Pick"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(pickButtonWasTapped:)];
    pick.tintColor = [UIColor blueColor];
    return pick;
}

#pragma mark -

- (IBAction)pickButtonWasTapped:(UIBarButtonItem *)pickButton
{
    
}

@end
