//
//  LQSettingsViewController.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQSettingsViewController.h"

@interface LQSettingsViewController ()

//- (LQSettingsActionSheetDelegate *)actionDelegate;

@end

@implementation LQSettingsViewController

@synthesize // scrollView,
            locationTracking/*,
            allowPublicGeonotes,
            usernameLabel,
            username,
            saveUsername,
            savingIndicator*/;

// @synthesize publicGeonoteURL, publicGeonoteURLLabel;

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
/*    
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
*/
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

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
        {
            cell = [self locationUpdateSettingCell:tableView];
            break;
        }
        
        case 1:
            // enable on reboot?
            break;
            
        case 2:
            // something
            break;
            
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;//3;
}

- (UITableViewCell *)locationUpdateSettingCell:(UITableView *)tableView
{
    static NSString *switchCellIdentifier = @"SwitchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:switchCellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:switchCellIdentifier];
    
    cell.textLabel.text = @"Enable location";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UISwitch *locationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = locationSwitch;
    [locationSwitch setOn:([[LQTracker sharedTracker] profile] != LQTrackerProfileOff) animated:NO];
    [locationSwitch addTarget:self action:@selector(locationTrackingWasSwitched:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

/*
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
*/

#pragma mark - IBActions

- (IBAction)locationTrackingWasSwitched:(UISwitch *)sender
{
    [[LQTracker sharedTracker] setProfile:(sender.on ? LQTrackerProfileAdaptive : LQTrackerProfileOff)];
}

/*
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
    [self.savingIndicator startAnimating];
    [session runAPIRequest:[session requestWithMethod:@"POST" path:@"/account/set_username" payload:params]
                completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
                    [self.savingIndicator stopAnimating];
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
                        
                        // clear this so it gets rebuilt
                        actionDelegate = nil;
                        
                        [LQSession sessionWithAccessToken:session.accessToken];
                    }
                }
     ];
}

#pragma mark -

- (IBAction)publicGeonoteURLWasTapped:(UIButton *)sender
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@""
                                                        delegate:[self actionDelegate]
                                               cancelButtonTitle:@"OK"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Email", @"Text", @"Copy", nil];
    [action showFromTabBar:self.tabBarController.tabBar];
}

- (LQSettingsActionSheetDelegate *)actionDelegate
{
    if (actionDelegate) return actionDelegate;
    return actionDelegate = [[LQSettingsActionSheetDelegate alloc] initWithUsername:[[LQSession savedSession] username]
                                                                  andViewController:self];
}

#pragma mark -

- (void)togglePublicGeonoteFields:(BOOL)show
{
    self.publicGeonoteURL.hidden = !show;
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
    [self.publicGeonoteURL setTitle:[NSString stringWithFormat:@"http://loqi.me/%@", _username]
                           forState:UIControlStateNormal];
    self.username.text = _username;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self populatePublicGeonoteFields:[[LQSession savedSession] username]];
    [self.username becomeFirstResponder];
}
*/

@end
