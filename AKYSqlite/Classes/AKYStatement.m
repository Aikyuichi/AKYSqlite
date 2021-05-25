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

#pragma mark Core

- (BOOL)step {
    BOOL result = NO;
    int stepResult = sqlite3_step(self.sqliteStatement);
    if (stepResult == SQLITE_ROW) {
        result = YES;
        if (self.resultColumns == nil) {
            NSMutableDictionary *columns = [NSMutableDictionary dictionary];
            for (int i = 0; i < self.columnCount; i++) {
                columns[[self getColumnNameOnIndex:i]] = [NSNumber numberWithInt:i];
            }
            self.resultColumns = columns;
        }
    } else if (stepResult != SQLITE_DONE) {
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

- (void)bindNULLOnIndex:(int)index {
    if (sqlite3_bind_null(self.sqliteStatement, index) != SQLITE_OK) {
        [self logBindFailed];
    }
}

- (void)bindIntegerOnIndex:(int)index value:(NSInteger)value {
    if (sqlite3_bind_int64(self.sqliteStatement, index, value) != SQLITE_OK) {
        [self logBindFailed];
    }
}

- (void)bindStringOnIndex:(int)index value:(NSString *)value {
    if (sqlite3_bind_text(self.sqliteStatement, index, value.UTF8String, -1, SQLITE_STATIC) != SQLITE_OK) {
        [self logBindFailed];
    }
}

- (void)bindStringOrNULLOnIndex:(int)index value:(NSString *)value {
    if (value == nil) {
        [self bindNULLOnIndex:index];
    } else {
        [self bindStringOnIndex:index value:value];
    }
}

- (void)bindDoubleOnIndex:(int)index value:(double)value {
    if (sqlite3_bind_double(self.sqliteStatement, index, value) != SQLITE_OK) {
        [self logBindFailed];
    }
}

- (void)bindBOOLOnIndex:(int)index value:(BOOL)value {
    if (sqlite3_bind_int(self.sqliteStatement, index, value) != SQLITE_OK) {
        [self logBindFailed];
    }
}

- (void)bindDataOnIndex:(int)index value:(NSData *)value {
    if (sqlite3_bind_blob(self.sqliteStatement, index, value.bytes, (int)value.length, SQLITE_TRANSIENT) != SQLITE_OK) {
        [self logBindFailed];
    }
}

- (void)bindDataOrNULLOnIndex:(int)index value:(NSData *)value {
    if (value == nil) {
        [self bindNULLOnIndex:index];
    } else {
        [self bindDataOnIndex:index value:value];
    }
}

- (void)bindParameterOnIndex:(int)index value:(AKYParameter *)value {
    switch (value.type) {
        case AKYDataTypeNull:
            [self bindNULLOnIndex:index];
            break;
        case AKYDataTypeString:
            [self bindStringOnIndex:index value:(NSString *)value.value];
            break;
        case AKYDataTypeInteger:
            [self bindIntegerOnIndex:index value:((NSNumber *)value.value).integerValue];
            break;
        case AKYDataTypeDouble:
            [self bindDoubleOnIndex:index value:((NSNumber *)value.value).doubleValue];
            break;
        case AKYDataTypeBool:
            [self bindBOOLOnIndex:index value:((NSNumber *)value.value).boolValue];
            break;
        case AKYDataTypeData:
            [self bindDataOnIndex:index value:(NSData *)value.value];
            break;
    }
}

#pragma mark Binding (name)

- (void)bindNULLWithName:(NSString *)name {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindNULLOnIndex:index];
}

- (void)bindIntegerWithName:(NSString *)name value:(NSInteger)value {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindIntegerOnIndex:index value:value];
}

- (void)bindStringWithName:(NSString *)name value:(NSString *)value {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindStringOnIndex:index value:value];
}

- (void)bindStringOrNULLWithName:(NSString *)name value:(NSString *)value {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindStringOrNULLOnIndex:index value:value];
}

- (void)bindDoubleWithName:(NSString *)name value:(double)value {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindDoubleOnIndex:index value:value];
}

- (void)bindBOOLWithName:(NSString *)name value:(BOOL)value {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindBOOLOnIndex:index value:value];
}

- (void)bindDataWithName:(NSString *)name value:(NSData *)value {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindDataOnIndex:index value:value];
}

- (void)bindDataOrNULLWithName:(NSString *)name value:(NSData *)value {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindDataOrNULLOnIndex:index value:value];
}

- (void)bindParameterWithName:(NSString *)name value:(AKYParameter *)value {
    int index = sqlite3_bind_parameter_index(self.sqliteStatement, name.UTF8String);
    [self bindParameterOnIndex:index value:value];
}

#pragma mark Result (index)

- (BOOL)isColumnNULLOnIndex:(int)index {
    return sqlite3_column_type(self.sqliteStatement, index) == SQLITE_NULL;
}

- (NSString *)getColumnNameOnIndex:(int)index {
    return @((const char *)sqlite3_column_name(self.sqliteStatement, index));
}

- (NSInteger)getColumnIntegerOnIndex:(int)index {
    return sqlite3_column_int64(self.sqliteStatement, index);
}

- (NSInteger)getColumnIntegerOrDefaultOnIndex:(int)index {
    if ([self isColumnNULLOnIndex:index]) {
        return 0;
    } else {
        return [self getColumnIntegerOnIndex:index];
    }
}

- (NSString *)getColumnStringOnIndex:(int)index {
    return @((const char *)sqlite3_column_text(self.sqliteStatement, index));
}

- (NSString *)getColumnStringOrDefaultOnIndex:(int)index {
    if ([self isColumnNULLOnIndex:index]) {
        return nil;
    } else {
        return [self getColumnStringOnIndex:index];
    }
}

- (double)getColumnDoubleOnIndex:(int)index {
    return sqlite3_column_double(self.sqliteStatement, index);
}

- (BOOL)getColumnBOOLOnIndex:(int)index {
    return sqlite3_column_int(self.sqliteStatement, index);
}

- (BOOL)getColumnBOOLOrDefaultOnIndex:(int)index {
    if ([self isColumnNULLOnIndex:index]) {
        return NO;
    } else {
        return [self getColumnBOOLOnIndex:index];
    }
}

- (NSData *)getColumnDataOnIndex:(int)index {
    int length = sqlite3_column_bytes(self.sqliteStatement, index);
    return [NSData dataWithBytes:sqlite3_column_blob(self.sqliteStatement, index) length:length];
}

- (NSObject *)getColumnValueOnIndex:(int)index {
    int dataType = sqlite3_column_type(self.sqliteStatement, index);
    switch (dataType) {
        case SQLITE_INTEGER:
            return [NSNumber numberWithInteger:[self getColumnIntegerOnIndex:index]];
        case SQLITE_FLOAT:
            return [NSNumber numberWithDouble:[self getColumnDoubleOnIndex:index]];
        case SQLITE_TEXT:
            return [self getColumnStringOnIndex:index];
        case SQLITE_BLOB:
            return [self getColumnDataOnIndex:index];
        case SQLITE_NULL:
        default:
            return nil;
    }
}

#pragma mark Result (name)

- (BOOL)isColumnNULLWithName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self isColumnNULLOnIndex:index];
}

- (NSInteger)getColumnIntegerWithName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getColumnIntegerOnIndex:index];
}

- (NSInteger)getColumnIntegerOrDefaultWithName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getColumnIntegerOrDefaultOnIndex:index];
}

- (NSString *)getColumnStringWithName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getColumnStringOnIndex:index];
}

- (NSString *)getColumnStringOrDefaultWithName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getColumnStringOrDefaultOnIndex:index];
}

- (double)getColumnDoubleWithName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getColumnDoubleOnIndex:index];
}

- (BOOL)getColumnBOOLWithName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getColumnBOOLOnIndex:index];
}

- (BOOL)getColumnBOOLOrDefaultWitnName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getColumnBOOLOrDefaultOnIndex:index];
}

- (NSData *)getColumnDataWithName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getColumnDataOnIndex:index];
}

- (NSObject *)getColumnValueWithName:(NSString *)name {
    int index = self.resultColumns[name].intValue;
    return [self getColumnValueOnIndex:index];
}

#pragma mark Helpers

- (NSString *)expandedQuery {
    return @((char *)sqlite3_expanded_sql(self.sqliteStatement));
}

- (int)columnCount {
    return sqlite3_column_count(self.sqliteStatement);
}

- (void)logBindFailed {
    NSLog(@"bind failed: %s", sqlite3_errmsg(self.sqlite));
}

@end
