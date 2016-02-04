//
//  InAppPaymentVerifier.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "InAppPaymentVerifier.h"
#import <WeakTimer.h>

#import "NSObject+KeychainProperty.h"
#import "InAppPaymentQueue.h"

#define VALIDATE_DELAY 0.5

@interface InAppPaymentVerifier ()
@property (nonatomic) InAppReceiptVerifier* receiptVerifier;
@property (nonatomic) id paymentTimerToken;
@property (nonatomic) NSString* receiptData;
@property (nonatomic) BOOL receiptRequestInProgress;
@end


@implementation InAppPaymentVerifier

EVENT_IMPL(PaymentFailed);
EVENT_IMPL(PaymentCancelled);
EVENT_IMPL(PaymentVerifyError);
EVENT_IMPL(PaymentVerifyComplete);

@dynamic receiptData;

-(NSString *)keychain_prefix { return @"in_app_"; }

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self keychain_generate:@[@"receiptData"]];
    });
}

-(instancetype)initWithReceiptVerifier:(InAppReceiptVerifier *)receiptVerifier
{
    self = [super init];
    if (self) {
        
        self.receiptVerifier = receiptVerifier;
        
        EVENT_ADD([InAppPaymentQueue sharedInstance], onPurchased:^(NSString *ident), {
            [self onTransactionComplete];
        });
        EVENT_ADD([InAppPaymentQueue sharedInstance], onRestored:^ (NSString *ident), {
            [self onTransactionComplete];
        });
        EVENT_ADD([InAppPaymentQueue sharedInstance], onFailed:^(NSString *ident, BOOL cancelled, NSError *error), {
            if (cancelled){
                // directly notify (assume server not send cancellation)
                EVENT_RAISE(PaymentCancelled, ident);
            }else{
                [self onTransactionComplete];
            }
        });
        
    }
    return self;
}

-(void)onTransactionComplete
{
    // delay need in case of several transactions in a row
    WEAK_TIMER_RESTART(self.paymentTimerToken, VALIDATE_DELAY, {
        NSData* data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
        assert(data != nil);
        self.receiptData = [data base64EncodedStringWithOptions:0];
        [self verifyReceipt];
    });
}

-(void)verifyReceipt
{
    NSString* receiptData = self.receiptData;
    if (receiptData == nil){
        EVENT_RAISE(PaymentFailed);
        return;
    }
    
    if (self.receiptRequestInProgress) return;
    self.receiptRequestInProgress = YES;
    
    [self.receiptVerifier verifyReceipt:receiptData complete:^(NSDictionary *items, NSError *error) {
        self.receiptRequestInProgress = NO;
        if (error != nil){
            EVENT_RAISE(PaymentVerifyError);
        }else{
            EVENT_RAISE(PaymentVerifyComplete, items);
        }
    }];
}

@end
