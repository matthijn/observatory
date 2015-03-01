//
//  NSObject+OBYObserver.h
//  Observatory
//
//  Created by Matthijn Dijkstra on 24/10/13.
//  Copyright (c) 2013 Matthijn Dijkstra. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBYModel;

/**
 *  This Category adds helper methods to the NSObject for observing models
 */
@interface NSObject (OBYObserver)

#pragma mark Add models to observe

/**
 *  Observe a given OBYModel
 *
 *  @param model The model you want to observe
 */
- (void)observeModel:(OBYModel*)model;

/**
 *  Observe a given model only on specific keys
 *
 *  @param model The model you want to observe
 *  @param keys  An array containing keypaths to the properties on the model to observe
 */
- (void)observeModel:(OBYModel*)model onKeys:(NSArray*)keys;

/**
 *  Observe multiple OBYModels at once on all keys
 *
 *  @param models An array containing one or more OBYModel instances
 */
- (void)observeModels:(NSArray*)models;

#pragma mark Remove models from observation

/**
 *  Removes this instance as an observer on the given OBYModel instance
 *
 *  @param model The model you want to stop observing
 */
- (void)removeAsObserverForModel:(OBYModel *)model;

/**
 *  Removes this instance as an obverver on all current observing OBYModels
 */
- (void)removeAsObserverForAllModels;

# pragma mark KVO Events

/**
 *  Called when the values of the given model change and there is no more specific method declared, for that see online documentation ( https://github.com/Matthijn/Observatory ) for the correct naming conventions
 *
 *  @param model The model instance which has the changed property value
 *  @param key   The keypath to the property that changed value
 */
- (void)model:(OBYModel*)model valueChangedForKey:(NSString*)key;

@end
