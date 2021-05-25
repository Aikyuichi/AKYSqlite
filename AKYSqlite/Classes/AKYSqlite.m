//
//  AKYSqlite.m
//  scoreMAMA
//
//  Created by Aikyuichi on 12/10/17.
//  MIT License
//  Copyright (c) 2017 Aikyuichi
//  

#import "AKYSqlite.h"

@implementation AKYSqlite

+ (void)registerDatabaseAtPath:(NSString *)path forKey:(NSString *)key {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:path forKey:key];
}

+ (void)registerDatabaseFromMainBundleWithName:(NSString *)name forKey:(NSString *)key {
    NSBundle *thisBundle = [NSBundle mainBundle];
    NSString *dbPath = [thisBundle pathForResource:[[name lastPathComponent] stringByDeletingPathExtension] ofType:[name pathExtension]];
    [self registerDatabaseAtPath:dbPath forKey:key];
}

+ (void)registerDatabaseFromDocumentDirectoryWithName:(NSString *)name forKey:(NSString *)key {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:name];
    [self registerDatabaseAtPath:dbPath forKey:key];
}

+ (void)logError {
    sqlite3_config(SQLITE_CONFIG_LOG, errorLogCallback);
}

void errorLogCallback(void *pArg, int iErrCode, const char *zMsg) {
    NSLog(@"SQLite error (%d): %s", iErrCode, zMsg);
}

@end
