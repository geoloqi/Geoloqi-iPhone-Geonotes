//
//  LQActivityItemViewController.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/9/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQActivityItemViewController.h"
#import "LQBasicAnnotation.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LQActivityItemViewController () {
    NSDictionary *storyData;
}
@end

@implementation LQActivityItemViewController

@synthesize titleLabel, dateLabel, mapView, textView, imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    if([storyData objectForKey:@"location"]) {
        // Center the map on the location and add a marker
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[[storyData objectForKey:@"location"] objectForKey:@"latitude"] floatValue], [[[storyData objectForKey:@"location"] objectForKey:@"longitude"] floatValue]);
        [self setMapLocation:center radius:[[[storyData objectForKey:@"location"] objectForKey:@"radius"] floatValue]];
        [mapView addAnnotation:[[LQBasicAnnotation alloc] initWithTitle:[[storyData objectForKey:@"location"] objectForKey:@"displayName"] andCoordinate:center]];
    } else {
        // Hide the map
        
    }
 
    self.titleLabel.text = [storyData objectForKey:@"title"];
    self.textView.text = [[storyData objectForKey:@"object"] objectForKey:@"summary"];
    self.dateLabel.text = [storyData objectForKey:@"displayDate"];

    NSString *imageURL;
    if(![[[[storyData objectForKey:@"actor"] objectForKey:@"image"] objectForKey:@"url"] isEqualToString:@""]) {
        imageURL = [[[storyData objectForKey:@"actor"] objectForKey:@"image"] objectForKey:@"url"];
    } else if(![[[[storyData objectForKey:@"generator"] objectForKey:@"image"] objectForKey:@"url"] isEqualToString:@""]) {
        imageURL = [[[storyData objectForKey:@"generator"] objectForKey:@"image"] objectForKey:@"url"];
    }
    if(![imageURL isEqualToString:@""]) {
        [self.imageView setImageWithURL:[NSURL URLWithString:imageURL]];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)loadStory:(NSDictionary *)_storyData {
    storyData = _storyData;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setMapLocation:(CLLocationCoordinate2D)center radius:(CGFloat)radius
{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, radius, radius);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

@end
