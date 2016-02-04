//
//  InAppProductRequester.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "InAppProductRequester.h"


#define TRACE_ENABLED 1
#if TRACE_ENABLED
#   define TRACE(_format, ...) NSLog(@"INAPP PRODUCT REQUEST %@", [NSString stringWithFormat:_format, ##__VA_ARGS__])
#else
#   define TRACE(_format, ...)
#endif


@interface InAppProductRequester()<SKProductsRequestDelegate>
@property (nonatomic) NSString* productIdentifier;
@property (nonatomic, copy) void(^complete)(SKProduct *);
@property (nonatomic) SKProduct* product;
@property (nonatomic) SKProductsRequest* productsRequest;
@end

@implementation InAppProductRequester

-(instancetype)initWithProductIdentifier:(NSString*)productIdentifier
{
    self = [super init];
    if (self) {
        self.productIdentifier = productIdentifier;
    }
    return self;
}

-(void)requestWithCompletion:(void (^)(SKProduct *))complete
{
    if (self.product != nil){
        complete(self.product);
        return;
    }
    
    TRACE(@"request %@", self.productIdentifier);
    
    self.complete = complete;
    
    self.productsRequest.delegate = nil;
    self.productsRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithArray:@[self.productIdentifier]]];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

-(void)onComplete
{
    self.complete(self.product);
}

#pragma mark - SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (response.invalidProductIdentifiers.count > 0){
        TRACE(@"invalid products: [%@]", [response.invalidProductIdentifiers componentsJoinedByString:@", "]);
    }
    
    for (SKProduct* product in response.products) {
        if ([product.productIdentifier isEqualToString:self.productIdentifier]){
            TRACE(@"success %@", self.productIdentifier);
            self.product = product;
            break;
        }
    }
    
    if (self.product == nil){
        NSArray* prodIds = [response.products valueForKey:@"productIdentifier"];
        TRACE(@"not found %@ in [%@]", self.productIdentifier, [prodIds componentsJoinedByString:@", "]);
    }
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    TRACE(@"error: %@", error);
    [self onComplete];
}

-(void)requestDidFinish:(SKRequest *)request
{
    [self onComplete];
}

@end
