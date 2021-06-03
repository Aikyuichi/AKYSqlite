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

NS_ASSUME_NONNULL_BEGIN

@protocol AKYTransaction <NSObject>

- (void)rollback;

@end

@interface AKYStatement : NSObject

@property (nonatomic, weak) id<AKYTransaction> transactionDelegate;

+ (instancetype)statementWithSqlite:(sqlite3 *)sqlite query:(NSString *)query;

#pragma mark - Helpers

@property (nonatomic, readonly) NSString *expandedQuery API_AVAILABLE(macos(10.12), ios(10.0));

@property (nonatomic, readonly) NSString *uncompiledSql;

@property (nonatomic, readonly) int columnCount;

#pragma mark Core

- (BOOL)step;

- (void)reset;

- (void)finalize;

#pragma mark Binding (index)

- (void)bindNULLForIndex:(int)index;

- (void)bindInteger:(NSInteger)value forIndex:(int)index;

- (void)bindString:(nullable NSString *)value forIndex:(int)index;

- (void)bindDouble:(double)value forIndex:(int)index;

- (void)bindBOOL:(BOOL)value forIndex:(int)index;

- (void)bindData:(nullable NSData *)value forIndex:(int)index;

- (void)bindParameter:(AKYParameter *)value forIndex:(int)index;

#pragma mark Binding (name)

- (void)bindNULLForName:(NSString *)name;

- (void)bindInteger:(NSInteger)value forName:(NSString *)name;

- (void)bindString:(nullable NSString *)value forName:(NSString *)name;

- (void)bindDouble:(double)value forName:(NSString *)name;

- (void)bindBOOL:(BOOL)value forName:(NSString *)name;

- (void)bindData:(nullable NSData *)value forName:(NSString *)name;

- (void)bindParameter:(AKYParameter *)value forName:(NSString *)name;

#pragma mark Result (index)

- (BOOL)isNULLForIndex:(int)index;

- (NSString *)getColumnNameForIndex:(int)index;

- (NSInteger)getIntegerForIndex:(int)index;

- (NSInteger)getIntegerOrDefaultForIndex:(int)index;

- (NSString *)getStringForIndex:(int)index;

- (NSString *)getStringOrDefaultForIndex:(int)index;

- (double)getDoubleForIndex:(int)index;

- (BOOL)getBOOLForIndex:(int)index;

- (BOOL)getBOOLOrDefaultForIndex:(int)index;

- (NSData *)getDataForIndex:(int)index;

- (NSObject *)getValueForIndex:(int)index;

#pragma mark Result (name)

- (BOOL)isNULLForName:(NSString *)name;

- (NSInteger)getIntegerForName:(NSString *)name;

- (NSInteger)getIntegerOrDefaultForName:(NSString *)name;

- (NSString *)getStringForName:(NSString *)name;

- (NSString *)getStringOrDefaultForName:(NSString *)name;

- (double)getDoubleForName:(NSString *)name;

- (BOOL)getBOOLForName:(NSString *)name;

- (BOOL)getBOOLOrDefaultForName:(NSString *)name;

- (NSData *)getDataForName:(NSString *)name;

- (NSObject *)getValueForName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
