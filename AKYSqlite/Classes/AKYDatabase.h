//
//  akyDatabase.h
//  akySqlite
//
//  Created by Aikyuichi on 12/10/17.
//  MIT License
//  Copyright (c) 2017 Aikyuichi
//

#import <Foundation/Foundation.h>
#import "AKYStatement.h"

@interface AKYDatabase : NSObject

+ (instancetype)databaseAtPath:(NSString *)path;

+ (instancetype)databaseForKey:(NSString *)key;

- (BOOL)open;

- (BOOL)openInReadonlyMode;

- (void)close;

- (void)attachDatabase:(AKYDatabase *)database withSchema:(NSString *)schema;

- (void)detachDatabaseWithSchema:(NSString *)schema;

- (NSInteger)getLastInsertRowId;

- (AKYStatement *)prepareStatement:(NSString *)query;

- (void)executeQuery:(NSString *)query;

- (void)executeQuery:(NSString *)query parameters:(NSArray<AKYParameter *> *)parameters;

- (void)executeQuery:(NSString *)query namedParameters:(NSDictionary<NSString *,AKYParameter *> *)parameters;

- (NSArray<NSDictionary<NSString *,NSObject *> *> *)select:(NSString *)query parameters:(NSArray<AKYParameter *> *)parameters;

- (NSArray<NSDictionary<NSString *,NSObject *> *> *)select:(NSString *)query namedParameters:(NSDictionary<NSString *,AKYParameter *> *)parameters;

@end
