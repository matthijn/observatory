//
//  NSObject+OBYObserver.m
//  Observatory
//
//  Created by Matthijn Dijkstra on 24/10/13.
//  Copyright (c) 2013 Matthijn Dijkstra. All rights reserved.
//

// The compiler warns about a possible leak by generating selectors from strings. However will not leak because the method for the generated selector will not return anything. More details can be found here:  http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
// When I find the time I will build a better solution, for now suppressing the warning

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#import <objc/runtime.h>

#import "NSObject+OBYObserver.h"
#import "OBYModel.h"

@interface NSObject()

/**
 *  Holds the reference to all observed models. So make sure to call removeAsObserverForModel if you are done with it. (Using some lower level code to make adding properties possible with categories, since this is not supported by default)
 */
@property (nonatomic, strong) NSMutableDictionary *observedModels;

@end

/**
 *  This Category adds helper methods to the NSObject for observing models
 */
@implementation NSObject (OBYObserver)

#pragma mark Add models to observe

/**
 *  Observe a given OBYModel
 *
 *  @param model The model you want to observe
 */
- (void)observeModel:(OBYModel*)model;
{
    [self observeModel:model onKeys:nil];
}

/**
 *  Observe a given model only on specific keys
 *
 *  @param model The model you want to observe
 *  @param keys  An array containing keypaths to the properties on the model to observe
 *  @param tag The unique identifier for this instance of this model
 */
- (void)observeModel:(OBYModel*)model onKeys:(NSArray*)keys;
{
    // Make sure we have a place to store the referenced models in
    if(!self.observedModels)
    {
        self.observedModels = [NSMutableDictionary dictionary];
    }
    
    // Make sure it is unique
    NSAssert(!self.observedModels[@(model.identifier)], @"Already observing a model with identifier: %lu", model.identifier);
    
    // If we get here it is unique, so we can add it
    self.observedModels[@(model.identifier)] = model;
    
    // Call the relevant models both on the initial fase (so you can hook up it directly) and when the value changes
    NSKeyValueObservingOptions options = (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew);
    
    // If keys have been passed only observe those keys
    if(keys)
    {
        // Iterage over all keys and add self as the observer for those keys
        for(id key in keys)
        {
            [model addObserver:self forKeyPath:key options:options context:nil];
        }
    }
    // No keys have been passed, listening for all values
    else
    {
        [model addObserverForAllProperties:self options:options context:nil];
    }

}

/**
 *  Observe multiple OBYModels at once on all keys
 *
 *  @param models An array containing one or more OBYModel instances
 */
- (void)observeModels:(NSArray*)models
{
    for(OBYModel *model in models)
    {
        [self observeModel:model];
    }
}

#pragma mark Remove models from observation

/**
 *  Removes this instance as an observer on the given OBYModel instance
 *
 *  @param model The model you want to stop observing
 */
- (void)removeAsObserverForModel:(OBYModel *)model
{
    if(self.observedModels[@(model.identifier)])
    {
        // Stop observing the model
        [model removeObserverForAllProperties:self];
        
        // Remove it from the dictionary
        [self.observedModels removeObjectForKey:@(model.identifier)];
    }
}

/**
 *  Removes this instance as an obverver on all current observing OBYModels
 */
- (void)removeAsObserverForAllModels
{
    for(OBYModel* model in [self.observedModels allValues])
    {
        [model removeObserverForAllProperties:self];
    }
    [((NSMutableDictionary*)self.observedModels) removeAllObjects];
}

#pragma mark KVO Events

/**
 *  This is where the magic happens. By default the Objective-C KVO system calls this when it detects changes in properties. This forwards it to the correct selector
 *
 *  @param keyPath
 *  @param object
 *  @param change
 *  @param context
 */
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    
    // This category only handles OBYModels
    if([object isKindOfClass:[OBYModel class]])
    {
        // Build a selector so we can call the correct method for this specific object and key directly
        
        // Building the relevant and most specific selector
        // Lets say we are listening on model Foo for key baz it will generate the selector: foo: (Foo *) valueChangedForBaz: (id) baz
        
        // Get the name of the model
        NSString *shortName = [object shortName];
        
        // And the correct name format for the key
        NSString *keyName = [keyPath stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[keyPath substringToIndex:1] uppercaseString]];
        
        // Build the most specific selector
        SEL modelAndKeySpecificSelector = NSSelectorFromString([NSString stringWithFormat:@"%@:valueChangedFor%@:", shortName, keyName]);
        
        // Does it respond to the most specific selector?
        if([self respondsToSelector:modelAndKeySpecificSelector])
        {
            // It does! Get the correct value from the observed object and perform the selector on self
            id value = [object valueForKey:keyPath];
            SuppressPerformSelectorLeakWarning(
                                               [self performSelector:modelAndKeySpecificSelector withObject:object withObject:value];
                                               );
        }
        // This class does not respond to the most specific selector, perhaps a more generic selector has been chosen?
        else
        {
            // Maybe there is a specific one for this model
            // For example with the same class Foo and key baz it will now call the selector: foo: (Foo *) foo valueChangedForKey:(NSString *) key
            SEL modelSpecificSelector = NSSelectorFromString([NSString stringWithFormat:@"%@:valueChangedForKey:", shortName]);
            
            // Determine if it responds to the model specific selector
            if([self respondsToSelector:modelSpecificSelector ])
            {
                SuppressPerformSelectorLeakWarning(
                                                   [self performSelector:modelSpecificSelector withObject:object withObject:keyPath];
                                                   );
            }
            // Nothing there, revert to the good ol' default
            else
            {
                // No specific selector was in place. Calling the final fallback
                [self model:object valueChangedForKey:keyPath];
            }
        }
    }
}

/**
 *  Called when the values of the given model change and there is no more specific method declared, for that see online documentation ( https://github.com/Matthijn/Observatory ) for the correct naming conventions
 *
 *  @param model The model instance which has the changed property value
 *  @param key   The keypath to the property that changed value
 */
- (void)model:(OBYModel*)model valueChangedForKey:(NSString*)key { }

# pragma mark Other

// This is a category, which cannot add properties to a class by default. This low level runtime code makes it possible.

/**
 *  Setting the observed models property
 *
 *  @param models A dictionary that will contain the models
 */
- (void)setObservedModels:(NSDictionary *)models
{
    objc_setAssociatedObject(self, @selector(observedModels), models, OBJC_ASSOCIATION_RETAIN);
}

/**
 *  And retrieving the dictionary that holds the observed models
 *
 *  @return
 */
- (NSMutableDictionary *)observedModels
{
    return objc_getAssociatedObject(self, @selector(observedModels));
}

@end
