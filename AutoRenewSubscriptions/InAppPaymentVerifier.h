//
//  InAppPaymentVerifier.h
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WeakEvent.h>
#import "InAppReceiptVerifier.h"


@interface InAppPaymentVerifier : NSObject

-(instancetype)initWithReceiptVerifier:(InAppReceiptVerifier*)receiptVerifier;

EVENT_DECL(PaymentFailed);
EVENT_DECL(PaymentCancelled);
EVENT_DECL(PaymentVerifyError);
EVENT_DECL(PaymentVerifyComplete, NSDictionary *items);

-(void)verifyReceipt;

@end
