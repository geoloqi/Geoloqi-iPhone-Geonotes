//
//  MTLocateMeBarButtonItem.h
//
//  Created by Matthias Tretter on 21.01.11.
//  Copyright (c) 2009-2012  Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MTLocationDefines.h"

@class MKMapView;
@class MTLocateMeButton;
@protocol MTLocateMeButtonDelegate;


@interface MTLocateMeBarButtonItem : UIBarButtonItem 

@property (nonatomic, assign) MTUserTrackingMode trackingMode;
@property (nonatomic, assign) BOOL headingEnabled;
@property (nonatomic, unsafe_unretained) id<MTLocateMeButtonDelegate> delegate;


// initializer
- (id)initWithMapView:(MKMapView *)mapView;
- (id)initWithTrackingMode:(MTUserTrackingMode)trackingMode startListening:(BOOL)startListening;
- (id)initWithTrackingMode:(MTUserTrackingMode)trackingMode;

// re-direct setting of location status to MTLocateMeButton
- (void)setTrackingMode:(MTUserTrackingMode)trackingMode animated:(BOOL)animated;
// re-direct target-action to MTLocateMeButton
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

// start/stop listening to location and heading updates
- (void)startListeningToLocationUpdates;
- (void)stopListeningToLocationUpdates;

// sets the right frame when used in a UINavigationBar for portrait/landscape
- (void)setFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end
