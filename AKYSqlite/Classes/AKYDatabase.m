//
//  AKYDatabase.m
//  AKYSqlite
//
//  Created by Aikyuichi on 12/10/17.
//  MIT License
//  Copyright (c) 2021 Aikyuichi
//

#import "AKYDatabase.h"

@interface AKYDatabase() <AKYTransaction>

@property (nonatomic, copy) NSString *path;
@property (nonatomic) sqlite3 *sqlite;
@property (nonatomic) BOOL transactional;
@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL rollbackTransaction;
@property (nonatomic) NSMutableArray<NSString *> *deferredAttachments;

@end

@implementation AKYDatabase

+ (instancetype)databaseAtPath:(NSString *)path {
    AKYDatabase *database = [[self alloc] init];
    database.path = path;
    database.deferredAttachments = [NSMutableArray array];
    return database;
}

+ (instancetype)databaseForKey:(NSString *)key {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *dbPaths = [prefs objectForKey:@"AKYSqlite_db_paths"];
    AKYDatabase *database = [AKYDatabase databaseAtPath:dbPaths[key]];
    return database;
}

- (BOOL)open {
    if (sqlite3_open(self.path.UTF8String, &_sqlite) != SQLITE_OK) {
        NSLog(@"error: %s", sqlite3_errmsg(self.sqlite));
        return NO;
    }
    self.isOpen = YES;
    for (NSString *attachement in self.deferredAttachments) {
        [self executeQuery:attachement];
    }
    return YES;
}

- (BOOL)openInReadonlyMode {
    if (sqlite3_open_v2(self.path.UTF8String, &_sqlite, SQLITE_OPEN_READONLY, NULL) != SQLITE_OK) {
        NSLog(@"error: %s", sqlite3_errmsg(self.sqlite));
        return NO;
    }
    self.isOpen = YES;
    for (NSString *attachement in self.deferredAttachments) {
        [self executeQuery:attachement];
    }
    return YES;
}

- (BOOL)openTransaction {
    if ([self open]) {
        [self executeQuery:@"BEGIN TRANSACTION"];
        self.transactional = YES;
        return YES;
    }
    return NO;
}

- (void)closeTransaction {
    if (self.transactional) {
        if (self.rollbackTransaction) {
            [self executeQuery:@"ROLLBACK"];
            NSLog(@"Rollback transaction");
        } else {
            [self executeQuery:@"COMMIT"];
        }
    }
    self.transactional = NO;
    self.rollbackTransaction = NO;
}

- (void)close {
    [self closeTransaction];
    sqlite3_close(self.sqlite);
    self.isOpen = NO;
}

- (void)attachDatabase:(AKYDatabase *)database withSchema:(NSString *)schema {
    NSString *sql = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS %@", database.path, schema];
    if (self.isOpen) {
        [self executeQuery:sql];
    } else {
        [self.deferredAttachments addObject:sql];
    }
}

- (void)detachDatabaseWithSchema:(NSString *)schema {
    NSString *sql = [NSString stringWithFormat:@"DETACH DATABASE %@", schema];
    [self executeQuery:sql];
}

- (void)rollback {
    self.rollbackTransaction = YES;
}

- (NSInteger)lastInsertRowId {
    return sqlite3_last_insert_rowid(self.sqlite);
}

- (NSInteger)userVersion {
    NSInteger version = 0;
    AKYStatement *stmt = [self prepareStatement:@"PRAGMA user_version"];
    if (stmt != nil) {
        if ([stmt step]) {
            version = [stmt getIntegerForIndex:0];
        }
        [stmt finalize];
    }
    return version;
}

- (nullable AKYStatement *)prepareStatement:(NSString *)query {
    AKYStatement *statement = [AKYStatement statementWithSqlite:self.sqlite query:query];
    if (self.transactional) {
        if (statement != nil) {
            statement.transactionDelegate = self;
        } else {
            self.rollbackTransaction = YES;
        }
    }
    return statement;
}

- (void)executeQuery:(NSString *)query {
    char *error;
    if (sqlite3_exec(self.sqlite, query.UTF8String, NULL, NULL, &error) != SQLITE_OK) {
        self.rollbackTransaction = YES;
        NSLog(@"execute query failed: %s", error);
        sqlite3_free(error);
    }
}

- (void)executeStatement:(NSString *)query parameters:(NSArray<AKYParameter *> *)parameters {
    AKYStatement *statement = [self prepareStatement:query];
    if (statement != nil) {
        for (int i = 0; i < parameters.count; i++) {
            AKYParameter *parameter = parameters[i];
            [statement bindParameter:parameter forIndex:i + 1];
        }
        [statement step];
        [statement finalize];
    }
}

- (void)executeStatement:(NSString *)query namedParameters:(NSDictionary<NSString *,AKYParameter *> *)parameters {
    AKYStatement *statement = [self prepareStatement:query];
    if (statement != nil) {
        for (NSString * key in parameters.allKeys) {
            AKYParameter *parameter = parameters[key];
            [statement bindParameter:parameter forName:key];
        }
        [statement step];
        [statement finalize];
    }
}

- (NSArray<NSDictionary<NSString *,NSObject *> *> *)select:(NSString *)query parameters:(NSArray<AKYParameter *> *)parameters {
    NSMutableArray *result = [NSMutableArray array];
    AKYStatement *statement = [self prepareStatement:query];
    if (statement != nil) {
        for (int i = 0; i < parameters.count; i++) {
            AKYParameter *parameter = parameters[i];
            [statement bindParameter:parameter forIndex:i + 1];
        }
        @autoreleasepool {
            while ([statement step]) {
                NSMutableDictionary *row = [NSMutableDictionary dictionary];
                for (int i = 0; i < statement.columnCount; i++) {
                    NSString *columnName = [statement getColumnNameForIndex:i];
                    row[columnName] = [statement getValueForIndex:i];
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
            [statement bindParameter:parameter forName:key];
        }
        @autoreleasepool {
            while ([statement step]) {
                NSMutableDictionary *row = [NSMutableDictionary dictionary];
                for (int i = 0; i < statement.columnCount; i++) {
                    NSString *columnName = [statement getColumnNameForIndex:i];
                    row[columnName] = [statement getValueForIndex:i];
                }
                [result addObject:row];
            }
        }
        [statement finalize];
    }
    return result;
}

@end
