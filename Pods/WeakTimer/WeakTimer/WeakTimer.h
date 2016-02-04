//
//  WeakTimer.h
//  WeakTimer
//
//  Created by Alexander Stepanov on 15/01/16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import <Foundation/Foundation.h>


#define WEAK_TIMER_ONCE(seconds, ...) _WEAK_TIMER_START(seconds, NO, __VA_ARGS__)
#define WEAK_TIMER_REPEAT(seconds, ...) _WEAK_TIMER_START(seconds, YES, __VA_ARGS__)

#define WEAK_TIMER_STOP(token) [self weakTimer_stopTimer:token]
#define WEAK_TIMER_STOP_ALL() [self weakTimer_stopAllTimers]

#define WEAK_TIMER_RESTART(token, seconds, ...) \
WEAK_TIMER_STOP(token); \
token = _WEAK_TIMER_START(seconds, NO, __VA_ARGS__); \




#define _WEAK_TIMER_START(seconds, shouldRepeat, ...) \
({ \
    __weak __typeof(self) weakSelf = self; \
    [self weakTimer_startWithTimeInterval:seconds repeats:shouldRepeat block:^{ \
        __strong __typeof(self) self = weakSelf; \
        if (self) { \
            __VA_ARGS__ \
        } \
    }]; \
})

@interface NSObject (WeakTimer)

-(id)weakTimer_startWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void(^)())block;
-(void)weakTimer_stopTimer:(id)token;
-(void)weakTimer_stopAllTimers;

@end
