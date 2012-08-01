//
//  LQGeonote.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/30/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQGeonote.h"

@implementation LQGeonote

#pragma mark - setters

- (void)setLocation:(CLLocation *)location
{
    _location = location;
    [self.delegate geonote:self locationDidChange:self.location];
//    NSLog(@"location: %@", [self description]);
}

- (void)setRadius:(CGFloat)radius
{
    _radius = radius;
    if ([self.delegate respondsToSelector:@selector(geonote:radiusDidChange:)])
        [self.delegate geonote:self radiusDidChange:self.radius];
//    NSLog(@"radius: %@", [self description]);
}

- (void)setText:(NSString *)text
{
    _text = text;
    if ([self.delegate respondsToSelector:@selector(geonote:textDidChange:)])
        [self.delegate geonote:self textDidChange:self.text];
//    NSLog(@"text: %@", [self description]);
}

#pragma mark - other

- (BOOL)isSaveable:(NSInteger)maxTextLength
{
    return ((_location != nil) && (_text != nil) && (_text.length > 0) && (_text.length <= maxTextLength));
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Geonote at %f, %f with radius %f, text: \"%@\"",
            self.location.coordinate.latitude,
            self.location.coordinate.longitude,
            self.radius,
            self.text];
}

@end