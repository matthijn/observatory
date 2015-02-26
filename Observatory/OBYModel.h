//
//  OBYModel.h
//  Observatory
//
//  Created by Nils Wiersema on Oct 5, 2013.
//  Modified by Matthijn Dijkstra on Feb 26, 2015
//  Copyright (c) 2013 Nils Wiersema & Matthijn Dijkstra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBYModel : NSObject

# pragma mark Helpers to more easily manage KVO on this model

- (void)addObserverForAllProperties:(NSObject*)observer options:(NSKeyValueObservingOptions)options context:(void*)context;

- (void)removeObserverForAllProperties:(NSObject*)observer;

- (NSString *)shortName;

@end