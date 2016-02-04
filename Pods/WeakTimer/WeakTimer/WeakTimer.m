//
//  WeakTimer.m
//  WeakTimer
//
//  Created by Alexander Stepanov on 15/01/16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "WeakTimer.h"
#import <objc/runtime.h>


static const void *TrackersKey = &TrackersKey;


// WeakTimerTracker
@interface WeakTimerTracker : NSObject
@property (nonatomic, weak) NSTimer* timer;
@end

@implementation WeakTimerTracker
-(void)dealloc
{
    [self.timer invalidate];
}
@end


// WeakTimerToken
@interface WeakTimerToken : NSObject
@property (nonatomic, weak) WeakTimerTracker* tracker;
@end

@implementation WeakTimerToken
@end


// WeakTimerTarget
@interface WeakTimerTarget : NSObject
@property (nonatomic, copy) void(^block)();
@end

@implementation WeakTimerTarget
-(void)onTick:(NSTimer*)timer
{
    self.block();
}
@end


// NSObject (WeakTimer)
@implementation NSObject (WeakTimer)

-(id)weakTimer_startWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)())block
{
    NSMutableArray* trackers = objc_getAssociatedObject(self, TrackersKey);
    if (trackers == nil){
        trackers = [NSMutableArray array];
        objc_setAssociatedObject(self, TrackersKey, trackers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    WeakTimerTarget* tgt = [[WeakTimerTarget alloc]init];
    tgt.block = block;

    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:seconds target:tgt selector:@selector(onTick:) userInfo:nil repeats:repeats];
    
    WeakTimerTracker* tracker = [[WeakTimerTracker alloc]init];
    tracker.timer = timer;
    [trackers addObject:tracker];
    
    WeakTimerToken* token = [[WeakTimerToken alloc]init];
    token.tracker = tracker;
    
    return token;
}

-(void)weakTimer_stopTimer:(id)token
{
    if (token == nil) return;
    
    NSAssert([token isKindOfClass:[WeakTimerToken class]], @"Invalid token class");
    
    if ([token isKindOfClass:[WeakTimerToken class]]){
        @autoreleasepool {
            id obj = [token tracker];
            if (obj != nil){
                NSMutableArray* timers = objc_getAssociatedObject(self, TrackersKey);
                [timers removeObject:obj];
            }
        }
    }

}

-(void)weakTimer_stopAllTimers
{
    NSMutableArray* trackers = objc_getAssociatedObject(self, TrackersKey);
    [trackers removeAllObjects];
}

@end
