//
//  AKYSqlite.h
//  scoreMAMA
//
//  Created by Aikyuichi on 12/10/17.
//  MIT License
//  Copyright (c) 2017 Aikyuichi
// 

#import <Foundation/Foundation.h>
#import "AKYDatabase.h"

NS_ASSUME_NONNULL_BEGIN

@interface AKYSqlite : NSObject

+ (void)registerDatabasePath:(NSString *)path forKey:(NSString *)key;

+ (void)registerDatabaseWithName:(NSString *)name fromMainBundleForKey:(NSString *)key;

+ (void)registerDatabaseWithName:(NSString *)name fromDocumentDirectoryForKey:(NSString *)key;

+ (void)unregisterDatabaseForKey:(NSString *)key;

+ (NSString *)databasePathForKey:(NSString *)key;

+ (void)logError;

@end

NS_ASSUME_NONNULL_END
