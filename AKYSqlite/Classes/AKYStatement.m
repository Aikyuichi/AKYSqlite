//
//  akyStatement.m
//  akySqlite
//
//  Created by Aikyuichi on 12/10/17.
//  MIT License
//  Copyright (c) 2017 Aikyuichi
//  

#import "AKYStatement.h"

@interface AKYStatement()

@property (nonatomic) sqlite3 *sqlite;
@property (nonatomic) sqlite3_stmt *sqliteStatement;
@property (nonatomic) NSDictionary<NSString *, NSNumber *> *resultColumns;
@property (nonatomic, readwrite) NSString *uncompiledSql;

@end

@implementation AKYStatement

+ (instancetype)statementWithSqlite:(sqlite3 *)sqlite query:(NSString *)query {
    AKYStatement *statement = nil;
    sqlite3_stmt *sqliteStatement = nil;
    const char *uncompiledSql = NULL;
    if (sqlite3_prepare_v2(sqlite, query.UTF8String, -1, &sqliteStatement, &uncompiledSql) == SQLITE_OK) {
        statement = [[self alloc] init];
        statement.sqlite = sqlite;
        statement.sqliteStatement = sqliteStatement;
        if (strlen(uncompiledSql) > 0) {
            statement.uncompiledSql = @(uncompiledSql);
        }
    } else {
        NSLog(@"prepare statement failed: %s", sqlite3_errmsg(sqlite));
    }
    return statement;
}

#pragma mark Helpers

- (NSString *)expandedQuery {
    return @((char *)sqlite3_expanded_sql(self.sqliteStatement));
}

- (int)columnCount {
    return sqlite3_column_count(self.sqliteStatement);
}

- (void)logBindFailed {
    [self rollback];
    NSLog(@"bind failed: %s", sqlite3_errmsg(self.sqlite));
}

- (void)rollback {
    if ([self.transactionDelegate respondsToSelector:@selector(rollback)]) {
        [self.transactionDelegate rollback];
    }
}

#pragma mark Core

- (BOOL)step {
    BOOL result = NO;
    int stepResult = sqlite3_step(self.sqliteStatement);
    if (stepResult == SQLITE_ROW) {
        result = YES;
        if (self.resultColumns == nil) {
            NSMutableDictionary *columns = [NSMutableDictionary dictionary];
            for (int i = 0; i < self.columnCount; i++) {
                columns[[self getColumnNameForIndex:i]] = [NSNumber numberWithInt:i];
            }
            self.resultColumns = columns;
        }
    } else if (stepResult != SQLITE_DONE) {
        [self rollback];
        NSLog(@"step error: %s", sqlite3_errmsg(self.sqlite));
    }
    return result;
}

- (void)reset {
    sqlite3_reset(self.sqliteStatement);
}

- (void)finalize {
    sqlite3_finalize(self.sqliteStatement);
}

#pragma mark Binding (index)

- (void)bindNULLForIndex:(int)index {
    if (sqlite3_bind_null(self.sqliteStatement, index) != SQLITE_OK) {
        [self logBindFailed];
    }
}

- (void)bindInteger:(NSInteger)value forIndex:(int)index {
    if (sqlite3_bind_int64(self.sqliteStatement, index, value) != SQLITE_OK) {
        [self logBindFailed];
    }
}

- (void)bindString:(nullable NSString *)value forIndex:(int)index {
    if (value == nil) {
        [self bindNULLForIndex:index];
    } else {
        if (sqlite3_bind_text(self.sqliteStatement, index, value.UTF8String, -1, SQLITE_STATIC) != SQLITE_OK) {
            [self logBindFailed];
        }
    }
}

- (void)bindDouble:(double)value forIndex:(int)index {
    if (sqlite3_bind_double(self.sqliteStatement, index, value) != SQLITE_OK) {
        [self logBindFailed];
    }
}

- (void)bindBOOL:(BOOL)value forIndex:(int)index {
    if (sqlite3_bind_int(self.sqliteStatement, index, value) != SQLITE_OK) {
        [self logBindFailed];
    }
}

- (void)bindData:(nullable NSData *)value forIndex:(int)index {
    if (value == nil) {
        [self bindNULLForIndex:index];
    } else {
        if (sqlite3_bind_blob(self.sqliteStatement, index, value.bytes, (int)value.length, SQLITE_TRANSIENT) != SQLITE_OK) {
            [self logBindFailed];
        }
    }
}

- (void)bindParameter:(AKYParameter *)value forIndex:(int)index {
    switch (value.type) {
        case AKYDataTypeNull:
            [self bindNULLForIndex:index];
            break;
        case AKYDataTypeString:
            [self bindString:(NSString *)value.value forIndex:index];
            break;
        case AKYDataTypeInteger:
            [self bindInteger:((NSNumber *)value.value).integerValue forIndex:index];
            break;
        case AKYDataTypeDouble:
            [self bindDouble:((NSNumber *)value.value).doubleValue forIndex:index];
            break;
        case AKYDataTypeBool:
            [self bindBOOL:((NSNumber *)value.value).boolValue forIndex:index];
            break;
        case AKYDataTypeData:
            [self bindData:(NSData *)value.value forIndex:index];
            break;
    }
}

#pragma mark Binding (name)

- (void)bindNULLForName:(NSString *)name {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindNULLForIndex:index];
}

- (void)bindInteger:(NSInteger)value forName:(NSString *)name {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindInteger:value forIndex:index];
}

- (void)bindString:(nullable NSString *)value forName:(NSString *)name {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindString:value forIndex:index];
}

- (void)bindDouble:(double)value forName:(NSString *)name {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindDouble:value forIndex:index];
}

- (void)bindBOOL:(BOOL)value forName:(NSString *)name {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindBOOL:value forIndex:index];
}

- (void)bindData:(nullable NSData *)value forName:(NSString *)name {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindData:value forIndex:index];
}

- (void)bindParameter:(AKYParameter *)value forName:(NSString *)name {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindParameter:value forIndex:index];
}

#pragma mark Result (index)

- (BOOL)isNULLForIndex:(int)index {
    return sqlite3_column_type(self.sqliteStatement, index) == SQLITE_NULL;
}

- (NSString *)getColumnNameForIndex:(int)index {
    return @((const char *)sqlite3_column_name(self.sqliteStatement, index));
}

- (NSInteger)getIntegerForIndex:(int)index {
    return sqlite3_column_int64(self.sqliteStatement, index);
}

- (NSInteger)getIntegerOrDefaultForIndex:(int)index {
    if ([self isNULLForIndex:index]) {
        return 0;
    } else {
        return [self getIntegerForIndex:index];
    }
}

- (NSString *)getStringForIndex:(int)index {
    return @((const char *)sqlite3_column_text(self.sqliteStatement, index));
}

- (NSString *)getStringOrDefaultForIndex:(int)index {
    if ([self isNULLForIndex:index]) {
        return nil;
    } else {
        return [self getStringForIndex:index];
    }
}

- (double)getDoubleForIndex:(int)index {
    return sqlite3_column_double(self.sqliteStatement, index);
}

- (BOOL)getBOOLForIndex:(int)index {
    return sqlite3_column_int(self.sqliteStatement, index);
}

- (BOOL)getBOOLOrDefaultForIndex:(int)index {
    if ([self isNULLForIndex:index]) {
        return NO;
    } else {
        return [self getBOOLForIndex:index];
    }
}

- (NSData *)getDataForIndex:(int)index {
    int length = sqlite3_column_bytes(self.sqliteStatement, index);
    return [NSData dataWithBytes:sqlite3_column_blob(self.sqliteStatement, index) length:length];
}

- (NSObject *)getValueForIndex:(int)index {
    int dataType = sqlite3_column_type(self.sqliteStatement, index);
    switch (dataType) {
        case SQLITE_INTEGER:
            return [NSNumber numberWithInteger:[self getIntegerForIndex:index]];
        case SQLITE_FLOAT:
            return [NSNumber numberWithDouble:[self getDoubleForIndex:index]];
        case SQLITE_TEXT:
            return [self getStringForIndex:index];
        case SQLITE_BLOB:
            return [self getDataForIndex:index];
        case SQLITE_NULL:
        default:
            return nil;
    }
}

#pragma mark Result (name)

- (BOOL)isNULLForName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self isNULLForIndex:index];
}

- (NSInteger)getIntegerForName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getIntegerForIndex:index];
}

- (NSInteger)getIntegerOrDefaultForName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getIntegerOrDefaultForIndex:index];
}

- (NSString *)getStringForName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getStringForIndex:index];
}

- (NSString *)getStringOrDefaultForName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getStringOrDefaultForIndex:index];
}

- (double)getDoubleForName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getDoubleForIndex:index];
}

- (BOOL)getBOOLForName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getBOOLForIndex:index];
}

- (BOOL)getBOOLOrDefaultForName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getBOOLOrDefaultForIndex:index];
}

- (NSData *)getDataForName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getDataForIndex:index];
}

- (NSObject *)getValueForName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getValueForIndex:index];
}

@end
