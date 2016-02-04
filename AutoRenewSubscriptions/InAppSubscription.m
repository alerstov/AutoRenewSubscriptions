//
//  InAppSubscription.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "InAppSubscription.h"
#import "InAppPaymentQueue.h"
#import "InAppSubscriptionState.h"
#import "InAppProductRequester.h"
#import "InAppExpirationChecker.h"


#define TRACE_ENABLED 1
#if TRACE_ENABLED
#   define TRACE(_format, ...) NSLog(@"INAPP [%@] %@", self.productId, [NSString stringWithFormat:_format, ##__VA_ARGS__])
#else
#   define TRACE(_format, ...)
#endif


@interface InAppSubscription()
@property (nonatomic, copy) NSString* productId;
@property (nonatomic) InAppSubscriptionState* state;
@property (nonatomic) InAppProductRequester* productRequester;
@property (nonatomic) InAppExpirationChecker* expireChecker;
@end

@implementation InAppSubscription

EVENT_IMPL(PaymentSuccess);
EVENT_IMPL(PaymentCancelled);
EVENT_IMPL(PaymentFailed);

#pragma mark - ctor

-(instancetype)initWithProductId:(NSString *)productId
                  keychainPrefix:(NSString *)key
                 paymentVerifier:(InAppPaymentVerifier*)paymentVerifier
{
    self = [super init];
    if (self) {
        self.productId = productId;
        self.state = [[InAppSubscriptionState alloc]initWithKeychainPrefix:key];
        self.productRequester = [[InAppProductRequester alloc]initWithProductIdentifier:productId];
        
        [self setupExpirationChecker:paymentVerifier];
        [self setupPaymentVerifier:paymentVerifier];
        
        [self.expireChecker start];
    }
    return self;
}


#pragma mark - public

-(void)enableDateChecking:(InAppDateChecker *)dateChecker
{
    EVENT_ADD(dateChecker, onDateChanged:^, {
        TRACE(@"date changed, need verify receipt");
        [self disableSubscription];
    });
}

-(BOOL)isActive
{
    return self.state.isActive;
}

+(BOOL)canMakePayments
{
    return [InAppPaymentQueue canMakePayments];
}

-(void)restorePurchases
{
    [[InAppPaymentQueue sharedInstance] restorePurchases];
}

-(void)requestPayment
{
    [self.productRequester requestWithCompletion:^(SKProduct* product) {
        if (product != nil) {
            [[InAppPaymentQueue sharedInstance] addPayment:product];
        }else{
            EVENT_RAISE(PaymentFailed);
        }
    }];
}


#pragma mark - interval

-(NSTimeInterval)recheckIntervalOnError
{
    return self.expireChecker.recheckIntervalOnError;
}

-(NSTimeInterval)recheckIntervalOnSuccess
{
    return self.expireChecker.recheckIntervalOnSuccess;
}

-(void)setRecheckIntervalOnError:(NSTimeInterval)recheckIntervalOnError
{
    self.expireChecker.recheckIntervalOnError = recheckIntervalOnError;
}

-(void)setRecheckIntervalOnSuccess:(NSTimeInterval)recheckIntervalOnSuccess
{
    self.expireChecker.recheckIntervalOnSuccess = recheckIntervalOnSuccess;
}


#pragma mark - private

-(void)setupExpirationChecker:(InAppPaymentVerifier*)paymentVerifier
{
    self.expireChecker = [[InAppExpirationChecker alloc]initWithState:self.state];
    EVENT_ADD(self.expireChecker, onComplete:^(BOOL success), {
        if (success){
            [paymentVerifier verifyReceipt];
        }else{
            TRACE(@"expiration !!!");
            [self disableSubscription];
        }
    });
}

-(void)setupPaymentVerifier:(InAppPaymentVerifier*)paymentVerifier
{
    EVENT_ADD(paymentVerifier, onPaymentCancelled:^, {
        // cancelled by user
        // subscription status not change (should be off)
        EVENT_RAISE(PaymentCancelled);
    });
    EVENT_ADD(paymentVerifier, onPaymentFailed:^, {
        // receipt data is nil
        [self disableSubscription];
        EVENT_RAISE(PaymentFailed);
    });
    EVENT_ADD(paymentVerifier, onPaymentVerifyError:^, {
        if (self.state.isActive){
            // payment dialog should not be presented when subscription active
            [self.expireChecker checkAfterError];
        }else{
            // no need invalidate subscription
            EVENT_RAISE(PaymentFailed);
        }
    });
    EVENT_ADD(paymentVerifier, onPaymentVerifyComplete:^(NSDictionary *items), {
        NSDate* expireDate = items[self.productId];
        if (expireDate == nil){
            [self disableSubscription];
            EVENT_RAISE(PaymentFailed);
        }else{
            [self enableSubscription:expireDate];
            EVENT_RAISE(PaymentSuccess);
        }
    });
}

-(void)disableSubscription
{
    TRACE(@"subscription off");
    self.state.isActive = NO;
    [self.expireChecker stop];
}

-(void)enableSubscription:(NSDate*)expireDate
{
    TRACE(@"subscription on");
    self.state.isActive = YES;
    self.state.expireDate = expireDate;
    [self.expireChecker checkAfterSuccess];
}

@end
