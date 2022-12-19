//
//  AKYSqlite.m
//  AKYSqlite
//
//  Created by Aikyuichi on 12/10/17.
//  MIT License
//  Copyright (c) 2021 Aikyuichi
//  

#import "AKYSqlite.h"

NSString *const AKYSQLITE_DB_PATHS = @"AKYSqlite_db_paths";

@implementation AKYSqlite

+ (void)registerDatabasePath:(NSString *)path forKey:(NSString *)key {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dbPaths = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:AKYSQLITE_DB_PATHS]];
    [dbPaths setObject:path forKey:key];
    [prefs setObject:dbPaths forKey:AKYSQLITE_DB_PATHS];
}

+ (void)registerDatabaseWithName:(NSString *)name fromMainBundleForKey:(NSString *)key {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *dbPath = [mainBundle pathForResource:[name.lastPathComponent stringByDeletingPathExtension] ofType:name.pathExtension];
    [self registerDatabasePath:dbPath forKey:key];
}

+ (void)registerDatabaseWithName:(NSString *)name fromDocumentDirectoryForKey:(NSString *)key {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dbPath = [documentPath stringByAppendingPathComponent:name];
    [self registerDatabasePath:dbPath forKey:key];
}

+ (void)registerDatabaseWithName:(NSString *)name copyFromMainBundleForKey:(NSString *)key {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *dbPathFrom = [mainBundle pathForResource:[name.lastPathComponent stringByDeletingPathExtension] ofType:name.pathExtension];
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dbPathTo = [documentPath stringByAppendingPathComponent:name];
    if (![NSFileManager.defaultManager fileExistsAtPath:dbPathTo]) {
        [NSFileManager.defaultManager copyItemAtPath:dbPathFrom toPath:dbPathTo error:NULL];
    }
    [self registerDatabasePath:dbPathTo forKey:key];
}

+ (void)unregisterDatabaseForKey:(NSString *)key {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dbPaths = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:AKYSQLITE_DB_PATHS]];
    [dbPaths removeObjectForKey:key];
    [prefs setObject:dbPaths forKey:AKYSQLITE_DB_PATHS];
}

+ (NSString *)databasePathForKey:(NSString *)key {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dbPaths = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:AKYSQLITE_DB_PATHS]];
    return dbPaths[key];
}

+ (void)runUpdaterForKey:(NSString *)key {
    NSArray *updates = [self getUpdatesForKey:key];
    if (updates.count == 0) {
        return;
    }
    for (NSDictionary *update in updates) {
        if (![self executeUpdate:update]) {
            NSLog(@"update failed: %@", update);
            break;
        }
    }
}

+ (NSArray *)getUpdatesForKey:(NSString *)key {
    NSMutableArray *updates = [NSMutableArray array];
    AKYDatabase *db = [AKYDatabase databaseForKey:key];
    if ([db open]) {
        AKYStatement *stmt = [db prepareStatement:@"SELECT id, db_key, db_version, sql, error_level, date FROM updater"];
        if (stmt != nil) {
            while ([stmt step]) {
                NSNumber *codigo = [NSNumber numberWithInteger:[stmt getIntegerForName:@"id"]];
                NSString *dbKey = [stmt getStringForName:@"db_key"];
                NSNumber *dbVersion = [NSNumber numberWithInteger:[stmt getIntegerForName:@"db_version"]];
                NSString *sql = [stmt getStringForName:@"sql"];
                NSNumber *error_level = [NSNumber numberWithInteger:[stmt getIntegerForName:@"error_level"]];
                NSString *date = [stmt getStringForName:@"date"];
                [updates addObject:@{@"id":codigo, @"dbVersion":dbVersion, @"dbKey":dbKey, @"sql":sql, @"errorLevel":error_level, @"date":date}];
            }
            [stmt finalize];
        }
        [db close];
    }
    return updates;
}

+ (BOOL)executeUpdate:(NSDictionary *)update {
    BOOL result = NO;
    NSString *dbKey = [update objectForKey:@"dbKey"];
    NSNumber *dbVersion = [update objectForKey:@"dbVersion"];
    if ([self existsDatabaseWithKey:dbKey]) {
        AKYDatabase *db = [AKYDatabase databaseForKey:dbKey];
        if ([db openTransaction]) {
            if (db.userVersion <= dbVersion.integerValue) {
                NSString *sql = [update objectForKey:@"sql"];
                NSArray *statements = [sql componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
                for (NSString *statement in statements) {
                    if (statement.length > 0) {
                        AKYStatement *stmt = [db prepareStatement:statement];
                        [stmt step];
                        [stmt finalize];
                        result = stmt != nil && !stmt.failed;
                        if (!result) {
                            break;
                        }
                    }
                }
            } else {
                result = YES;
            }
            [db close];
        }
    }
    return result;
}

+ (BOOL)existsDatabaseWithKey:(NSString *)key {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dbPaths = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:AKYSQLITE_DB_PATHS]];
    NSString *dbPath = dbPaths[key];
    return [manager fileExistsAtPath:dbPath];
}

+ (void)logError {
    sqlite3_config(SQLITE_CONFIG_LOG, errorLogCallback);
}

void errorLogCallback(void *pArg, int iErrCode, const char *zMsg) {
    NSLog(@"SQLite error (%d): %s", iErrCode, zMsg);
}

@end
