//
//  LQActivityItemViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/9/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LQActivityItemViewController : UIViewController

@property IBOutlet UILabel *titleLabel;
@property IBOutlet UILabel *dateLabel;
@property IBOutlet UITextView *textView;
@property IBOutlet MKMapView *mapView;
@property IBOutlet UIImageView *imageView;

@property IBOutlet UIView *detailView;

- (void)loadStory:(NSDictionary *)storyData;

- (void)setMapLocation:(CLLocationCoordinate2D)center radius:(CGFloat)radius;

@end
