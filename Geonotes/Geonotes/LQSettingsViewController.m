//
//  LQSettingsViewController.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQSettingsViewController.h"

@interface LQSettingsViewController ()

@end

@implementation LQSettingsViewController

@synthesize locationTracking,
            allowPublicGeonotes,
            publicGeonoteURL,
            usernameLabel,
            username,
            saveUsername,
            savingIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
        self.tabBarItem.image = [UIImage imageNamed:@"settings"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"Settings View Loaded");
    
    // i don't think this is working
    self.locationTracking.on = ([[LQTracker sharedTracker] status] != LQTrackerStatusNotTracking);

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:LQAllowPublicGeonotesUserDefaultsKey] intValue] == 1) {
        self.allowPublicGeonotes.on = YES;
        [self togglePublicGeonoteFields:YES];
    } else {
        self.allowPublicGeonotes.on = NO;
    }
    
    [self populatePublicGeonoteFields];
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

- (IBAction)locationTrackingWasSwitched:(UISwitch *)sender
{
    [[LQTracker sharedTracker] setProfile:(sender.on ? LQTrackerProfileAdaptive : LQTrackerProfileOff)];
}

- (IBAction)allowPublicGeonotesWasSwitched:(UISwitch *)sender
{
    NSNumber *on = [[NSNumber alloc] initWithInt:(sender.on ? 1 : 0)];
    LQSession *session = [LQSession savedSession];
    [self togglePublicGeonoteFields:sender.on];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:on, @"public_geonotes", nil];
    [session runAPIRequest:[session requestWithMethod:@"POST" path:@"/account/privacy" payload:params]
                completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
                    // TODO handle response and errors if any
                    [[NSUserDefaults standardUserDefaults] setObject:on
                                                              forKey:LQAllowPublicGeonotesUserDefaultsKey];
                }
     ];
}

- (IBAction)saveUsernameWasTapped:(UIButton *)sender
{
    
}

- (void)togglePublicGeonoteFields:(BOOL)show
{
    self.publicGeonoteURL.hidden = !show;
    self.usernameLabel.hidden = !show;
    self.username.hidden = !show;
    self.saveUsername.hidden = !show;
    self.saveUsername.enabled = show;
}

- (void)populatePublicGeonoteFields
{
    LQSession *session = [LQSession savedSession];
    self.publicGeonoteURL.text = [[NSString alloc] initWithFormat:@"http://geoloqi.com/%@", session.username];
    self.username.text = session.username;
}

- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
}
@end
