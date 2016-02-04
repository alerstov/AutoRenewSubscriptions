//
//  InAppDateChecker.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "InAppDateChecker.h"
#import "NSObject+KeychainProperty.h"


@interface InAppDateChecker ()
@property (nonatomic) NSDate* currentDate;
@end

@implementation InAppDateChecker

EVENT_IMPL(DateChanged);

@dynamic currentDate;

-(NSString *)keychain_prefix { return @"in_app_"; }

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self keychain_generate:@[@"currentDate"]];
    });
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ensureDate)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ensureDate)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)ensureDate
{
    NSDate* date = self.currentDate;
    NSDate* now = [NSDate date];
    BOOL isDateValid = date == nil || [date compare:now] == NSOrderedAscending;
    
    if (isDateValid) {
        self.currentDate = now;
    }else{
        EVENT_RAISE(DateChanged);
    }
}

@end
