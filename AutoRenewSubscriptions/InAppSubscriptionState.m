//
//  InAppSubscriptionState.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 03.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "InAppSubscriptionState.h"
#import "NSObject+KeychainProperty.h"


@interface InAppSubscriptionState ()
@property (nonatomic) NSString* keychainPrefix;
@end

@implementation InAppSubscriptionState

@dynamic isActive;
@dynamic expireDate;
@dynamic checkDate;

-(NSString *)keychain_prefix { return self.keychainPrefix; }

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self keychain_generate:@[@"isActive", @"expireDate", @"checkDate"]];
    });
}

-(instancetype)initWithKeychainPrefix:(NSString*)key
{
    self = [super init];
    if (self) {
        self.keychainPrefix = key;
    }
    return self;
}

@end
