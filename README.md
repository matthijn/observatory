# Observatory

## What does Observatory do?

We all love the Objective-C KVO system. However it is [quite tedious](http://nshipster.com/key-value-observing/) in it’s usage. It is annoying to setup and if you observe multiple properties on different objectes there will be code duplication all over the place. Observatory aims to fix those annoyances. 

## Example

Lets say you run a pet store and we want to check the food supply of some animals. The `PETSquirrel` and `PETRabbit`. With observatory we can do it with just a few lines of code:

```

@interface PETStore : NSViewController

// Some models (they should extend OBYModel)
@property (nonatomic, strong) PETRabbit* rabbit;
@property (nonatomic, strong) PETSquirrel* squirrel;

@end

@implementation PETStore

- (void)viewDidLoad
{
    // Observe all properties on the rabbit model
    [self observeModel:self.rabbit];
    
    // Observe only the nuts property on the squirrel model
    [self observeModel:self.squirrel onKeys[@"nuts"]];
}

// Called when the <carrots> property is changed on the <PETRabbit> instance
- (void)rabbit:(PETRabbit *)rabbit valueChangedForCarrots:(NSNumber *)carrots
{
    NSLog(@"Nom, I now have %d carrots!", [carrots intValue]);
}

// Called when the <nuts> property is changed on the <PETSquirrel> instance
- (void)squirrel:(PETSquirrel *)squirrel valueChangedForNuts:(NSNumber *)nuts
{
    NSLog(@"Nom, I now have %d nuts!", [nuts intValue]);
}

@end
```

So, what happened here? Observatory determines what the name is of the class and property you are observing and will generate a unique selector based of that.

So if we have a model `PETRabbit` with a property `carrots` the following selector will be called on the observer when the property `carrots` changes:

```
- (void)rabbit:(PETRabbit *)valueChangedForCarrots:(id)carrots;
```

The pattern here is:

```
- (void)[className]:(Class *)valueChangedFor[value]:(id)value;
```

Much easier, is it not?

## Installation

Observatory is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "Observatory"

and run `pod install`

## API

### NSObject+OBYObserver

For the observer the following methods are available

Observe a given `OBYModel` on all it’s keys:
```
- (void)observeModel:(OBYModel*)model;
```

Add observation to multiple `OBYModels` at once:
```
- (void)observeModels:(NSArray*)models;
```

Stop observation on all `OBYModels`:
```
- (void)removeAsObserverForAllModels;
```

Remove the observation for a given `OBYModel`:
```
- (void)removeAsObserverForModel:(OBYModel *)model;
```

## Usage

First install `Observatory` as explained in the installation section. Then add 

```
#import <Observatory/NSObject+Observer>
```

to the objects who will act as the observer. This will make the API listed above available.

The objects you want to observe should extend `OBYModel`.

**Final note:** Your classes should have a [three letter prefix](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Conventions/Conventions.html) to determine the correct class name. 

## More

Observatory “falls back” to more generic selectors if a given selector is not implemented in your observer. If for example you have not implemented the earlier `rabbit: valueChangedForCarrots` selector it will try the following more generic selector:

```
- (void)rabbit:(PETRabbit *) valueChangedForKey(NSString *)key;
```

Where the structure is:

```
- (void)[model]:(Class *) valueChangedForKey(NSString *)key;
```

Finally if this selector has not been implemented either it will fall back to the most generic selector:

```
- (void)model:(OBYModel*)model valueChangedForKey:(NSString*)key;
```

## Thanks

Finally, thanks to [Nils Wiersema](https://github.com/nilswiersema) for working on the original project with me where this idea first saw the light.