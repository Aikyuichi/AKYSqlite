//
//  Group.m
//  AKYSqlite_Example
//
//  Created by Luis Mosquera on 25/5/21.
//  Copyright © 2021 Aikyuichi. All rights reserved.
//

#import "Group.h"

@implementation Group

+ (void)groupTest {
    AKYDatabase *db = [AKYDatabase databaseForKey:@"DB_DOC"];
    [db openTransaction];
    AKYStatement *stmtQG = [db prepareStatement:@"INSERT INTO 'group' (name) VALUES ('test')"];
    AKYStatement *stmtQM = [db prepareStatement:@"INSERT INTO group_member VALUES ($group_id, $person_id)"];
    [stmtQG step];
    [stmtQG finalize];
    NSInteger groupId = db.lastInsertRowId;
    [stmtQM bindInteger:groupId forName:@"$group_id"];
    [stmtQM bindInteger:1 forName:@"$person_id"];
    [stmtQM step];
    [stmtQM finalize];
    [db close];
}

@end
