//
//  NSObject+OBYObserver.h
//  Observatory
//
//  Created by Matthijn Dijkstra on 24/10/13.
//  Copyright (c) 2013 Matthijn Dijkstra. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBYModel;

@interface NSObject (OBYObserver)

#pragma mark Add models to observe

// Observe a given OBYModel
- (void)observeModel:(OBYModel*)model;

// Observe a given model only on specific keys
- (void)observeModel:(OBYModel*)model onKeys:(NSArray*)keys;

// Observe multiple OBYModels at once
- (void)observeModels:(NSArray*)models;

#pragma mark Remove models from observation

// Stop observing
- (void)removeAsObserverForAllModels;
- (void)removeAsObserverForModel:(OBYModel *)model;

# pragma mark KVO Events

// Called when the values of the given model change and there is no more specific method declared, for that see online documentation for the correct naming conventions
- (void)model:(OBYModel*)model valueChangedForKey:(NSString*)key;

@end
