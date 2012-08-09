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
#import <QuartzCore/QuartzCore.h>

@interface LQActivityItemViewController () {
    NSDictionary *storyData;
}
@end

@implementation LQActivityItemViewController

@synthesize scrollView, detailContainerView, titleTextView, linkLabel, mapView, bodyTextView, imageView, detailView;

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
    
    CGFloat originY = 0.0;

    if([storyData objectForKey:@"location"]) {
        // Center the map on the location and add a marker
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[[storyData objectForKey:@"location"] objectForKey:@"latitude"] floatValue], [[[storyData objectForKey:@"location"] objectForKey:@"longitude"] floatValue]);
        [self setMapLocation:center radius:[[[storyData objectForKey:@"location"] objectForKey:@"radius"] floatValue]];
        [mapView addAnnotation:[[LQBasicAnnotation alloc] initWithTitle:[[storyData objectForKey:@"location"] objectForKey:@"displayName"] andCoordinate:center]];

//        detailView.frame = CGRectMake(0.0, 130.0, self.scrollView.frame.size.width, detailView.frame.size.height);
        originY = 130.0;
    }// else {
        // Hide the map
//        detailView.frame = CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, detailView.frame.size.height);
//    }
    
    self.titleTextView.text = [storyData objectForKey:@"title"];
    self.bodyTextView.text = [[storyData objectForKey:@"object"] objectForKey:@"summary"];
    NSString *sourceURL = [[storyData objectForKey:@"object"] objectForKey:@"sourceURL"];
    if (![sourceURL isEqualToString:@""])
        self.linkLabel.text = [NSString stringWithFormat:@"Link: %@", sourceURL];
    else
        [self.linkLabel removeFromSuperview];

    NSString *imageURL;
    if(![[[[storyData objectForKey:@"actor"] objectForKey:@"image"] objectForKey:@"url"] isEqualToString:@""]) {
        imageURL = [[[storyData objectForKey:@"actor"] objectForKey:@"image"] objectForKey:@"url"];
    } else if(![[[[storyData objectForKey:@"generator"] objectForKey:@"image"] objectForKey:@"url"] isEqualToString:@""]) {
        imageURL = [[[storyData objectForKey:@"generator"] objectForKey:@"image"] objectForKey:@"url"];
    }
    if(![imageURL isEqualToString:@""]) {
        [self.imageView setImageWithURL:[NSURL URLWithString:imageURL]];
    }
    
    self.detailContainerView.layer.cornerRadius = 10.0;
    self.detailContainerView.layer.masksToBounds = YES;
    self.detailContainerView.layer.borderWidth = 1.0;
    self.detailContainerView.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0.67 alpha:1.0] CGColor];

    [self.scrollView addSubview:detailView];
    
    // can only get contentSize after view has been added
    CGFloat yToAddToFrameHeight = 0.0;
    CGFloat delta;
    CGRect frame;
    
    frame = self.titleTextView.frame;
    delta = self.titleTextView.contentSize.height - frame.size.height;
    yToAddToFrameHeight += delta;
    frame.size.height += delta;
    self.titleTextView.frame = frame;

    frame = self.bodyTextView.frame;
    frame.origin.y += yToAddToFrameHeight;
    delta = self.bodyTextView.contentSize.height - frame.size.height;
    if (delta < -20.0) { delta += (fabs(delta + 20.0)); }
    yToAddToFrameHeight += delta;
    frame.size.height += delta;
    self.bodyTextView.frame = frame;
    
    frame = self.detailContainerView.frame;
    frame.size.height += yToAddToFrameHeight;
    self.detailContainerView.frame = frame;
    
    if (![sourceURL isEqualToString:@""]) {
        frame = self.linkLabel.frame;
        frame.origin.y += yToAddToFrameHeight;
        self.linkLabel.frame = frame;
    }
    
    detailView.frame = CGRectMake(0.0, originY, self.scrollView.frame.size.width, (self.scrollView.frame.size.height + yToAddToFrameHeight));
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.detailView.frame.size.height);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)loadStory:(NSDictionary *)_storyData {
    storyData = _storyData;
    NSLog(@"storyData: %@", storyData);
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
