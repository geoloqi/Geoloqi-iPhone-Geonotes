//
//  LQLocateMeButton.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 10/9/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQLocateMeButton.h"

#define IDLE_BG_IMAGE        @"LocateMeButton"
#define TRACKING_BG_IMAGE    @"LocateMeButtonTrackingPressed"
#define LOCATION_ARROW_IMAGE @"Location"

#define BUTTON_VIEW_INSET 5.0

@implementation LQLocateMeButton {
    UIImage *idleBackgroundImage;
    UIImage *trackingBackgroundImage;
    UIImageView *buttonImageView;
}

@synthesize trackingState;
@synthesize delegate;

- (LQLocateMeButton *)initWithButtonState:(LQLocateMeButtonState)buttonState
{
    self = [self initWithFrame:CGRectZero];
    self.trackingState = buttonState;
    [self setBackgroundImage];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    idleBackgroundImage =     [UIImage imageNamed:IDLE_BG_IMAGE];
    trackingBackgroundImage = [UIImage imageNamed:TRACKING_BG_IMAGE];
    
    frame = CGRectMake(frame.origin.x, frame.origin.y,
                       idleBackgroundImage.size.width,
                       idleBackgroundImage.size.height);
    
    self = [super initWithFrame:frame];
    if (self) {

        CGRect buttonViewFrame = CGRectInset(self.bounds, BUTTON_VIEW_INSET, BUTTON_VIEW_INSET);
        buttonImageView = [[UIImageView alloc] initWithFrame:buttonViewFrame];
        buttonImageView.contentMode = UIViewContentModeScaleAspectFit;
		buttonImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        buttonImageView.image = [UIImage imageNamed:LOCATION_ARROW_IMAGE];
        
        [self addSubview:buttonImageView];
        [self addTarget:self action:@selector(trackingModeToggled:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)trackingModeToggled:(LQLocateMeButton *)button
{
    LQLocateMeButtonState oldState = trackingState;
    switch (trackingState) {
        case LQLocateMeButtonStateIdle:
            trackingState = LQLocateMeButtonStateTracking;
            break;
            
        case LQLocateMeButtonStateTracking:
            trackingState = LQLocateMeButtonStateIdle;
            break;
    }
    [self setBackgroundImage];
    [self.delegate locateMeButton:self didChangeFromState:oldState toState:trackingState];
}

- (void)setBackgroundImage
{
    [self setBackgroundImageForState:trackingState];
}

- (void)setBackgroundImageForState:(LQLocateMeButtonState)buttonState
{
    switch (buttonState) {
        case LQLocateMeButtonStateIdle:
            [self setImage:idleBackgroundImage forState:UIControlStateNormal];
            break;
            
        case LQLocateMeButtonStateTracking:
            [self setImage:trackingBackgroundImage forState:UIControlStateNormal];
            break;
    }
}

@end
