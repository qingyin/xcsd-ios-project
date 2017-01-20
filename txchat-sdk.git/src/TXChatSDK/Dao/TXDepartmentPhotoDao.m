//
// Created by lingqingwan on 9/22/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXDepartmentPhotoDao.h"


@implementation TXDepartmentPhotoDao {

}

- (NSArray *)queryDepartmentPhotos:(int64_t)departmentId
              maxDepartmentPhotoId:(int64_t)maxDepartmentPhotoId
                             count:(int64_t)count
                             error:(NSError **)outError {
    __block NSMutableArray *txDepartmentPhotos = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM department_photo WHERE department_id=? AND department_photo_id<? ORDER BY department_photo_id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql,
                                                  @(departmentId),
                                                  @(maxDepartmentPhotoId),
                                                  @(count)];
        while (resultSet.next) {
            TXDepartmentPhoto *txDepartmentPhoto = [[[TXDepartmentPhoto alloc] init] loadValueFromFMResultSet:resultSet];
            [txDepartmentPhotos addObject:txDepartmentPhoto];
        }
        [resultSet close];
    }];
    return txDepartmentPhotos;
}

- (void)addDepartmentPhoto:(TXDepartmentPhoto *)txDepartmentPhoto error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO department_photo"
            "(department_id,file_url,created_on,updated_on) "
            "VALUES(?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txDepartmentPhoto.departmentId),
                               txDepartmentPhoto.fileUrl,
                               @(txDepartmentPhoto.createdOn ),
                               @(TIMESTAMP_OF_NOW)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteAllDepartmentPhotosWithDepartmentId:(int64_t)departmentId {
    NSString *sql = @"DELETE FROM department_photo WHERE department_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(departmentId)];
    }];
}

@end