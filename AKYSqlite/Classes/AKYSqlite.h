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

@interface AKYSqlite : NSObject

+ (void)registerDatabaseAtPath:(NSString *)path forKey:(NSString *)key;

+ (void)registerDatabaseFromMainBundleWithName:(NSString *)name forKey:(NSString *)key;

+ (void)registerDatabaseFromDocumentDirectoryWithName:(NSString *)name forKey:(NSString *)key;

+ (void)logError;

@end
