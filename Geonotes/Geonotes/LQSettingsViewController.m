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
    
    self.locationTracking.on = ([[LQTracker sharedTracker] profile] != LQTrackerProfileOff);

    if ([[NSUserDefaults standardUserDefaults] integerForKey:LQAllowPublicGeonotesUserDefaultsKey] == 1) {
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
    int on = sender.on ? 1 : 0;
    LQSession *session = [LQSession savedSession];
    [self togglePublicGeonoteFields:sender.on];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSString alloc] initWithFormat:@"%d", on], @"public_geonotes", nil];
    [session runAPIRequest:[session requestWithMethod:@"POST" path:@"/account/privacy" payload:params]
                completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
                    // TODO handle response and errors if any
                    [[NSUserDefaults standardUserDefaults] setInteger:on
                                                              forKey:LQAllowPublicGeonotesUserDefaultsKey];
                }
     ];
}

- (IBAction)saveUsernameWasTapped:(UIButton *)sender
{
    [self doneEditing:self.username];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:username.text, @"desired_username", nil];
    LQSession *session = [LQSession savedSession];
    self.savingIndicator.hidden = NO;
    [session runAPIRequest:[session requestWithMethod:@"POST" path:@"/account/set_username" payload:params]
                completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
                    self.savingIndicator.hidden = YES;
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:[[error userInfo] objectForKey:@"NSLocalizedDescription"]
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                    }
                    NSString *res = (NSString *)[responseDictionary objectForKey:@"response"];
                    if (res && [res isEqualToString:@"ok"]) {
                        [self populatePublicGeonoteFields:username.text];
                        // hack to get new session data with the new username
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.geoloqi.LQUserID"];
                        [LQSession sessionWithAccessToken:session.accessToken];
                    }
                }
     ];
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
    [self populatePublicGeonoteFields:[[LQSession savedSession] username]];
}

- (void)populatePublicGeonoteFields:(NSString *)_username
{
    self.publicGeonoteURL.text = [[NSString alloc] initWithFormat:@"http://geoloqi.com/%@", _username];
    self.username.text = _username;
}

- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self populatePublicGeonoteFields:[[LQSession savedSession] username]];
    [self.username becomeFirstResponder];
}

@end
