//
//  LQActivityManager.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 9/21/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQActivityManager.h"
#import "LOLDatabase.h"
#import "LQAppDelegate.h"
#import "LQSDKUtils.h"

@interface LQActivityManager ()
- (void)reloadActivityFromAPI:(NSString *)path onSuccess:(void (^)(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error))success;
@end

@implementation LQActivityManager {
    NSMutableArray *activities;
    LOLDatabase *db;
    NSDateFormatter *dateFormatter;
}

@synthesize canLoadMore;

static LQActivityManager *activityManager;
static NSString *const kLQActivityCategoryName = @"LQActivity";
static NSString *const kLQActivityCollectionName = @"LQActivities";

+ (void)initialize
{
    if (!activityManager)
        activityManager = [self new];
}

+ (LQActivityManager *)sharedManager
{
    return activityManager;
}

#pragma mark -

- (LQActivityManager *)init
{
    self = [super init];
    if (self) {
        db = [[LOLDatabase alloc] initWithPath:[LQAppDelegate cacheDatabasePathForCategory:kLQActivityCategoryName]];
        db.serializer = ^(id object){
            return [LQSDKUtils dataWithJSONObject:object error:NULL];
        };
        db.deserializer = ^(NSData *data) {
            return [LQSDKUtils objectFromJSONData:data error:NULL];
        };
        
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // ISO 8601
        
        self.canLoadMore = YES;
    }
    return self;
}

- (NSArray *)activity
{
    return [NSArray arrayWithArray:activities];
}

#pragma mark -

- (void)reloadActivityFromAPI:(NSString *)path onSuccess:(void (^)(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error))success
{
    LQSession *session = [LQSession savedSession];
    NSURLRequest *request = [session requestWithMethod:@"GET"
                                                  path:path
                                               payload:nil];
    [session runAPIRequest:request completion:^(NSHTTPURLResponse *_response, NSDictionary *_responseDictionary, NSError *_error) {
        if (_error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[[_error userInfo] objectForKey:NSLocalizedDescriptionKey]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            success(_response, _responseDictionary, _error);
        }
    }];
}

- (void)reloadActivityFromAPI:(void (^)(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error))completion
{
    // reset local arrays and database
    NSMutableArray *_activities = [NSMutableArray new];
    [LQAppDelegate deleteFromTable:kLQActivityCollectionName forCategory:kLQActivityCategoryName];
    
    NSDate *aWeekAgo = [[NSDate alloc] initWithTimeIntervalSinceNow:(60*60*24*7*-1)];
    NSString *path = [NSString stringWithFormat:@"/timeline/messages?after=%@", [dateFormatter stringFromDate:aWeekAgo]];
    
    [self reloadActivityFromAPI:path onSuccess:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
        for (NSDictionary *item in [responseDictionary objectForKey:@"items"]) {
            [db accessCollection:LQActivityListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
                [accessor setDictionary:item forKey:[item objectForKey:@"published"]];
                [_activities addObject:item];
            }];
        }
        
        activities = _activities;
        self.canLoadMore = YES;
        if (completion) completion(response, responseDictionary, error);
    }];
}

- (void)loadMoreActivityFromAPI:(void (^)(NSHTTPURLResponse *, NSDictionary *, NSError *))completion
{
    if (self.canLoadMore) {
        NSString *lastItemDate = [[activities objectAtIndex:(activities.count - 1)] objectForKey:@"published"];
        NSString *path = [NSString stringWithFormat:@"/timeline/messages?before=%@", lastItemDate];
        
        [self reloadActivityFromAPI:path onSuccess:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
            for (NSDictionary *item in [responseDictionary objectForKey:@"items"]) {
                [db accessCollection:LQActivityListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
                    [accessor setDictionary:item forKey:[item objectForKey:@"published"]];
                    [activities addObject:item];
                }];
            }
            
            if ([[responseDictionary objectForKey:@"paging"] objectForKey:@"next_offset"])
                self.canLoadMore = YES;
            else
                self.canLoadMore = NO;
            
            if (completion) completion(response, responseDictionary, error);
        }];
    }
}

- (void)reloadActivityFromDB
{
    activities = [NSMutableArray new];
    [db accessCollection:LQActivityListCollectionName withBlock:^(id<LOLDatabaseAccessor> accessor) {
        [accessor enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *object, BOOL *stop) {
            
            // TODO possible prepend?
            
            [activities insertObject:object atIndex:[activities count]];
        }];
    }];
}

@end
