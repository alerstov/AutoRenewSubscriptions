//
//  InAppExpirationChecker.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 03.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "InAppExpirationChecker.h"
#import <WeakTimer.h>


@interface InAppExpirationChecker ()
@property (nonatomic) id checkTimerToken;
@property (nonatomic) InAppSubscriptionState* state;
@end

@implementation InAppExpirationChecker

EVENT_IMPL(Complete);

-(instancetype)initWithState:(InAppSubscriptionState*)state
{
    self = [super init];
    if (self) {
        self.recheckIntervalOnError = 60;
        self.recheckIntervalOnSuccess = (60*60*12);
    }
    return self;
}

-(void)start
{
    NSDate* checkDate = self.state.checkDate;
    NSDate* now = [NSDate date];
    NSTimeInterval tm = [checkDate timeIntervalSinceDate:now];
    if (tm > 0){
        [self checkAfter:tm];
    }else{
        [self checkExpiration];
    }
}

-(void)stop
{
    WEAK_TIMER_STOP(self.checkTimerToken); // stop checking
}

-(void)checkAfterError
{
    [self checkAfter:self.recheckIntervalOnError];
}

-(void)checkAfterSuccess
{
    self.state.checkDate = [[NSDate date] dateByAddingTimeInterval:self.recheckIntervalOnSuccess];
    [self checkAfter:self.recheckIntervalOnSuccess];
}

-(void)checkAfter:(NSTimeInterval)seconds
{
    WEAK_TIMER_RESTART(self.checkTimerToken, seconds, {
        [self checkExpiration];
    });
}

-(void)checkExpiration
{
    if (!self.state.isActive){
        return;
    }
    
    if (self.state.expireDate == nil){
        EVENT_RAISE(Complete, NO);
        return;
    }
    
    if ([self.state.expireDate compare:[NSDate date]] == NSOrderedAscending){
        EVENT_RAISE(Complete, NO);
        return;
    }
    
    EVENT_RAISE(Complete, YES);
}

@end
