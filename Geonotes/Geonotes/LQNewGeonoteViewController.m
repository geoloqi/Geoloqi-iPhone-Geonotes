//
//  LQNewGeonoteViewController.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/18/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQNewGeonoteViewController.h"

@interface LQNewGeonoteViewController ()

- (UIBarButtonItem *)cancelButton;
- (UIBarButtonItem *)saveButton;

@end

@implementation LQNewGeonoteViewController

@synthesize tableView = _tableView,
            geonoteTextView,
            cancelButton, saveButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"New Geonote";
        self.navigationItem.leftBarButtonItem = [self cancelButton];
        self.navigationItem.rightBarButtonItem = [self saveButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [geonoteTextView becomeFirstResponder];
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

- (UIBarButtonItem *)cancelButton
{
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(cancelButtonWasTapped:)];
    return cancel;
}

- (UIBarButtonItem *)saveButton
{
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(saveButtonWasTapped:)];
    save.tintColor = [UIColor blueColor];
    save.enabled = NO;
    return save;
}

#pragma mark -

- (IBAction)cancelButtonWasTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonWasTapped:(id)sender
{
    
}

- (BOOL) isSaveable
{
    return geonoteTextView.text.length > 0 &&
           geonoteTextView.text.length <= kLQGeonoteTotalCharacterCount &&
           geonoteLocation != nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
            if (mapViewController == nil)
                mapViewController = [[LQNewGeonoteMapViewController alloc] init];
            [self.navigationController pushViewController:mapViewController animated:YES];
            break;
    }
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat f;
    switch (indexPath.section) {
        case 0:
            f = 180;
            break;
        case 1:
            f = 44;
            break;
    }
    return f;
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[NSArray alloc] initWithObjects:nil, @"Location", nil];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    switch (indexPath.section) {
        case 0:
        {
            CGRect textViewRect = CGRectMake(10, 10, 280, 150);
            geonoteTextView = [[UITextView alloc] initWithFrame:textViewRect];
            geonoteTextView.font = [UIFont systemFontOfSize:16];
            geonoteTextView.returnKeyType = UIReturnKeyDone;
            [geonoteTextView setDelegate:self];
//            cell.backgroundColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:geonoteTextView];
            
            CGRect characterCountRect = CGRectMake(270, 160, 20, 18);
            characterCount = [[UILabel alloc] initWithFrame:characterCountRect];
            characterCount.text = [NSString stringWithFormat:@"%d", kLQGeonoteTotalCharacterCount];
            characterCount.textAlignment = UITextAlignmentRight;
            characterCount.font = [UIFont systemFontOfSize:10];
            [cell.contentView addSubview:characterCount];
            
            break;
        }
            
        case 1:
            cell.textLabel.text = @"Pick Location";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    switch (section) {
        case 0:
            break;
        case 1:
            header = @"Location";
            break;
    }
    return header;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger chars = kLQGeonoteTotalCharacterCount - geonoteTextView.text.length;
    if (chars < 0)
        characterCount.textColor = [UIColor redColor];
    else
        characterCount.textColor = [UIColor darkTextColor];
    characterCount.text = [NSString stringWithFormat:@"%d", chars];
    saveButton.enabled = [self isSaveable];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL should = NO;
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    } else {
        should = YES;
    }
    return should;
}

@end
