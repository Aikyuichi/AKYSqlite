//
//  Person.m
//  AKYSqlite_Example
//
//  Created by Luis Mosquera on 24/5/21.
//  Copyright © 2021 Aikyuichi. All rights reserved.
//

#import "Contact.h"

@implementation Contact

+ (NSArray<Contact *> *)list {
    NSMutableArray *persons = [NSMutableArray array];
    AKYDatabase *db = [AKYDatabase databaseForKey:@"DB_MAIN"];
    [db open];
    AKYStatement *stmt = [db prepareStatement:@"SELECT name, lastname FROM person ORDER BY name"];
    if (stmt != nil) {
        while ([stmt step]) {
            Contact *person = [[Contact alloc] init];
            person.name = [stmt getColumnStringWithName:@"name"];
            person.lastname = [stmt getColumnStringOrDefaultWithName:@"lastname"];
            [persons addObject:person];
        }
        [stmt finalize];
    }
    [db close];
    return persons;
}

@end
