//
//  InAppSubscriptionState.h
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 03.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InAppSubscriptionState : NSObject

-(instancetype)initWithKeychainPrefix:(NSString*)key;

@property (nonatomic) BOOL isActive;
@property (nonatomic) NSDate* expireDate;
@property (nonatomic) NSDate* checkDate;

@end
