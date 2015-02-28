//
//  OBYModel.m
//  Observatory
//
//  Created by Nils Wiersema on Oct 5, 2013.
//  Modified by Matthijn Dijkstra on Feb 26, 2015
//  Copyright (c) 2013 Nils Wiersema & Matthijn Dijkstra. All rights reserved.
//

#import "OBYModel.h"

#import <objc/runtime.h>

@implementation OBYModel

// Adds the given observer as an observer for all keys in this object
- (void)addObserverForAllProperties:(NSObject*)observer options:(NSKeyValueObservingOptions)options context:(void*)context
{
    // Iterate over all properties
    for(NSString *key in [self allProperties])
    {
        // And start observing that key
        [self addObserver:observer forKeyPath:key options:options context:context];
    }
}

// Remove the observing of the observer on all properties
- (void)removeObserverForAllProperties:(NSObject*)observer
{
    // Iterate over all properties
    for(NSString *key in [self allProperties])
    {
        // And stop observing on that key
        [self removeObserver:observer forKeyPath:key];
    }
}

// Returns an array with string representations of the keys of all properties of this object
- (NSArray *)allProperties
{
    // No need to calculate the properties multiple times
    static NSMutableArray *allProperties;
    
    if(allProperties == nil)
    {
        allProperties = [NSMutableArray new];
        
        // Determine what properties this object has
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        
        // Itterate over all properties
        for (size_t i = 0; i < count; ++i)
        {
            // Convert the c string to an objective c string
            NSString* key = [NSString stringWithCString:property_getName(properties[i]) encoding:NSASCIIStringEncoding];
            
            // Add it to the array
            [allProperties addObject: key];
        }
        
    }
    
    return allProperties;
}

// Returns a shortened name for this model. Observatory expects classes to have a prefix and will strip that prefix ( Converts STKFooBarName to fooBarName )
- (NSString *)shortName
{
    // Strip the prefix
    NSString *name = [[[self class] description] substringFromIndex:3];
    
    // And correct the casing
    return [name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[name substringToIndex:1] lowercaseString]];
}

@end
