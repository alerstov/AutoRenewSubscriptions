//
//  InAppReceiptVerifier.h
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InAppReceiptVerifier : NSObject

-(instancetype)initWithUrl:(NSString*)url;

@property (nonatomic) BOOL sandbox;

// items - {productId : expireDate}
-(void)verifyReceipt:(NSString*)receipt complete:(void(^)(NSDictionary* items, NSError* error))complete;

@end
