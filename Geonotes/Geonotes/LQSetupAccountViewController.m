//
//  LQSetupAccountViewController.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/19/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQSetupAccountViewController.h"

@interface LQSetupAccountViewController ()

@end

@implementation LQSetupAccountViewController

@synthesize tableView = _tableView, emailAddressField;

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
    
//	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
//																			  style:UIBarButtonItemStyleDone 
//																			 target:self 
//																			 action:@selector(setupAccount)];
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

- (void)resetField
{
    self.emailAddressField.text = nil;
    [buttonTableViewCell setButtonState:NO];
}

- (BOOL)isComplete;
{
	return emailAddressField.text.length > 0;
}

- (IBAction)cancel
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction)setupAccount
{
    [self.emailAddressField resignFirstResponder];
    LQSession *session = [LQSession savedSession];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:emailAddressField.text, @"email", nil];
    NSURLRequest *r = [session requestWithMethod:@"POST" path:@"/account/anonymous_set_email" payload:params];
    [session runAPIRequest:r
                completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
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
                        // hack to get new session data
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.geoloqi.LQUserID"];
                        [LQSession setSavedSession:[LQSession sessionWithAccessToken:session.accessToken]];
                        // [self cancel];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
    ];
}

- (IBAction)textFieldDidEditChanged:(UITextField *)textField
{
//    self.navigationItem.rightBarButtonItem.enabled = [self isComplete];
    [buttonTableViewCell setButtonState:[self isComplete]];
}

#pragma mark - table view datasource

- (NSString *)tableView:(UITableView *)inTableView titleForHeaderInSection:(NSInteger)section;
{
    NSString *title;
    switch (section) {
        case 0:
            title = NSLocalizedString(@"Create your Geoloqi account", nil);
            break;
    }
    return title;
}

- (NSString *)tableView:(UITableView *)inTableView titleForFooterInSection:(NSInteger)section;
{
    NSString *footer;
    switch (section) {
        case 0:
            footer = NSLocalizedString(@"You'll get an email to complete the setup.", nil);
            break;
    }
    return footer;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	UITableViewCell *cell;
    NSString *cellId;
    switch (indexPath.section) {
        case 0:
            cellId = @"email";
            cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
            cell.accessoryView = emailAddressField;
            cell.detailTextLabel.text = NSLocalizedString(@"Email", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case 1:
            buttonTableViewCell = [LQButtonTableViewCell buttonTableViewCellWithTitle:@"Save"
                                                                                owner:self
                                                                              enabled:[self isComplete]
                                                                               target:self
                                                                             selector:@selector(setupAccount)];
            cell = buttonTableViewCell;
            break;
    }

	return cell;
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
	if ([self isComplete]) [self setupAccount];
	return YES;
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [emailAddressField becomeFirstResponder];
}

@end
