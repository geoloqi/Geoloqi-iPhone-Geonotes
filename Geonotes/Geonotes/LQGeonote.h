//
//  LQGeonote.h
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/30/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LQGeonoteDelegate;

@interface LQGeonote : NSObject {
    int maxTextLength;
}

@property (nonatomic) CLLocation *location;
@property (nonatomic) CGFloat radius;
@property (nonatomic) NSString *text;
@property (nonatomic) id <LQGeonoteDelegate> delegate;

- (id)initWithDelegate:(id<LQGeonoteDelegate>)delegate;

- (BOOL)isSaveable:(int)maxTextLength;
- (BOOL)isSaveable;
- (void)save:(void (^)(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error))complete;

@end

@protocol LQGeonoteDelegate <NSObject>

@required
- (void)geonote:(LQGeonote *)geonote locationDidChange:(CLLocation *)newLocation;

@optional
- (void)geonote:(LQGeonote *)geonote radiusDidChange:(CGFloat)newRadius;
- (void)geonote:(LQGeonote *)geonote textDidChange:(NSString *)newText;

@end