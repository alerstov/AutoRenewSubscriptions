//
//  InAppReceiptVerifier.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "InAppReceiptVerifier.h"
#import <AFNetworking.h>


#define TRACE_ENABLED 1
#if TRACE_ENABLED
#   define TRACE(_format, ...) NSLog(@"INAPP VERIFIER %@", [NSString stringWithFormat:_format, ##__VA_ARGS__])
#else
#   define TRACE(_format, ...)
#endif


@interface InAppReceiptVerifier ()
@property (nonatomic, copy) NSString* url;
@property (nonatomic, copy) void (^complete)(NSDictionary *, NSError *);
@end

@implementation InAppReceiptVerifier

-(instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

-(void)verifyReceipt:(NSString *)receipt complete:(void (^)(NSDictionary *, NSError *))complete
{
    TRACE(@"start");
    
    self.complete = complete;
    id params = @{@"receipt": receipt, @"sandbox": @(self.sandbox)};
    
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    [manager POST:self.url parameters:params success:^(AFHTTPRequestOperation * operation, id responseObject) {
        id res = [self validateResponse:responseObject];
        self.complete(res, nil);
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        TRACE(@"error: %@", error);
        self.complete(nil, error);
    }];
}

-(NSDictionary*)validateResponse:(id)json
{
    NSArray* inApps = [self validateReceiptJson:json];
    if (inApps == nil) return nil;
    
    
    // find last transaction for each productId
    NSMutableDictionary* transactions = [NSMutableDictionary dictionary];
    for (id inApp in inApps) {
        NSString* productId = inApp[@"product_id"];
        if (productId.length > 0){
            transactions[productId] = inApp;
        }
    }
    if (transactions.count == 0) {
        TRACE(@"no products");
        return nil;
    }
    
    
    NSMutableDictionary* items = [NSMutableDictionary dictionary];
    for (NSString* productId in transactions) {
        id inApp = transactions[productId];
        NSDate* expireDate = [self validateProductJson:inApp];
        if (expireDate != nil){
            TRACE(@"validation success %@, expire date %@", productId, expireDate);
            items[productId] = expireDate;
        }else{
            TRACE(@"validation failed %@", productId);
        }
    }
    return items;
}

-(NSArray*)validateReceiptJson:(id)json
{
    NSInteger status = [json[@"status"] integerValue];
    if (status != 0){
        TRACE(@"invalid status %@", @(status));
        return nil;
    }
    
    id receipt = json[@"receipt"];
    NSString* bundleId = receipt[@"bundle_id"];
    
    if (![bundleId isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]){
        TRACE(@"invalid bundle id %@", bundleId);
        return nil;
    }
    
    NSString* appVersion = receipt[@"application_version"];
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
    if (![appVersion isEqualToString:version]){
        TRACE(@"invalid app version %@", appVersion);
        return nil;
    }
    
    id inApps = receipt[@"in_app"];
    if (inApps == nil){
        TRACE(@"no 'in_app' in receipt");
        return nil;
    }
    
    return inApps;
}

-(NSDate*)validateProductJson:(id)inApp
{
    id expiresDate = inApp[@"expires_date_ms"];
    if (expiresDate == nil){
        TRACE(@"no 'expires_date_ms' in receipt");
        return nil;
    }
    
    NSDate* expDate = [NSDate dateWithTimeIntervalSince1970:[expiresDate floatValue]/1000.0];
    if ([expDate compare:[NSDate date]] == NSOrderedAscending){
        TRACE(@"expire date %@", expDate);
        return nil;
    }
    
    id cancelDate = inApp[@"cancellation_date_ms"];
    if (cancelDate != nil){
        TRACE(@"cancel date exists %@", [NSDate dateWithTimeIntervalSince1970:[cancelDate floatValue]/1000.0]);
        return nil;
    }
    
    return expDate;
}

@end
