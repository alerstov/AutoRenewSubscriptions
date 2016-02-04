//
//  InAppExpirationChecker.h
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 03.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WeakEvent.h>
#import "InAppSubscriptionState.h"

@interface InAppExpirationChecker : NSObject

-(instancetype)initWithState:(InAppSubscriptionState*)state;

@property (nonatomic) NSTimeInterval recheckIntervalOnSuccess;  // default 12 hour
@property (nonatomic) NSTimeInterval recheckIntervalOnError;    // default 1 minute

-(void)start;
-(void)stop;

-(void)checkAfterSuccess;
-(void)checkAfterError;

EVENT_DECL(Complete, BOOL success);

@end
