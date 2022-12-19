//
//  AKYParameter.h
//  AKYSqlite
//
//  Created by Aikyuichi on 10/5/21.
//  MIT License
//  Copyright (c) 2021 Aikyuichi
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
