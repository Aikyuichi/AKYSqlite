//
//  akyDatabase.m
//  akySqlite
//
//  Created by Aikyuichi on 12/10/17.
//  MIT License
//  Copyright (c) 2017 Aikyuichi
//

#import "AKYDatabase.h"

@interface AKYDatabase()

@property (nonatomic, copy) NSString *path;
@property (nonatomic) sqlite3 *sqlite;

@end

@implementation AKYDatabase

+ (instancetype)databaseAtPath:(NSString *)path {
    AKYDatabase *database = [[self alloc] init];
    database.path = path;
    return database;
}

+ (instancetype)databaseForKey:(NSString *)key {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    AKYDatabase *database = [AKYDatabase databaseAtPath:[preferences objectForKey:key]];
    return database;
}

- (BOOL)open {
    if (sqlite3_open(self.path.UTF8String, &_sqlite) != SQLITE_OK) {
        NSLog(@"error: %s", sqlite3_errmsg(self.sqlite));
        return NO;
    }
    return YES;
}

- (BOOL)openInReadonlyMode {
    if (sqlite3_open_v2(self.path.UTF8String, &_sqlite, SQLITE_READONLY, NULL) != SQLITE_OK) {
        NSLog(@"error: %s", sqlite3_errmsg(self.sqlite));
        return NO;
    }
    return YES;
}

- (void)close {
    sqlite3_close(self.sqlite);
}

- (void)attachDatabase:(AKYDatabase *)database withSchema:(NSString *)schema {
    NSString *sql = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS %@", database.path, schema];
    [self executeQuery:sql];
}

- (void)detachDatabaseWithSchema:(NSString *)schema {
    NSString *sql = [NSString stringWithFormat:@"DETACH DATABASE %@", schema];
    [self executeQuery:sql];
}

- (NSInteger)getLastInsertRowId {
    return sqlite3_last_insert_rowid(self.sqlite);
}

- (AKYStatement *)prepareStatement:(NSString *)query {
    return [AKYStatement statementWithSqlite:self.sqlite query:query];
}

- (void)executeQuery:(NSString *)query {
    char *error;
    if (sqlite3_exec(self.sqlite, query.UTF8String, NULL, NULL, &error) != SQLITE_OK) {
        NSLog(@"execute query failed: %s", error);
        sqlite3_free(error);
    }
}

- (void)executeQuery:(NSString *)query parameters:(NSArray<AKYParameter *> *)parameters {
    while (query != nil) {
        AKYStatement *statement = [self prepareStatement:query];
        query = statement.uncompiledSql;
        if (statement != nil) {
            for (int i = 0; i < parameters.count; i++) {
                AKYParameter *parameter = parameters[i];
                [statement bindParameterOnIndex:i + 1 value:parameter];
            }
            [statement step];
            [statement finalize];
        }
    }
}

- (void)executeQuery:(NSString *)query namedParameters:(NSDictionary<NSString *,AKYParameter *> *)parameters {
    while (query != nil) {
        AKYStatement *statement = [self prepareStatement:query];
        query = statement.uncompiledSql;
        if (statement != nil) {
            for (NSString * key in parameters.allKeys) {
                AKYParameter *parameter = parameters[key];
                [statement bindParameterWithName:key value:parameter];
            }
            [statement step];
            [statement finalize];
        }
    }
}

- (NSArray<NSDictionary<NSString *,NSObject *> *> *)select:(NSString *)query parameters:(NSArray<AKYParameter *> *)parameters {
    NSMutableArray *result = [NSMutableArray array];
    AKYStatement *statement = [self prepareStatement:query];
    if (statement != nil) {
        for (int i = 0; i < parameters.count; i++) {
            AKYParameter *parameter = parameters[i];
            [statement bindParameterOnIndex:i + 1 value:parameter];
        }
        @autoreleasepool {
            while ([statement step]) {
                NSMutableDictionary *row = [NSMutableDictionary dictionary];
                for (int i = 0; i < statement.columnCount; i++) {
                    NSString *columnName = [statement getColumnNameOnIndex:i];
                    row[columnName] = [statement getColumnValueOnIndex:i];
                }
                [result addObject:row];
            }
        }
        [statement finalize];
    }
    return result;
}

- (NSArray<NSDictionary<NSString *,NSObject *> *> *)select:(NSString *)query namedParameters:(NSDictionary<NSString *,AKYParameter *> *)parameters {
    NSMutableArray *result = [NSMutableArray array];
    AKYStatement *statement = [self prepareStatement:query];
    if (statement != nil) {
        for (NSString *key in parameters.allKeys) {
            AKYParameter *parameter = parameters[key];
            [statement bindParameterWithName:key value:parameter];
        }
        @autoreleasepool {
            while ([statement step]) {
                NSMutableDictionary *row = [NSMutableDictionary dictionary];
                for (int i = 0; i < statement.columnCount; i++) {
                    NSString *columnName = [statement getColumnNameOnIndex:i];
                    row[columnName] = [statement getColumnValueOnIndex:i];
                }
                [result addObject:row];
            }
        }
        [statement finalize];
    }
    return result;
}

@end
