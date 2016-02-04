//
//  InAppProductRequester.h
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface InAppProductRequester : NSObject

-(instancetype)initWithProductIdentifier:(NSString*)productIdentifier;

-(void)requestWithCompletion:(void (^)(SKProduct *))complete;

@end
