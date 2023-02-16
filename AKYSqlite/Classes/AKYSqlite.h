//
//  AKYSqlite.h
//  AKYSqlite
//
//  Created by Aikyuichi on 12/10/17.
//  MIT License
//  Copyright (c) 2021 Aikyuichi
// 

#import <Foundation/Foundation.h>
#import "AKYDatabase.h"

NS_ASSUME_NONNULL_BEGIN

@interface AKYSqlite : NSObject

+ (void)registerDatabasePath:(NSString *)path forKey:(NSString *)key;

+ (void)registerDatabaseWithName:(NSString *)name fromMainBundleForKey:(NSString *)key;

+ (void)registerDatabaseWithName:(NSString *)name fromDocumentDirectoryForKey:(NSString *)key;

+ (void)registerDatabaseWithName:(NSString *)name copyFromMainBundleForKey:(NSString *)key;

+ (void)unregisterDatabaseForKey:(NSString *)key;

+ (NSString *)databasePathForKey:(NSString *)key;

+ (void)runUpdaterForKey:(NSString *)key;

+ (void)logError;

@end

typedef NS_ENUM(NSUInteger, AKYUpdaterErrorLevel) {
    AKYUpdaterErrorLevelSkip,
    AKYUpdaterErrorLevelLog,
};

NS_ASSUME_NONNULL_END
