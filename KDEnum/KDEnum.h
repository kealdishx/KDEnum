//
//  KDEnum.h
//  KDEnum
//
//  Created by kealdish on 2020/9/20.
//  Copyright © 2020 Kealdish. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for KDEnum.
FOUNDATION_EXPORT double KDEnumVersionNumber;

//! Project version string for KDEnum.
FOUNDATION_EXPORT const unsigned char KDEnumVersionString[];

BOOL kd_enum_is_valid_value(NSString *enumDefinition, NSNumber *number);

#define KD_ENUM(type, name, ...) \
typedef NS_ENUM(type, name) { \
__VA_ARGS__ \
}; \
\
__attribute__((overloadable)) static inline BOOL __unused KSEnumIsValid##name(name value) \
{ \
  return kd_enum_is_valid_value(@(#__VA_ARGS__), @((name)value)); \
} \
