//
//  akyStatement.h
//  akySqlite
//
//  Created by Aikyuichi on 12/10/17.
//  MIT License
//  Copyright (c) 2017 Aikyuichi
//  

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "AKYParameter.h"

@interface AKYStatement : NSObject

+ (instancetype)statementWithSqlite:(sqlite3 *)sqlite query:(NSString *)query;

#pragma mark Core

- (BOOL)step;

- (void)reset;

- (void)finalize;

#pragma mark Binding (index)

- (void)bindNULLOnIndex:(int)index;

- (void)bindIntegerOnIndex:(int)index value:(NSInteger)value;

- (void)bindStringOnIndex:(int)index value:(NSString *)value;

- (void)bindStringOrNULLOnIndex:(int)index value:(NSString *)value;

- (void)bindDoubleOnIndex:(int)index value:(double)value;

- (void)bindBOOLOnIndex:(int)index value:(BOOL)value;

- (void)bindDataOnIndex:(int)index value:(NSData *)value;

- (void)bindDataOrNULLOnIndex:(int)index value:(NSData *)value;

- (void)bindParameterOnIndex:(int)index value:(AKYParameter *)value;

#pragma mark Binding (name)

- (void)bindNULLWithName:(NSString *)name;

- (void)bindIntegerWithName:(NSString *)name value:(NSInteger)value;

- (void)bindStringWithName:(NSString *)name value:(NSString *)value;

- (void)bindStringOrNULLWithName:(NSString *)name value:(NSString *)value;

- (void)bindDoubleWithName:(NSString *)name value:(double)value;

- (void)bindBOOLWithName:(NSString *)name value:(BOOL)value;

- (void)bindDataWithName:(NSString *)name value:(NSData *)value;

- (void)bindDataOrNULLWithName:(NSString *)name value:(NSData *)value;

- (void)bindParameterWithName:(NSString *)name value:(AKYParameter *)value;

#pragma mark Result (index)

- (BOOL)isColumnNULLOnIndex:(int)index;

- (NSString *)getColumnNameOnIndex:(int)index;

- (NSInteger)getColumnIntegerOnIndex:(int)index;

- (NSInteger)getColumnIntegerOrDefaultOnIndex:(int)index;

- (NSString *)getColumnStringOnIndex:(int)index;

- (NSString *)getColumnStringOrDefaultOnIndex:(int)index;

- (double)getColumnDoubleOnIndex:(int)index;

- (BOOL)getColumnBOOLOnIndex:(int)index;

- (BOOL)getColumnBOOLOrDefaultOnIndex:(int)index;

- (NSData *)getColumnDataOnIndex:(int)index;

- (NSObject *)getColumnValueOnIndex:(int)index;

#pragma mark Result (name)

- (BOOL)isColumnNULLWithName:(NSString *)name;

- (NSInteger)getColumnIntegerWithName:(NSString *)name;

- (NSInteger)getColumnIntegerOrDefaultWithName:(NSString *)name;

- (NSString *)getColumnStringWithName:(NSString *)name;

- (NSString *)getColumnStringOrDefaultWithName:(NSString *)name;

- (double)getColumnDoubleWithName:(NSString *)name;

- (BOOL)getColumnBOOLWithName:(NSString *)name;

- (BOOL)getColumnBOOLOrDefaultWitnName:(NSString *)name;

- (NSData *)getColumnDataWithName:(NSString *)name;

- (NSObject *)getColumnValueWithName:(NSString *)name;

#pragma mark - Helpers

@property (nonatomic, readonly) NSString *expandedQuery API_AVAILABLE(macos(10.12), ios(10.0));

@property (nonatomic, readonly) NSString *uncompiledSql;

@property (nonatomic, readonly) int columnCount;

@end
