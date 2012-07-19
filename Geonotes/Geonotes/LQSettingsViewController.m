//
//  LQSettingsViewController.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQSettingsViewController.h"

@implementation LQSettingsViewController

@synthesize locationTracking, navigationBar,
            setupAccountViewController, loginViewController, privacyPolicyViewController;

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

#pragma mark - Table View - Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows;
    switch (section) {
        case 0:
            rows = 1;
            break;
            
        case 1:
            rows = [LQSession savedSession].isAnonymous ? 2 : 1;
            break;
            
        case 2:
            rows = 3;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
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
                    cell = [self privacyPolicyCell];
                    break;
                case 1:
                    cell = [self appVersionCell];
                    break;
                case 2:
                    cell = [self sdkVersionCell];
                    break;
            }
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
        sectionHeaders = [NSArray arrayWithObjects:@"Location", @"Account", @"About", nil];
    return sectionHeaders;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self sectionHeaders] objectAtIndex:section];
}

#pragma mark - Table View - Cells

- (UITableViewCell *)locationUpdateCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.textLabel.text = @"Enable location";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UISwitch *locationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = locationSwitch;
    [locationSwitch setOn:([[LQTracker sharedTracker] profile] != LQTrackerProfileOff) animated:NO];
    [locationSwitch addTarget:self action:@selector(locationTrackingWasSwitched:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (UITableViewCell *)setupAccountCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"Setup account";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)loginCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = [NSString stringWithFormat:@"Login to %@ account", ([LQSession savedSession].isAnonymous ? @"existing" : @"different")];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)privacyPolicyCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"Privacy Policy";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)appVersionCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = [NSString stringWithFormat:@"Version: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)sdkVersionCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = [NSString stringWithFormat:@"SDK Version: %@", LQSDKVersionString];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            if (indexPath.row == 0)
                [self privacyPolicyCellWasTapped];
            break;
    }
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}

- (void)setupAccountCellWasTapped
{
    if (self.setupAccountViewController == nil) {
        self.setupAccountViewController = [[LQSetupAccountViewController alloc] initWithNibName:@"LQSetupAccountViewController"
                                                                                         bundle:[NSBundle mainBundle]];
    } else {
        UINavigationController *nc = (UINavigationController *)self.setupAccountViewController;
        LQSetupAccountViewController *savc = [[nc viewControllers] objectAtIndex:0];
        [savc resetField];
    }
    [self presentModalViewController:self.setupAccountViewController animated:YES];
}

- (void)loginCellWasTapped
{
    if (self.loginViewController == nil) {
        self.loginViewController = [[LQLoginViewController alloc] initWithNibName:@"LQLoginViewController"
                                                                           bundle:[NSBundle mainBundle]];
    } else {
        UINavigationController *nc = (UINavigationController *)self.loginViewController;
        LQLoginViewController *lvc = [[nc viewControllers] objectAtIndex:0];
        [lvc resetFields];
    }
    [self presentModalViewController:self.loginViewController animated:YES];
}

- (void)privacyPolicyCellWasTapped
{
    if (self.privacyPolicyViewController == nil) {
        self.privacyPolicyViewController = [[LQPrivacyPolicyViewController alloc] initWithNibName:@"LQPrivacyPolicyViewController"
                                                                                  bundle:[NSBundle mainBundle]];
    }
    [self presentModalViewController:self.privacyPolicyViewController animated:YES];
}

#pragma mark - IBActions

- (IBAction)locationTrackingWasSwitched:(UISwitch *)sender
{
    [[LQTracker sharedTracker] setProfile:(sender.on ? LQTrackerProfileAdaptive : LQTrackerProfileOff)];
}

@end
