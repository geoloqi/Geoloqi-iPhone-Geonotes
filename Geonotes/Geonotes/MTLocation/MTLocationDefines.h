//
//  MTLocationDefines.h
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


// The location status determines in which Status regarding to Core Location the application
// currently is, whether it is idle, searching for a location, receiving locations or receiving heading information
typedef enum {
    MTUserTrackingModeNone = 0,                     // Currently Idle
    MTUserTrackingModeFollow,                       // Currently receiving location updates
    MTUserTrackingModeFollowWithHeading,            // Currently receiving heading updates
    MTUserTrackingModeSearching                     // Currently determining Location
} MTUserTrackingMode;

// number of defines stati
#define kMTUserTrackingModeCount    4

// legacy __attribute__((deprecated))
#define MTLocationStatus                            MTUserTrackingMode
#define MTLocationStatusIdle                        MTUserTrackingModeNone
#define MTLocationStatusReceivingLocationUpdates    MTUserTrackingModeFollow
#define MTLocationStatusReceivingHeadingUpdates     MTUserTrackingModeFollowWithHeading
#define MTLocationStatusSearching                   MTUserTrackingModeSearching
#define kMTLocationStatusCount                      kMTUserTrackingModeCount


// thresholds to define good/medium/bad heading accuracy
#define kMTHeadingAccuracyLargeThreshold	45
#define kMTHeadingAccuracyMediumThreshold	30

// Notifications that are sent when BarButtonItem is used as LocationManager-Delegate
#define kMTLocationManagerDidUpdateToLocationFromLocation	@"kMTLocationManagerDidUpdateToLocationFromLocation"
#define kMTLocationManagerDidFailWithError					@"kMTLocationManagerDidFailWithError"
#define kMTLocationManagerDidUpdateHeading					@"kMTLocationManagerDidUpdateHeading"
#define kMTLocationManagerDidEnterRegion					@"kMTLocationManagerDidEnterRegion"
#define kMTLocationManagerDidExitRegion						@"kMTLocationManagerDidExitRegion"
#define kMTLocationManagerMonitoringDidFailForRegion		@"kMTLocationManagerMonitoringDidFailForRegion"
#define kMTLocationManagerDidChangeAuthorizationStatus		@"kMTLocationManagerDidChangeAuthorizationStatus"

#define kMTLocationManagerDidStopUpdatingHeading			@"kMTLocationManagerDidStopUpdatingHeading"
#define kMTLocationManagerDidStopUpdatingServices			@"kMTLocationManagerDidStopUpdatingServices"

// Keys for Notification UserInfo
#define kMTLocationLocationManagerKey                       @"locationManager"
#define kMTLocationNewLocationKey                           @"newLocation"
#define kMTLocationOldLocationKey                           @"oldLocation"
#define kMTLocationNewHeadingKey                            @"newHeading"
#define kMTLocationRegionKey                                @"region"
#define kMTLocationErrorKey                                 @"error"
#define kMTLocationAuthorizationStatusKey                   @"status"

// UIView Tags
#define kMTLocationGoogleBadgeTag   666
#define kMTLocationHeadingViewTag   667

// block-type of block that gets executed when location changes
typedef void (^mt_location_changed_block)(CLLocation *location);
typedef void (^mt_location_error_block)(NSError *error);

// Helper Functions for easier retreival of Notification UserInfos

NS_INLINE CLLocationManager* MTLocationGetLocationManager(NSNotification *notification) {
    return [notification.userInfo valueForKey:kMTLocationLocationManagerKey];
}

NS_INLINE CLLocation* MTLocationGetNewLocation(NSNotification *notification) {
    return [notification.userInfo valueForKey:kMTLocationNewLocationKey];
}

NS_INLINE CLLocation* MTLocationGetOldLocation(NSNotification *notification) {
    return [notification.userInfo valueForKey:kMTLocationOldLocationKey];
}

NS_INLINE CLHeading* MTLocationGetNewHeading(NSNotification *notification) {
    return [notification.userInfo valueForKey:kMTLocationNewHeadingKey];
}

NS_INLINE CLRegion* MTLocationGetRegion(NSNotification *notification) {
    return [notification.userInfo valueForKey:kMTLocationRegionKey];
}

NS_INLINE NSError* MTLocationGetError(NSNotification *notification) {
    return [notification.userInfo valueForKey:kMTLocationErrorKey];
}

NS_INLINE CLAuthorizationStatus MTLocationGetAuthorizationStatus(NSNotification *notification) {
    return (CLAuthorizationStatus)[[notification.userInfo valueForKey:kMTLocationAuthorizationStatusKey] intValue];
}
