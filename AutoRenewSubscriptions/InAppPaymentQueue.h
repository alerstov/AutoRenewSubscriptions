//
//  InAppPaymentQueue.h
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WeakEvent.h>
#import <StoreKit/StoreKit.h>

@interface InAppPaymentQueue : NSObject

+(instancetype)sharedInstance;

-(void)start;

+(BOOL)canMakePayments;

-(void)restorePurchases;
-(void)addPayment:(SKProduct*)product;

EVENT_DECL(Purchasing, NSString* ident);
EVENT_DECL(Purchased, NSString* ident);
EVENT_DECL(Restored, NSString* ident);
EVENT_DECL(Failed, NSString* ident, BOOL cancelled, NSError* error);

@end
