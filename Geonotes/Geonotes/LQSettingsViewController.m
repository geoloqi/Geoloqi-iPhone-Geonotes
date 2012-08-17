//
//  LQSettingsViewController.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQSettingsViewController.h"
#import "LQPrivacyPolicyViewController.h"
#import "LQCreditsViewController.h"

@implementation LQSettingsViewController {
    NSArray *sectionHeaders;
    LQSetupAccountViewController *setupAccountViewController;
    LQLoginViewController *loginViewController;
    LQCreditsViewController *creditsViewController;
}

@synthesize locationTracking, navigationBar, tableView = _tableView,
            setupAccountViewController, loginViewController, privacyPolicyViewController,
            logoCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
        self.tabBarItem.image = [UIImage imageNamed:@"settings"];
        NSLog(@"Settings init");
        [[LQSession savedSession] log:@"Settings init"];
    }
    return self;
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"Settings viewDidLoad");
    [[LQSession savedSession] log:@"Settings viewDidLoad"];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[LQSession savedSession] log:@"Settings viewDidUnload"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View - Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows;
    switch (section) {
        // location
        case 0:
            rows = 1;
            break;
            
        // account
        case 1:
            rows = [LQSession savedSession].isAnonymous ? 2 : 1;
            break;
            
        // logging
        case 2:
            rows = 3;
            break;
            
        // about
        case 3:
            rows = 4;
            break;
        
        // logo
        case 4:
            rows = 1;
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    [[LQSession savedSession] log:[NSString stringWithFormat:@"Settings loading cell at indexPath %d x %d", indexPath.section, indexPath.row]];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell = [self locationUpdateCell];
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    if ([LQSession savedSession].isAnonymous)
                        cell = [self setupAccountCell];
                    else
                        cell = [self loginCell];
                    break;
                case 1:
                    cell = [self loginCell];
                    break;
            }
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell = [self enableLoggingCell];
                    break;
                case 1:
                    cell = [self emailLogCell];
                    break;
                case 2:
                    cell = [self clearLogCell];
                    break;
            }
            break;
            
        case 3:
            switch (indexPath.row) {
                case 0:
                    cell = [self privacyPolicyCell];
                    break;
                case 1:
                    cell = [self appVersionCell];
                    break;
                case 2:
                    cell = [self sdkVersionCell];
                    break;
                case 3:
                    cell = [self creditsCell];
                    break;
            }
            break;
        
        case 4:
            cell = [self logoCell];
            break;
        
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self sectionHeaders] count];
}

- (NSArray *)sectionHeaders
{
    if (sectionHeaders == nil)
        sectionHeaders = [NSArray arrayWithObjects:@"Location", @"Account", @"Logging", @"About", @"", nil];
    return sectionHeaders;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self sectionHeaders] objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footer;
    switch (section) {
        case 1:
            if ([LQSession savedSession].isAnonymous)
                footer = @"Logged in anonymously";
            else {
                NSString *displayName = [[NSUserDefaults standardUserDefaults] objectForKey:LQDisplayNameUserDefaultsKey];
                footer = [NSString stringWithFormat:@"Currently logged in as '%@'", displayName];
            }
            break;
        case 2:
            footer = @"Logging must be enabled to email the log";
            break;
    }
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat f = 44.0;
    if (indexPath.section == 4)
        f = 64.0;
    return f;
}

#pragma mark - Table View - Cells

- (UITableViewCell *)getCellForId:(NSString *)cellIdentifier
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    return cell;
}

#pragma mark -

- (UITableViewCell *)locationUpdateCell
{
    UITableViewCell *cell = [self getCellForId:@"locationUpdateCell"];
    cell.textLabel.text = @"Enable location";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UISwitch *locationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = locationSwitch;
    LQTracker *tracker = [LQTracker sharedTracker];
    LQTrackerProfile profile = [tracker profile];
    [locationSwitch setOn:(profile != LQTrackerProfileOff) animated:NO];
    [locationSwitch addTarget:self action:@selector(locationTrackingWasSwitched:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

#pragma mark -

- (UITableViewCell *)setupAccountCell
{
    UITableViewCell *cell = [self getCellForId:@"setupAccountCell"];
    cell.textLabel.text = @"Set up account";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)loginCell
{
    UITableViewCell *cell = [self getCellForId:@"loginCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"Log in to %@ account", ([LQSession savedSession].isAnonymous ? @"existing" : @"different")];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark -

- (UITableViewCell *)enableLoggingCell
{
    UITableViewCell *cell = [self getCellForId:@"enableLoggingCell"];
    cell.textLabel.text = @"Enable logging";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UISwitch *loggingSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = loggingSwitch;
    [loggingSwitch setOn:[[LQSession savedSession] fileLogging] animated:NO];
    [loggingSwitch addTarget:self action:@selector(fileLoggingWasSwitched:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (UITableViewCell *)emailLogCell
{
    UITableViewCell *cell = [self getCellForId:@"emailLogCell"];
    cell.textLabel.text = @"Email log";
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)clearLogCell
{
    UITableViewCell *cell = [self getCellForId:@"clearLogCell"];
    cell.textLabel.text = @"Clear log";
    return cell;
}

#pragma mark -

- (UITableViewCell *)privacyPolicyCell
{
    UITableViewCell *cell = [self getCellForId:@"privacyPolicyCell"];
    cell.textLabel.text = @"Privacy Policy";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)appVersionCell
{
    UITableViewCell *cell = [self getCellForId:@"appVersionCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"Version: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)sdkVersionCell
{
    UITableViewCell *cell = [self getCellForId:@"sdkVersionCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"SDK Version: %@", LQSDKVersionString];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)creditsCell
{
    UITableViewCell *cell = [self getCellForId:@"creditsCell"];
    cell.textLabel.text = @"Credits";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark -

- (UITableViewCell *)logoCell
{
    static NSString *logoCellId = @"logoCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:logoCellId];
    if (!cell) {
        [[NSBundle mainBundle] loadNibNamed:@"LQLogoCell" owner:self options:nil];
        cell = logoCell;
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

#pragma mark - Table View - Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 0:
                    if ([LQSession savedSession].isAnonymous)
                        [self setupAccountCellWasTapped];
                    else
                        [self loginCellWasTapped];                    
                    break;
                case 1:
                    [self loginCellWasTapped];                    
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 1:
                    [self emailLogCellWasTapped];
                    break;
                case 2:
                    [self clearLogCellWasTapped];
                    break;
            }
            break;

        case 3:
            switch (indexPath.row) {
                case 0:
                    [self privacyPolicyCellWasTapped];
                    break;
                case 3:
                    [self creditsCellWasTapped];
                    break;
            }
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setupAccountCellWasTapped
{
    [self.navigationController pushViewController:self.setupAccountViewController animated:YES];
}

- (void)anonymousBannerWasTapped
{
    if (self.navigationController.topViewController != self.setupAccountViewController) {
        [self.navigationController popViewControllerAnimated:NO];
        [self.navigationController pushViewController:self.setupAccountViewController animated:NO];
    }
}

- (void)loginCellWasTapped
{
    [self.navigationController pushViewController:self.loginViewController animated:YES];
}

- (void)privacyPolicyCellWasTapped
{
    if (self.privacyPolicyViewController == nil)
        self.privacyPolicyViewController = [LQPrivacyPolicyViewController new];
    [self.navigationController pushViewController:self.privacyPolicyViewController animated:YES];
}

- (void)creditsCellWasTapped
{
    if (creditsViewController == nil)
        creditsViewController = [LQCreditsViewController new];
    [self.navigationController pushViewController:creditsViewController animated:YES];
}

- (void)emailLogCellWasTapped
{
    LQSession *session = [LQSession savedSession];
    if ([session fileLogging])
        [session viewControllerDidRequestLogEmail:self];
}

- (void)clearLogCellWasTapped
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Clear log?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Clear"
                                                    otherButtonTitles: nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
        [[LQSession savedSession] clearLog];
}

#pragma mark - getters

- (LQSetupAccountViewController *)setupAccountViewController
{
    if (setupAccountViewController == nil) {
        self.setupAccountViewController = [[LQSetupAccountViewController alloc] initWithNibName:@"LQSetupAccountViewController"
                                                                                         bundle:[NSBundle mainBundle]
                                                                      andSettingsViewController:self];
    } else {
        [setupAccountViewController resetField];
    }
    return setupAccountViewController;
}

- (LQLoginViewController *)loginViewController
{
    if (loginViewController == nil) {
        self.loginViewController = [[LQLoginViewController alloc] initWithNibName:@"LQLoginViewController"
                                                                           bundle:[NSBundle mainBundle]
                                                             andSettingsTableView:_tableView
                                                        andSettingsViewController:self];
    } else {
        [loginViewController resetFields];
    }
    return loginViewController;
}

#pragma mark - IBActions

- (IBAction)locationTrackingWasSwitched:(UISwitch *)sender
{
    [[LQTracker sharedTracker] setProfile:(sender.on ? LQTrackerProfileAdaptive : LQTrackerProfileOff)];
}

- (IBAction)fileLoggingWasSwitched:(UISwitch *)sender
{
    [[LQSession savedSession] setFileLogging:sender.on];
    
}

#pragma mark -

- (void)switchFrom:(UIViewController *)from to:(UIViewController *)to
{
    [from.navigationController popViewControllerAnimated:NO];
    [self.navigationController pushViewController:to animated:YES];
}

@end
