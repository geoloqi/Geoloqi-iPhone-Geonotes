//
//  LQNewGeonoteMapViewController.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/27/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQNewGeonoteMapViewController.h"

// which esri tiles to load into the map
#define BASEMAP_URL @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"

@implementation LQNewGeonoteMapViewController {
    BOOL pinUp;
}

#pragma mark - consts

// floor of geonote radius as determined by visiable map area
const float LQMinimumGeonoteRadius = 150.0;

// how far the pin travels vertically
const float LQPinYDelta = 30;

// how far the pin's shadow travels diagonally
const float LQPinShadowXDelta = 10;
const float LQPinShadowYDelta = 20;

// how long the animation of the pin & its shadow takes
const float LQPinAnimationDuration = 0.2;

// how many degrees of buffer around the center location to show on the map intially
const float LQZoomSpanDegreesDelta = 0.025;

// key to watch on the AGSMapView object for pinUp animations
static NSString *const LQPinUpObserverKeyPath = @"self.agsMapView.visibleArea";

#pragma mark - initializers / notification handlers

@synthesize toolbar;
@synthesize locateMeBarButtonItem = _locateMeBarButtonItem;
@synthesize geonotePin;
@synthesize geonotePinShadow;
@synthesize geonoteTarget;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.rightBarButtonItem = [self pickButton];
        pinUp = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LQLocateMeButtonState buttonState = self.agsMapView.gps.enabled ? LQLocateMeButtonStateTracking : LQLocateMeButtonStateIdle;
    LQLocateMeButton *locateMeButton = [[LQLocateMeButton alloc] initWithButtonState:buttonState];
    locateMeButton.delegate = self;
    self.locateMeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:locateMeButton];
    
    [self.toolbar setItems:[NSArray arrayWithObjects:self.locateMeBarButtonItem, nil] animated:NO];

    self.agsMapView.wrapAround = YES;
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:BASEMAP_URL]];
    [self.agsMapView addMapLayer:tiledLayer withName:@"Tiled Layer"];
    
    [self zoomMapToLocation:[[[CLLocationManager alloc] init] location]];
    
    [self addObserver:self forKeyPath:LQPinUpObserverKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropGeonotePin) name:@"MapDidEndPanning" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropGeonotePin) name:@"MapDidEndZooming" object:nil];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:LQPinUpObserverKeyPath];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:LQPinUpObserverKeyPath]) {
        [self liftGeonotePin];
    }
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

#pragma mark - helpers

- (void)zoomMapToLocation:(CLLocation *)_location
{
    if (_location) {
        double xmin = _location.coordinate.longitude - LQZoomSpanDegreesDelta;
        double ymin = _location.coordinate.latitude - LQZoomSpanDegreesDelta;
        double xmax = _location.coordinate.longitude + LQZoomSpanDegreesDelta;
        double ymax = _location.coordinate.latitude + LQZoomSpanDegreesDelta;

        AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:xmin
                                                         ymin:ymin
                                                         xmax:xmax
                                                         ymax:ymax
                                             spatialReference:[AGSSpatialReference wgs84SpatialReference]];
        
        [self.agsMapView zoomToEnvelope:envelope animated:YES];
    }
}

- (void)setGeonotePositionFromMapCenter
{
    AGSEnvelope *visibleEnvelope = self.agsMapView.visibleArea.envelope;
    float latitudeDelta = fabs(visibleEnvelope.ymax - visibleEnvelope.ymin);
    // 111.0 km/degree of latitude * 1000 m/km * current delta * 20% of the half-screen width
    CGFloat desiredRadius = 111.0 * 1000 * latitudeDelta * 0.2;
    self.geonote.radius = desiredRadius < LQMinimumGeonoteRadius ? LQMinimumGeonoteRadius : desiredRadius;
    
    AGSPoint *center = [self.agsMapView toMapPoint:self.agsMapView.center];
    self.geonote.location = [[CLLocation alloc] initWithLatitude:center.y longitude:center.x];
}

#pragma mark - ui element creators

- (UIBarButtonItem *)pickButton
{
    UIBarButtonItem *pick = [[UIBarButtonItem alloc] initWithTitle:@"Pick"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(pickButtonWasTapped:)];
    pick.tintColor = [UIColor blueColor];
    return pick;
}

#pragma mark - ui actions

- (IBAction)pickButtonWasTapped:(UIBarButtonItem *)pickButton
{
    [self setGeonotePositionFromMapCenter];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - LQLocateMeButtonDelegate

- (void)locateMeButton:(LQLocateMeButton *)locateMeButton didChangeFromState:(LQLocateMeButtonState)fromState toState:(LQLocateMeButtonState)toState
{
    AGSGPS *gps = self.agsMapView.gps;
    switch (toState) {
        case LQLocateMeButtonStateIdle:
            [gps stop];
            gps.autoPanMode = NO;
            break;
        case LQLocateMeButtonStateTracking:
            gps.autoPanMode = YES;
            [gps start];
            break;
    }
}

#pragma mark - animations

- (void)liftGeonotePin
{
    if (!pinUp) {
        self.geonoteTarget.hidden = NO;
        [UIView beginAnimations:@"" context:NULL];
        self.geonotePin.center = (CGPoint) {
            self.geonotePin.center.x,
            (self.geonotePin.center.y - LQPinYDelta)
        };
        self.geonotePinShadow.center = (CGPoint) {
            (self.geonotePinShadow.center.x + LQPinShadowXDelta),
            (self.geonotePinShadow.center.y - LQPinShadowYDelta)
        };
        [UIView setAnimationDuration:LQPinAnimationDuration];
        [UIView setAnimationDelay:UIViewAnimationCurveEaseOut];
        [UIView commitAnimations];
        pinUp = YES;
    }
}

- (void)dropGeonotePin
{
    if (pinUp) {
        self.geonoteTarget.hidden = YES;
        [UIView beginAnimations:@"" context:NULL];
        self.geonotePin.center = (CGPoint) {
            self.geonotePin.center.x,
            (self.geonotePin.center.y + LQPinYDelta)
        };
        self.geonotePinShadow.center = (CGPoint) {
            (self.geonotePinShadow.center.x - LQPinShadowXDelta),
            (self.geonotePinShadow.center.y + LQPinShadowYDelta)
        };
        [UIView setAnimationDuration:LQPinAnimationDuration];
        [UIView setAnimationDelay:UIViewAnimationCurveEaseIn];
        [UIView commitAnimations];
        
        pinUp = NO;
    }
}

@end
