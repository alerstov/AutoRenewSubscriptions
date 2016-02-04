//
//  NSObject+KeychainProperty.h
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>

// support BOOL, NSString, NSDate
@interface NSObject (KeychainProperty)

// prefix for keychain key, full key: prefix + propName
-(NSString*)keychain_prefix;

// generate impl-n of dynamic properties
+(void)keychain_generate:(NSArray*)props;

@end
