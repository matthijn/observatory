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

/**
 *  Your models should extend this class if you want to observe them with Observatory
 */
@implementation OBYModel

/**
 *  Helper method to observe all properties on this model via the Objective C KVO system
 *
 *  @param observer
 *  @param options
 *  @param context
 */
- (void)addObserverForAllProperties:(NSObject*)observer options:(NSKeyValueObservingOptions)options context:(void*)context
{
    // Iterate over all properties
    for(NSString *key in [self allProperties])
    {
        // And start observing that key
        [self addObserver:observer forKeyPath:key options:options context:context];
    }
}

/**
 *  Removes the given observer as an KVO observer for all properties on this model
 *
 *  @param observer
 */
- (void)removeObserverForAllProperties:(NSObject*)observer
{
    // Iterate over all properties
    for(NSString *key in [self allProperties])
    {
        // And stop observing on that key
        [self removeObserver:observer forKeyPath:key];
    }
}

/**
 *  Returns an array with all the keypaths to the properties of this instance
 *
 *  @return Array with keypaths
 */
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

# pragma mark Other

/**
 *  Returns the class name where the prefix is stripped of and the first letter is lowercased
 *
 *  @return The short name
 */
- (NSString *)shortName
{
    // Strip the prefix
    NSString *name = [[[self class] description] substringFromIndex:3];
    
    // And correct the casing
    return [name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[name substringToIndex:1] lowercaseString]];
}

/**
 *  Returns a unique name for this model and instance so Observatory can keep track of it
 *
 *  @return The model instance alias
 */
- (NSString *)observatoryAlias
{
    return [NSString stringWithFormat:@"%@-%p", NSStringFromClass([self class]), self];
}

@end
