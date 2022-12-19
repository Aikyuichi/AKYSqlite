//
//  AKYParameter.m
//  AKYSqlite
//
//  Created by Aikyuichi on 10/5/21.
//  MIT License
//  Copyright (c) 2021 Aikyuichi
//

#import "AKYParameter.h"

@interface AKYParameter()

@end

@implementation AKYParameter

+ (instancetype)stringParameter:(NSString *)value {
    AKYParameter *parameter = [[self alloc] init];
    parameter.type = AKYDataTypeString;
    parameter.value  = value;
    return parameter;
}

+ (instancetype)integerParameter:(NSInteger)value {
    AKYParameter *parameter = [[self alloc] init];
    parameter.type = AKYDataTypeInteger;
    parameter.value  = [NSNumber numberWithInteger:value];
    return parameter;
}

+ (instancetype)doubleParameter:(double)value {
    AKYParameter *parameter = [[self alloc] init];
    parameter.type = AKYDataTypeDouble;
    parameter.value  = [NSNumber numberWithDouble:value];
    return parameter;
}

+ (instancetype)boolParameter:(BOOL)value {
    AKYParameter *parameter = [[self alloc] init];
    parameter.type = AKYDataTypeBool;
    parameter.value  = [NSNumber numberWithBool:value];
    return parameter;
}

+ (instancetype)dataParameter:(NSData *)value {
    AKYParameter *parameter = [[self alloc] init];
    parameter.type = AKYDataTypeData;
    parameter.value = value;
    return parameter;
}

@end
