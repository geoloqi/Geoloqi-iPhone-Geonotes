//
//  LQLocateMeButton.h
//  Geonotes
//
//  Created by Kenichi Nakamura on 10/9/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LQLocateMeButtonStateIdle,
    LQLocateMeButtonStateTracking
} LQLocateMeButtonState;

@protocol LQLocateMeButtonDelegate;

@interface LQLocateMeButton : UIButton

@property LQLocateMeButtonState trackingState;
@property id<LQLocateMeButtonDelegate> delegate;

- (LQLocateMeButton *)initWithButtonState:(LQLocateMeButtonState)buttonState;

@end

@protocol LQLocateMeButtonDelegate <NSObject>

- (void)locateMeButton:(LQLocateMeButton *)locateMeButton didChangeFromState:(LQLocateMeButtonState)fromState toState:(LQLocateMeButtonState)toState;

@end