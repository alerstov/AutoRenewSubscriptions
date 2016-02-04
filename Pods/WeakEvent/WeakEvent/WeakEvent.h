//
//  WeakEvent.h
//  WeakEvent
//
//  Created by Alexander Stepanov on 10/12/15.
//  Copyright © 2015 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EVENT_DECL(name, ...) \
typedef void (^name##BlockType)(__VA_ARGS__); \
-(id)on##name:(name##BlockType)block

#define EVENT_IMPL(name) \
static const void *name##EventKey = &name##EventKey; \
-(id)on##name:(name##BlockType)block { \
    return [self weakEvent_addBlock:block forKey:name##EventKey]; \
}

#define EVENT_RAISE(name, ...) \
[self weakEvent_raiseEventForKey:name##EventKey usingBlock:^(id eventHandler) { \
    ((name##BlockType)eventHandler)(__VA_ARGS__); \
}]

#define EVENT_ADD(eventSource, eventMethod, ...) \
({  id obj; \
    @autoreleasepool { \
        __weak __typeof(self) weakSelf = self; \
        obj = [eventSource eventMethod{ \
            __strong __typeof(self) self = weakSelf; \
            if (self) { \
                __VA_ARGS__ \
            } \
        }]; \
    } \
    [self weakEvent_addEventBlock:obj]; \
})

#define EVENT_REMOVE(token) [self weakEvent_removeEventBlock:token]
#define EVENT_REMOVE_ALL() [self weakEvent_removeAllEventBlocks]


@interface NSObject (WeakEvent)

// event source
-(id)weakEvent_addBlock:(id)block forKey:(const void*)key;
-(void)weakEvent_raiseEventForKey:(const void*)key usingBlock:(void(^)(id eventHandler))block;

// event listener
-(id)weakEvent_addEventBlock:(id)obj;
-(void)weakEvent_removeEventBlock:(id)token;
-(void)weakEvent_removeAllEventBlocks;

@end