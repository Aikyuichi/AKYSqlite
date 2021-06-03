//
//  Person.h
//  AKYSqlite_Example
//
//  Created by Luis Mosquera on 24/5/21.
//  Copyright © 2021 Aikyuichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AKYSqlite/AKYSqlite.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *lastname;

+ (NSArray<Person *> *)list;

@end

NS_ASSUME_NONNULL_END
