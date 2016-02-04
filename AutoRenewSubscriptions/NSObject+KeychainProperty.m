//
//  NSObject+KeychainProperty.m
//  AutoRenewSubscriptions
//
//  Created by Alexander Stepanov on 02.02.16.
//  Copyright © 2016 Alexander Stepanov. All rights reserved.
//

#import "NSObject+KeychainProperty.h"
#import <objc/runtime.h>
#import <Lockbox.h>

static NSString* get_type_string(Class cls, NSString* propName)
{
    objc_property_t property = class_getProperty(cls, [propName cStringUsingEncoding:NSUTF8StringEncoding]);
    assert(property);
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
    const char* const attrString = property_getAttributes(property);
    assert(attrString && attrString[0] == 'T');
    const char *typeString = attrString + 1;
    
    if (*typeString == *(@encode(BOOL))) return @"BOOL";
    
    NSString* s = [NSString stringWithUTF8String:typeString];
    if ([s rangeOfString:@"NSDate"].location != NSNotFound) return @"NSDate";
    if ([s rangeOfString:@"NSString"].location != NSNotFound) return @"NSString";
    
    assert(false);
    return nil;
}

static void add_prop(Class cls, NSString* propName, const char* type, id getter, id setter)
{
    SEL getterSel = sel_registerName([propName cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSString* s = [NSString stringWithFormat:@"set%@%@:", [[propName substringToIndex:1] uppercaseString], [propName substringFromIndex:1]];
    SEL setterSel = sel_registerName([s cStringUsingEncoding:NSUTF8StringEncoding]);
    
    const char* getterTypes = [[NSString stringWithFormat:@"%s@:", type] cStringUsingEncoding:NSUTF8StringEncoding];  // (type, self, _cmd)
    const char* setterTypes = [[NSString stringWithFormat:@"v@:%s", type] cStringUsingEncoding:NSUTF8StringEncoding]; // (void, self, _cmd, type)
    
    // add getter
    BOOL success;
    success = class_addMethod(cls, getterSel, imp_implementationWithBlock(getter), getterTypes);
    assert(success);
    
    // add setter
    success = class_addMethod(cls, setterSel, imp_implementationWithBlock(setter), setterTypes);
    assert(success);
}


@implementation NSObject (KeychainProperty)

-(NSString *)keychain_prefix
{
    return @"";
}

-(NSString*)keychain_key:(NSString*)propName
{
    return [[self keychain_prefix] stringByAppendingString:propName];
}

+(void)keychain_generate:(NSArray *)props
{
    Class cls = [self class];
    
    for (NSString* propName in props)
    {
        NSString *typeString = get_type_string(cls, propName);
        
        if ([typeString isEqualToString:@"BOOL"])
        {
            id getter = ^(id self) { return [[Lockbox stringForKey:[self keychain_key:propName]] isEqualToString:@"1"]; };
            id setter = ^(id self, BOOL value) { [Lockbox setString:(value ? @"1" : @"0") forKey:[self keychain_key:propName]]; };
            add_prop(cls, propName, @encode(BOOL), getter, setter);
        }
        else if ([typeString isEqualToString:@"NSDate"])
        {
            id getter = ^(id self) { return [Lockbox dateForKey:[self keychain_key:propName]]; };
            id setter = ^(id self, id value) { [Lockbox setDate:value forKey:[self keychain_key:propName]]; };
            add_prop(cls, propName, @encode(id), getter, setter);
        }
        else if ([typeString isEqualToString:@"NSString"])
        {
            id getter = ^(id self) { return [Lockbox stringForKey:[self keychain_key:propName]]; };
            id setter = ^(id self, id value) { [Lockbox setString:value forKey:[self keychain_key:propName]]; };
            add_prop(cls, propName, @encode(id), getter, setter);
        }
        else
        {
            assert(false);
        }
    }
}

@end
