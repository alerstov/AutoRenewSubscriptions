//
//  WeakEvent.m
//  WeakEvent
//
//  Created by Alexander Stepanov on 10/12/15.
//  Copyright © 2015 Alexander Stepanov. All rights reserved.
//

#import "WeakEvent.h"
#import <objc/runtime.h>


static const void *EventBlocksKey = &EventBlocksKey;



@interface WeakEventToken : NSObject<NSCopying>
@property (nonatomic, weak) id weakObj;
@end

@implementation WeakEventToken

+(instancetype)tokenWithObject:(id)obj
{
    WeakEventToken* token = [[WeakEventToken alloc]init];
    token.weakObj = obj;
    return token;
}

-(id)copyWithZone:(NSZone *)zone
{
    return [WeakEventToken tokenWithObject:self.weakObj];
}

@end





@interface WeakEventBlock : NSObject
@property (nonatomic, copy) id block;
@property (nonatomic, weak) NSMutableSet* handlers;
@end

@implementation WeakEventBlock

// weak refernce to self is set to nil in dealloc
-(void)dealloc
{
    NSMutableSet* handlers = self.handlers;
    if (handlers == nil) return;
    
    NSMutableSet* toRemove = [NSMutableSet set];
    for (WeakEventToken* token in handlers) {
        if (token.weakObj == nil) {
            [toRemove addObject:token];
        }
    }
    
    [handlers minusSet:toRemove];
}

@end





@implementation NSObject (WeakEvent)

-(id)weakEvent_addBlock:(id)block forKey:(const void *)key
{
    NSMutableSet* handlers = objc_getAssociatedObject(self, key);
    if (handlers == nil){
        handlers = [NSMutableSet set];
        objc_setAssociatedObject(self, key, handlers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    WeakEventBlock* obj = [[WeakEventBlock alloc]init];
    obj.block = block;
    obj.handlers = handlers;
    
    WeakEventToken* token = [WeakEventToken tokenWithObject:obj];
    [handlers addObject:token];
    
    return obj;
}


-(void)weakEvent_raiseEventForKey:(const void *)key usingBlock:(void (^)(id))block
{
    NSMutableSet* handlers = objc_getAssociatedObject(self, key);
    
    // one-level-deep copy to avoid mutating while raising
    NSMutableSet* arr = [[NSMutableSet alloc]initWithSet:handlers copyItems:YES];
    
    for (WeakEventToken* token in arr){
        WeakEventBlock* obj = token.weakObj;
        if (obj != nil) {
            block(obj.block);
        }
    }
}


-(void)weakEvent_removeAllEventBlocks
{
    NSMutableSet* eventBlocks = objc_getAssociatedObject(self, EventBlocksKey);
    [eventBlocks removeAllObjects];
}

-(void)weakEvent_removeEventBlock:(id)token
{
    if (token == nil) return;
    
    NSAssert([token isKindOfClass:[WeakEventToken class]], @"Invalid token class");
    
    if ([token isKindOfClass:[WeakEventToken class]]){
        id obj = [token weakObj];
        if (obj != nil){
            NSMutableArray* eventBlocks = objc_getAssociatedObject(self, EventBlocksKey);
            [eventBlocks removeObject:obj];
        }
    }
}

-(id)weakEvent_addEventBlock:(id)eventBlock
{
    NSMutableSet* eventBlocks = objc_getAssociatedObject(self, EventBlocksKey);
    if (eventBlocks == nil){
        eventBlocks = [NSMutableSet set];
        objc_setAssociatedObject(self, EventBlocksKey, eventBlocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [eventBlocks addObject:eventBlock];
    
    WeakEventToken* token = [WeakEventToken tokenWithObject:eventBlock];
    return token;
}

@end