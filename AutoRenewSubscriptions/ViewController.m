//
//  ViewController.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "ViewController.h"
#import "InAppPaymentQueue.h"
#import "InAppProductRequester.h"
#import "InAppReceiptVerifier.h"
#import "InAppSubscriptionManager.h"

#if DEBUG
#define SANDBOX 1
#endif

#define URL @"https://inapp-mediacom.rhcloud.com/verify"

#define PRODUCT_ID          @"gtfgtr.mag"


@interface ViewController ()
@property (nonatomic) InAppProductRequester* productRequester;
@property (nonatomic) InAppReceiptVerifier* receiptVerifier;
@property (nonatomic) SKProduct* product;
@property (nonatomic) InAppSubscriptionManager* subManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.subManager = [[InAppSubscriptionManager alloc]init];
}

- (IBAction)requestProduct:(id)sender {
    self.productRequester = [[InAppProductRequester alloc]initWithProductIdentifier:PRODUCT_ID];
    [self.productRequester requestWithCompletion:^(SKProduct *product) {
        self.product = product;
    }];
}

- (IBAction)makePayment:(id)sender {
    if (self.product != nil){
        [[InAppPaymentQueue sharedInstance] addPayment:self.product];
    }
}

- (IBAction)validateReceipt:(id)sender {
    NSData* receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    if (receiptData != nil){
        NSString* receipt = [receiptData base64EncodedStringWithOptions:0];
        
        self.receiptVerifier = [[InAppReceiptVerifier alloc]initWithUrl:URL];
#if SANDBOX
        self.receiptVerifier.sandbox = YES;
#endif
        
        [self.receiptVerifier verifyReceipt:receipt complete:^(NSDictionary *items, NSError *error) {
            
        }];
    }
}

- (IBAction)magClick:(id)sender {
    InAppSubscription* sub = self.subManager.mag;
    [self checkSubscription:sub name:@"Magazine"];
}

- (IBAction)videoClick:(id)sender {
    InAppSubscription* sub = self.subManager.video;
    [self checkSubscription:sub name:@"Video"];
}

-(void)checkSubscription:(InAppSubscription*)sub name:(NSString*)name
{
    if (sub.isActive){
        [self showMessage:[NSString stringWithFormat:@"Subscription %@ active !!!", name]];
    }else{
        EVENT_ADD(sub, onPaymentSuccess:^,{
            EVENT_REMOVE_ALL();
            [self showMessage:[NSString stringWithFormat:@"Subscription %@ activated !!!", name]];
        });
        EVENT_ADD(sub, onPaymentFailed:^,{
            EVENT_REMOVE_ALL();
            [self showMessage:@"Paymnet failed"];
        });
        EVENT_ADD(sub, onPaymentCancelled:^,{
            EVENT_REMOVE_ALL();
        });
        
        [sub requestPayment];
    }
}

-(void)showMessage:(NSString*)mes
{
    [[[UIAlertView alloc]initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
