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

@synthesize scrollView,
            locationTracking,
            allowPublicGeonotes,
            usernameLabel,
            username,
            saveUsername,
            savingIndicator;

@synthesize publicGeonoteURL,
            publicGeonoteURLLabel,
            publicGeonoteURLButton;

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
    
    scrollView.frame = CGRectMake(0, 88, 320, 416);
    [scrollView setContentSize:CGSizeMake(320, 416)];
    
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

#pragma mark - Keyboard

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [super viewWillAppear:animated];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTextField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    currentTextField = nil;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    if (keyboadIsShown) return;
    
    NSDictionary *info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    CGRect viewFrame = [scrollView frame];
    // not sure where these extra 5 pixels are coming from...
    viewFrame.size.height -= (keyboardRect.size.height - 5);
    scrollView.frame = viewFrame;
    CGRect textFieldFrame = [currentTextField frame];
    [scrollView scrollRectToVisible:textFieldFrame animated:YES];
    keyboadIsShown = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    CGRect viewFrame = [scrollView frame];
    // not sure where these extra 5 pixels are coming from...
    viewFrame.size.height += (keyboardRect.size.height - 5);
    scrollView.frame = viewFrame;
    keyboadIsShown = NO;
}

#pragma mark - IBActions

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
    if (currentTextField)
        [currentTextField resignFirstResponder];
    
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

- (IBAction)publicGeonoteURLButtonWasTapped:(UIButton *)sender
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = publicGeonoteURL.text;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copied"
                                                    message:@"Your public Geonote URL has been copied."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Helpers

- (void)togglePublicGeonoteFields:(BOOL)show
{
    self.publicGeonoteURL.hidden = !show;
    self.publicGeonoteURLButton.hidden = !show;
    self.publicGeonoteURLLabel.hidden = !show;

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
    self.publicGeonoteURL.text = [NSString stringWithFormat:@"https://%@/%@", LQGeoloqiDomainName, _username];
    self.username.text = _username;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self populatePublicGeonoteFields:[[LQSession savedSession] username]];
    [self.username becomeFirstResponder];
}

@end
