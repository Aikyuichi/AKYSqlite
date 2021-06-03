//
//  AKYSqlite.m
//  scoreMAMA
//
//  Created by Aikyuichi on 12/10/17.
//  MIT License
//  Copyright (c) 2017 Aikyuichi
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

+ (void)logError {
    sqlite3_config(SQLITE_CONFIG_LOG, errorLogCallback);
}

void errorLogCallback(void *pArg, int iErrCode, const char *zMsg) {
    NSLog(@"SQLite error (%d): %s", iErrCode, zMsg);
}

@end
