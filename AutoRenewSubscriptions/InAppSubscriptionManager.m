//
//  InAppSubscriptionManager.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 03.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "InAppSubscriptionManager.h"

#import "InAppReceiptVerifier.h"
#import "InAppPaymentVerifier.h"
#import "InAppDateChecker.h"

#if DEBUG
#define SANDBOX 1
#endif

#define URL @"https://inapp-mediacom.rhcloud.com/verify"

#define PRODUCT_ID_MAG          @"gtfgtr.mag"
#define PRODUCT_ID_VIDEO        @"gtfgtr.video"

#define KEYCHAIN_KEY_MAG        @"in_app_mag_"
#define KEYCHAIN_KEY_VIDEO      @"in_app_video_"


@interface InAppSubscriptionManager ()
@property (nonatomic) NSArray* subscriptions;
@property (nonatomic) InAppSubscription* mag;
@property (nonatomic) InAppSubscription* video;
@property (nonatomic) InAppPaymentVerifier* paymentVerifier;
@property (nonatomic) InAppDateChecker* dateChecker;
@end

@implementation InAppSubscriptionManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        InAppReceiptVerifier* receiptVerifier = [[InAppReceiptVerifier alloc]initWithUrl:URL];
#if SANDBOX
        receiptVerifier.sandbox = YES;
#endif
        
        self.paymentVerifier = [[InAppPaymentVerifier alloc]initWithReceiptVerifier:receiptVerifier];
        self.dateChecker = [[InAppDateChecker alloc]init];
        [self setupSubscriptions];
    }
    return self;
}

-(void)setupSubscriptions
{
    self.mag = [[InAppSubscription alloc]initWithProductId:PRODUCT_ID_MAG keychainPrefix:KEYCHAIN_KEY_MAG paymentVerifier:self.paymentVerifier];
    self.video = [[InAppSubscription alloc]initWithProductId:PRODUCT_ID_VIDEO keychainPrefix:KEYCHAIN_KEY_VIDEO paymentVerifier:self.paymentVerifier];
    self.subscriptions = @[self.mag, self.video];
    for (InAppSubscription* sub in self.subscriptions) {
        [sub enableDateChecking:self.dateChecker];
    }
}

@end
