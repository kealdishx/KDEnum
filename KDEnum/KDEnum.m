//
//  KDEnum.m
//  KDEnum
//
//  Created by kealdish on 2020/9/20.
//  Copyright © 2020 Kealdish. All rights reserved.
//

#import "KDEnum.h"

@implementation NSArray (KDEnumMap)

- (NSArray *)kd_map:(id (^)(id obj))block {
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self) {
        id ret = block(obj);
        if (ret) {
            [arrayM addObject:block(obj)];
        }
    }

    return [arrayM copy];
}

@end

@interface KDEnumRepresentation : NSObject

@property (nonatomic, assign) BOOL containsDuplicates;
@property (nonatomic, copy) NSDictionary<NSNumber *, NSString *> *valueMapDict;

- (nullable NSString *)stringForNumber:(NSNumber *)number;

@end

@implementation KDEnumRepresentation

- (instancetype)initWithEnumDefinition:(NSString *)enumDefinition {
    self = [super init];
    if (self) {
        [self setupWithEnumDefinition:enumDefinition];
    }
    return self;
}

- (nullable NSString *)stringForNumber:(NSNumber *)number {
    NSAssert(!self.containsDuplicates, @"枚举定义中有重复的枚举值！");
    return self.valueMapDict[number];
}

#pragma mark - Private
- (void)setupWithEnumDefinition:(NSString *)enumDefinition {
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

    long long currentIndex = -1;
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
    // FIXME: 解析算法可以优化
    for (NSString *member in [enumDefinition componentsSeparatedByString:@","]) {
        if (member.length) {
            NSArray *parts = [[member componentsSeparatedByString:@"="] kd_map:^NSString *(NSString *element) {
                return [element stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }];
            NSAssert(parts.count == 1 || parts.count == 2, @"枚举定义出错");
            
            NSString *name = [parts firstObject];
            if (parts.count == 2) {
                NSString *valueString = [parts lastObject];
                NSNumber *number = [numberFormatter numberFromString:valueString];
                
                if (!number) {
                    NSArray *matchingKeys = [mutableDictionary allKeysForObject:valueString];
                    self.containsDuplicates = YES;
                    number = matchingKeys.firstObject;
                    NSAssert(number, @"解析枚举值出错");
                } else {
                    NSString *matchingObject = [mutableDictionary objectForKey:number];
                    if (matchingObject) {
                        self.containsDuplicates = YES;
                    }
                }
                
                currentIndex = [number longLongValue];
            } else {
                currentIndex++;
            }
            mutableDictionary[@(currentIndex)] = name;
        }
    }

    _valueMapDict = [mutableDictionary copy];
}

@end

#pragma mark - Helper Functions
static KDEnumRepresentation *representationFromDefinition(NSString *enumDefinition) {
    // FIXME: 后面如果使用场景多，需要优化字典的空间大小，比如 LRU 算法
    static NSMutableDictionary *cacheMappingFromEnumDefinitionDict = nil;
    static NSLock *lock = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheMappingFromEnumDefinitionDict = [[NSMutableDictionary alloc] init];
        lock = [[NSLock alloc] init];
    });
    
    if (!cacheMappingFromEnumDefinitionDict[enumDefinition]) {
        [lock lock];
        cacheMappingFromEnumDefinitionDict[enumDefinition] = [[KDEnumRepresentation alloc] initWithEnumDefinition:enumDefinition];
        [lock unlock];
    }

    return cacheMappingFromEnumDefinitionDict[enumDefinition];
}

#pragma mark - Public Functions
BOOL kd_enum_is_valid_value(NSString *enumDefinition, NSNumber *number) {
    return [representationFromDefinition(enumDefinition) stringForNumber:number] != nil;
}
