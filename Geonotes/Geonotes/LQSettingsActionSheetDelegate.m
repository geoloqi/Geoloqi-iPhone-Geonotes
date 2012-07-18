//
//  LQSettingsActionSheetDelegate.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/16/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQSettingsActionSheetDelegate.h"

@interface LQSettingsActionSheetDelegate ()

-(void)emailPublicGeonoteURLToContact;
-(void)textPublicGeonoteURLToContact;
-(void)copyPublicGeonoteURLToPasteboard;

@end

@implementation LQSettingsActionSheetDelegate

-(LQSettingsActionSheetDelegate *)initWithUsername:(NSString *)_username andViewController:(UIViewController *)_viewController
{
    if (self = [super init]) {
        publicGeonoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://loqi.me/%@", _username]];
        message = [NSString stringWithFormat:@"Leave me a Geonote with the following URL: %@", publicGeonoteURL];
        viewController = _viewController;
    }
    return self;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self emailPublicGeonoteURLToContact];
            break;
        case 1:
            [self textPublicGeonoteURLToContact];
            break;
        case 2:
            [self copyPublicGeonoteURLToPasteboard];
            break;
    }
}

#pragma mark -

-(void)emailPublicGeonoteURLToContact
{
    MFMailComposeViewController *mailer = [MFMailComposeViewController new];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:@"Geonote URL"];
    [mailer setMessageBody:message isHTML:NO];
    [viewController presentModalViewController:mailer animated:YES];
}

-(void)textPublicGeonoteURLToContact
{
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
	if (messageClass != nil) {
		// We must always check whether the current device is configured for sending SMSs
		if([MFMessageComposeViewController canSendText]) {
			MFMessageComposeViewController *mailer = [[MFMessageComposeViewController alloc] init];
			mailer.messageComposeDelegate = self;
			[mailer setBody:message];
			[viewController presentModalViewController:mailer animated:YES];
		} else {
			// SMS is not configured, (i.e. on an iPod touch or in the simulator), launch the SMS app
			[self launchMessageAppOnDevice:message];
		}
	} else {
		// pre iOS 4, so just open the app
		[self launchMessageAppOnDevice:message];
	}
}

-(void)copyPublicGeonoteURLToPasteboard
{
    [[UIPasteboard generalPasteboard] setString:[publicGeonoteURL absoluteString]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copied"
                                                    message:@"Your public Geonote URL has been copied."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark -

-(void)launchMessageAppOnDevice:(NSString *)body {
	[[UIPasteboard generalPasteboard] setString:body];
	NSString *sms = [NSString stringWithFormat:@"sms:?body=%@", body];
	sms = [sms stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:sms]];
}

#pragma mark -

-(void)messageComposeViewController:(MFMessageComposeViewController*)messageController
                didFinishWithResult:(MessageComposeResult)result {
    NSLog(@"messageComposeViewController:didFinishWithResult:");
    switch (result)
    {
        case MessageComposeResultCancelled:
			[viewController dismissModalViewControllerAnimated:YES];
            break;
        case MessageComposeResultSent:
			[viewController dismissModalViewControllerAnimated:YES];
            break;
        case MessageComposeResultFailed:
            NSLog(@"message compose failed");
			[viewController dismissModalViewControllerAnimated:YES];
            break;
        default:
			[viewController dismissModalViewControllerAnimated:YES];
            break;
    }

}

-(void)mailComposeController:(MFMailComposeViewController*)mailController
		  didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError*)error {
    NSLog(@"mailComposeController:didFinishWithResult:");
    switch (result)
    {
        case MFMailComposeResultCancelled:
			[viewController dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSaved:
			[viewController dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSent:
			[viewController dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"mail compose failed: %@", error);
			[viewController dismissModalViewControllerAnimated:YES];
            break;
        default:
			[viewController dismissModalViewControllerAnimated:YES];
            break;
    }
}


@end
