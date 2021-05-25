//
//  AKYParameter.h
//  bitacora
//
//  Created by Luis Mosquera on 10/5/21.
//  Copyright © 2021 Aikyu - Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKYDataType.h"

NS_ASSUME_NONNULL_BEGIN

@interface AKYParameter : NSObject

@property (nonatomic) AKYDataType type;
@property (nonatomic) NSObject *value;

+ (instancetype)stringParameter:(NSString *)value;

+ (instancetype)integerParameter:(NSInteger)value;

+ (instancetype)doubleParameter:(double)value;

+ (instancetype)boolParameter:(BOOL)value;

+ (instancetype)dataParameter:(NSData *)value;

@end

NS_ASSUME_NONNULL_END
