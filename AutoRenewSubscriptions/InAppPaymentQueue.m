//
//  InAppPaymentQueue.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "InAppPaymentQueue.h"


#define TRACE_ENABLED 1
#if TRACE_ENABLED
#   define TRACE(_format, ...) NSLog(@"INAPP QUEUE %@", [NSString stringWithFormat:_format, ##__VA_ARGS__])
#else
#   define TRACE(_format, ...)
#endif


@interface InAppPaymentQueue()<SKPaymentTransactionObserver>

@end

@implementation InAppPaymentQueue

EVENT_IMPL(Purchasing);
EVENT_IMPL(Purchased);
EVENT_IMPL(Restored);
EVENT_IMPL(Failed);

+(instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

-(void)start
{
    TRACE(@"start");
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

+(BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

-(void)restorePurchases
{
    TRACE(@"restore purchases");
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void)addPayment:(SKProduct*)product
{
    TRACE(@"add payment %@", product.productIdentifier);
    [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
}


-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    TRACE(@"removed transactions %@", @(transactions.count));
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    TRACE(@"update transactions %@", @(transactions.count));
    for(SKPaymentTransaction* t in transactions)
    {
        NSString* ident = t.payment.productIdentifier;
        
        if (t.transactionState == SKPaymentTransactionStatePurchasing) {
            TRACE(@"transaction purchasing (%@)", ident);
            EVENT_RAISE(Purchasing, ident);
        }
        
        else if (t.transactionState == SKPaymentTransactionStatePurchased) {
            TRACE(@"transaction complete (%@)", ident);
            [[SKPaymentQueue defaultQueue] finishTransaction:t];
            
            EVENT_RAISE(Purchased, ident);
        }
        
        else if (t.transactionState == SKPaymentTransactionStateRestored) {
            TRACE(@"transaction restore (%@)", ident);
            [[SKPaymentQueue defaultQueue] finishTransaction:t];
            
            EVENT_RAISE(Restored, ident);
        }
        
        else if (t.transactionState == SKPaymentTransactionStateFailed) {
            TRACE(@"transaction failed (%@), error: %@", ident, t.error);
            BOOL cancelled = t.error.code == SKErrorPaymentCancelled;
            [[SKPaymentQueue defaultQueue] finishTransaction:t];
            
            EVENT_RAISE(Failed, ident, cancelled, t.error);
        }
        
        else{
            
        }
    }
}

@end
