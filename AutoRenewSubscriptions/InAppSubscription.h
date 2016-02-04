//
//  InAppSubscription.h
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WeakEvent.h>
#import "InAppPaymentVerifier.h"
#import "InAppDateChecker.h"

@interface InAppSubscription : NSObject

-(instancetype)initWithProductId:(NSString*)productId
                  keychainPrefix:(NSString*)key
                 paymentVerifier:(InAppPaymentVerifier*)paymentVerifier;

-(void)enableDateChecking:(InAppDateChecker*)dateChecker;

@property (nonatomic) NSTimeInterval recheckIntervalOnSuccess;  // default 12 hour
@property (nonatomic) NSTimeInterval recheckIntervalOnError;    // default 1 minute

@property (nonatomic, copy, readonly) NSString* productId;
@property (nonatomic, readonly) BOOL isActive;

+(BOOL)canMakePayments;

-(void)restorePurchases;
-(void)requestPayment;

EVENT_DECL(PaymentSuccess);
EVENT_DECL(PaymentCancelled);
EVENT_DECL(PaymentFailed); // product not found, validation failed

@end
