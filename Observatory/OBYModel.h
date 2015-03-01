//
//  OBYModel.h
//  Observatory
//
//  Created by Nils Wiersema on Oct 5, 2013.
//  Modified by Matthijn Dijkstra on Feb 26, 2015
//  Copyright (c) 2013 Nils Wiersema & Matthijn Dijkstra. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Your models should extend this class if you want to observe them with Observatory
 */
@interface OBYModel : NSObject

/**
 *  Holds a unique name for this model and instance so Observatory can keep track of it
 */
@property (nonatomic, readonly) NSString *observatoryAlias;

# pragma mark Helpers to more easily manage KVO on this model

/**
 *  Helper method to observe all properties on this model via the Objective C KVO system
 *
 *  @param observer
 *  @param options
 *  @param context
 */
- (void)addObserverForAllProperties:(NSObject*)observer options:(NSKeyValueObservingOptions)options context:(void*)context;

/**
 *  Removes the given observer as an KVO observer for all properties on this model
 *
 *  @param observer
 */
- (void)removeObserverForAllProperties:(NSObject*)observer;

# pragma mark Other

/**
 *  Returns the class name where the prefix is stripped of and the first letter is lowercased
 *
 *  @return The short name
 */
- (NSString *)shortName;

@end