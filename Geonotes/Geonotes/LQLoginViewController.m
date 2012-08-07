//
//  LQLoginViewController.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/19/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQLoginViewController.h"

@interface LQLoginViewController ()

@end

@implementation LQLoginViewController

@synthesize tableView, settingsTableView, activityIndicator,
            emailAddressField, passwordField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSettingsTableView:(UITableView *)_settingsTableView
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.settingsTableView = _settingsTableView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Login", nil)
//																			  style:UIBarButtonItemStyleDone 
//																			 target:self 
//																			 action:@selector(loginToAccount)];
//	self.navigationItem.rightBarButtonItem.enabled = [self isComplete];
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

#pragma mark -

- (void)resetFields
{
    self.emailAddressField.text = nil;
    self.passwordField.text = nil;
    [self.emailAddressField becomeFirstResponder];
    [buttonTableViewCell setButtonState:NO];
}

- (BOOL)isComplete
{
    return emailAddressField.text.length > 0 && passwordField.text.length > 0;
}

- (IBAction)cancel
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction)loginToAccount
{
    [self.activityIndicator startAnimating];
    [self.emailAddressField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [LQSession requestSessionWithUsername:emailAddressField.text
                                 password:passwordField.text
                               completion:^(LQSession *session, NSError *error) {
                                   if (error) {
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                       message:[[error userInfo] objectForKey:@"error_description"]
                                                                                      delegate:self
                                                                             cancelButtonTitle:@"OK"
                                                                             otherButtonTitles:nil];
                                       [alert show];
                                   } else {
                                       [LQSession setSavedSession:session];
                                       [self updateDisplayName:^() {
                                           [self.settingsTableView reloadData];
                                           [self.activityIndicator stopAnimating];
                                           [self.navigationController popViewControllerAnimated:YES];
                                           [[[UIApplication sharedApplication] delegate] performSelector:@selector(refreshAllSubTableViews)];
                                       }];
                                   }
                               }];
}

- (IBAction)textFieldDidEditChanged:(UITextField *)textField
{
//    self.navigationItem.rightBarButtonItem.enabled = [self isComplete];
    [buttonTableViewCell setButtonState:[self isComplete]];
}

- (void)updateDisplayName:(void (^)())block
{
    LQSession *session = [LQSession savedSession];
    NSURLRequest *req = [session requestWithMethod:@"GET" path:@"/account/profile" payload:nil];
    [session runAPIRequest:req completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
                    [[NSUserDefaults standardUserDefaults] setObject:[responseDictionary objectForKey:@"display_name"]
                                                              forKey:LQDisplayNameUserDefaultsKey];
                    block();
                }];
}

#pragma mark - table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)inTableView titleForHeaderInSection:(NSInteger)section;
{
	return (section == 0) ? NSLocalizedString(@"Login to your Geoloqi account", nil) : nil;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
    int rows;
    switch (section) {
        case 0:
            rows = 2;
            break;
        case 1:
            rows = 1;
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        if (indexPath.row == 0) {
            cell.accessoryView = emailAddressField;
            cell.detailTextLabel.text = NSLocalizedString(@"Email", nil);
        } else if (indexPath.row == 1) {
            cell.accessoryView = passwordField;
            cell.detailTextLabel.text = NSLocalizedString(@"Password", nil);
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == 1) {
        buttonTableViewCell = [LQButtonTableViewCell buttonTableViewCellWithTitle:@"Login"
                                                                            owner:self
                                                                          enabled:[self isComplete]
                                                                           target:self
                                                                         selector:@selector(loginToAccount)];
        cell = buttonTableViewCell;
    }
	return cell;
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if (textField == emailAddressField) {
        [passwordField becomeFirstResponder];
    } else if (textField == passwordField && [self isComplete]) {
        [textField resignFirstResponder];
        [self loginToAccount];
    }
	return YES;
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [emailAddressField becomeFirstResponder];
}

@end
