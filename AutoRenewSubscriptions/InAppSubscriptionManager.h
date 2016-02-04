//
//  InAppSubscriptionManager.h
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 03.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppSubscription.h"

@interface InAppSubscriptionManager : NSObject

@property (nonatomic, readonly) InAppSubscription* mag;
@property (nonatomic, readonly) InAppSubscription* video;

@end
