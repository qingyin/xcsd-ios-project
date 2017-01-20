//
//  XCSDTestDao.m
//  Pods
//
//  Created by gaoju on 16/8/30.
//
//

#import "XCSDTestDao.h"

@implementation XCSDTestDao


- (NSArray *)queryTest:(NSString *)testId count:(NSInteger)count error:(NSError *)outError{
    
    __block NSMutableArray *tests = [NSMutableArray arrayWithCapacity:1];
    
    NSString *sql = @"SELECT * FROM test WHERE CAST(testId AS int)<? limit 0,?";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
       
        FMResultSet *set = [db executeQuery:sql, testId, @(count)];
        while (set.next) {
            XCSDTestInfo *test = [XCSDTestInfo.new loadValueFromFMResultSet:set];
            [tests addObject:test];
        }
        [set close];
    }];
    
    return tests.copy;
}

- (void)updateTest:(XCSDTestInfo *)testInfo{
    
    NSString *sql = @"UPDATE test SET status=? WHERE testId=?";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
       
        [db executeUpdate:sql, @(testInfo.status), testInfo.testId];
    }];
}

- (XCSDTestInfo *)queryLastTest{
    
    __block XCSDTestInfo *test = [[XCSDTestInfo alloc] init];
    
    NSString *sql = @"SELECT * FROM test ORDER BY testId DESC LIMIT 0,1";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *set = [db executeQuery:sql];
        if (set.next) {
            test = [test loadValueFromFMResultSet:set];
        }
        [set close];
    }];
    
    return test;
}

- (void)addTest:(XCSDTestInfo *)testInfo error:(NSError **)outError{
    
    NSString *sql = @"REPLACE INTO test(id, testId,testDescription,name,associateTag,animalPic,status, colorValue) VALUES(?,?,?,?,?,?,?,?)";
    
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        
        if (![db executeUpdate:sql withErrorAndBindings:outError,@(testInfo.testId.integerValue) ,testInfo.testId, testInfo.testDescription, testInfo.name, testInfo.associateTag, testInfo.animalPic, @(testInfo.status), testInfo.colorValue]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteAllTest{
    
    NSString *sql = @"DELETE FROM test";
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)deleteTest:(NSString *)testId{
    NSString *sql = @"DELETE FROM test WHERE testId=?";
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, testId];
    }];
}

@end
