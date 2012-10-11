//
//  LQNewGeonoteMapViewController.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/27/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQNewGeonoteMapViewController.h"

// which esri tiles to load into the map
#define BASEMAP_URL @"http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"

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
const float LQZoomSpanDegreesDelta = 0.01;

// key to watch on the AGSMapView object for pinUp animations
static NSString *const LQPinUpObserverKeyPath = @"self.agsMapView.visibleArea";

#pragma mark - initializers / notification handlers

@synthesize toolbar;
@synthesize locateMeBarButtonItem = _locateMeBarButtonItem;
@synthesize geonotePin;
@synthesize geonotePinShadow;
@synthesize geonoteTarget;
@synthesize mapMarker;
@synthesize mapMarkerShadow;
@synthesize mapX;

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

- (void)viewWillAppear:(BOOL)animated
{
    [self centerMapMarker];
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
    [self setMapMarker:nil];
    [self setMapMarkerShadow:nil];
    [self setMapX:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - helpers

- (void)zoomMapToLocation:(CLLocation *)location
{
    if (location) {
        double xmin = location.coordinate.longitude - LQZoomSpanDegreesDelta;
        double ymin = location.coordinate.latitude - LQZoomSpanDegreesDelta;
        double xmax = location.coordinate.longitude + LQZoomSpanDegreesDelta;
        double ymax = location.coordinate.latitude + LQZoomSpanDegreesDelta;

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

- (void)centerMapMarker
{
//    NSLog(@"mapview height: %f", self.agsMapView.frame.size.height);
    CGRect mapXFrame = CGRectMake(((self.agsMapView.frame.size.width / 2) - (self.mapX.frame.size.width / 2)),
                                  ((self.agsMapView.frame.size.height / 2) - (self.mapX.frame.size.height / 2)),
                                  self.mapX.frame.size.width, self.mapX.frame.size.height);
    
    CGPoint mapMarkerOrigin = CGPointMake(((self.agsMapView.frame.size.width / 2) - (self.mapMarker.frame.size.width / 2)),
                                          ((self.agsMapView.frame.size.height / 2) - self.mapMarker.frame.size.height));

    CGRect mapMarkerFrame = CGRectMake(mapMarkerOrigin.x, mapMarkerOrigin.y,
                                       self.mapMarker.frame.size.width, self.mapMarker.frame.size.height);

    CGRect mapMarkerShadowFrame = CGRectMake(mapMarkerOrigin.x + 1, mapMarkerOrigin.y + 3,
                                             self.mapMarkerShadow.frame.size.width, self.mapMarkerShadow.frame.size.height);
    
    [self setFrame:mapXFrame forView:self.mapX];
    [self setFrame:mapMarkerFrame forView:self.mapMarker];
    [self setFrame:mapMarkerShadowFrame forView:self.mapMarkerShadow];
}

- (void)setFrame:(CGRect)frame forView:(UIView *)view
{
//    NSLog(@"old frame = %f x %f", view.frame.origin.x, view.frame.origin.y);
    view.frame = frame;
//    NSLog(@"new frame = %f x %f", view.frame.origin.x, view.frame.origin.y);
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
            gps.autoPanMode = AGSGPSAutoPanModeOff;
            break;
        case LQLocateMeButtonStateTracking:
            gps.wanderExtentFactor = 0.0;
            gps.autoPanMode = AGSGPSAutoPanModeDefault;
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
