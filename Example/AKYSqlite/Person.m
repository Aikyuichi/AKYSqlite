//
//  Person.m
//  AKYSqlite_Example
//
//  Created by Luis Mosquera on 24/5/21.
//  Copyright © 2021 Aikyuichi. All rights reserved.
//

#import "Person.h"

@implementation Person

+ (NSArray<Person *> *)list {
    NSMutableArray *persons = [NSMutableArray array];
    AKYDatabase *db = [AKYDatabase databaseForKey:@"DB_MAIN"];
    [db openInReadonlyMode];
    AKYStatement *stmt = [db prepareStatement:@"SELECT name, lastname FROM person ORDER BY name"];
    if (stmt != nil) {
        while ([stmt step]) {
            Person *person = [[Person alloc] init];
            person.name = [stmt getStringForName:@"name"];
            person.lastname = [stmt getStringOrDefaultForName:@"lastname"];
            [persons addObject:person];
        }
        [stmt finalize];
    }
    [db close];
    return persons;
}

@end
