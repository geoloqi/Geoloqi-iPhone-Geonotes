//
//  LQSettingsActionSheetDelegate.h
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/16/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface LQSettingsActionSheetDelegate : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    NSString *message;
    NSURL *publicGeonoteURL;
    UIViewController *viewController;
}

- (LQSettingsActionSheetDelegate *)initWithUsername:(NSString *)_username
                                  andViewController:(UIViewController *)_viewController;

@end
