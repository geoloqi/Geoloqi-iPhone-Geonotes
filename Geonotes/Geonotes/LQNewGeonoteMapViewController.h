//
//  LQNewGeonoteMapViewController.h
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/27/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LQGeonote.h"
#import <ArcGIS/ArcGIS.h>
#import "LQLocateMeButton.h"

@class LQNewGeonoteMapViewController;

@interface LQNewGeonoteMapViewController : UIViewController <LQLocateMeButtonDelegate>

@property (nonatomic, strong) LQGeonote *geonote;
@property (strong, nonatomic) IBOutlet AGSMapView *agsMapView;

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *locateMeBarButtonItem;

@property (nonatomic, strong) IBOutlet UIImageView *geonotePin;
@property (nonatomic, strong) IBOutlet UIImageView *geonotePinShadow;
@property (nonatomic, strong) IBOutlet UIImageView *geonoteTarget;

@property (strong, nonatomic) IBOutlet UIImageView *mapMarker;
@property (strong, nonatomic) IBOutlet UIImageView *mapMarkerShadow;
@property (strong, nonatomic) IBOutlet UIImageView *mapX;
- (IBAction)pickButtonWasTapped:(UIBarButtonItem *)pickButton;

@end
