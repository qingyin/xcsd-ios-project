//
//  TXUserDbManager.m
//  TXChatSDK
//
//  Created by lingiqngwan on 6/7/15.
//  Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXUserDbManager.h"

typedef struct {
    int idx;
    char *sql;
} tx_sql_t;

static tx_sql_t sql_table[] = {
        {1, "CREATE TABLE setting ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "key                    TEXT UNIQUE NOT NULL,"
                "value                  TEXT NOT NULL"
                ")"
        },
        {2, "INSERT INTO setting(key,value) VALUES ('sqlMaxIdx',0)"},
        {3, "CREATE TABLE user ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "user_id                INTEGER UNIQUE NOT NULL,"
                "username               TEXT NOT NULL,"
                "token                  TEXT NOT NULL DEFAULT '',"
                "is_init                INTEGER NOT NULL,"
                "child_user_id          INTEGER NOT NULL DEFAULT 0,"
                "mobile_phone_number    TEXT NOT NULL DEFAULT '',"
                "sign                   TEXT NOT NULL DEFAULT '',"
                "user_type              INTEGER NOT NULL DEFAULT 0,"
                "avatar_url,            TEXT NOT NULL DEFAULT '',"
                "sex                    INTEGER NOT NULL DEFAULT 0,"
                "birthday               INTEGER NOT NULL DEFAULT 0,"
                "garden_id              INTEGER NOT NULL DEFAULT 0,"
                "class_id               INTEGER NOT NULL DEFAULT 0,"
                "class_name             TEXT NOT NULL DEFAULT '',"
                "garden_name            TEXT NOT NULL DEFAULT '',"
                "location               TEXT NOT NULL DEFAULT '',"
                "position_id            INTEGER NOT NULL DEFAULT 0,"
                "position_name          TEXT NOT NULL DEFAULT '',"
                "nickname               TEXT NOT NULL DEFAULT '',"
                "nickname_first_letter  TEXT NOT NULL DEFAULT '',"
                "real_name              TEXT NOT NULL DEFAULT '',"
                "parent_type            INTEGER NOT NULL DEFAULT 0,"
                "guarder                TEXT NOT NULL DEFAULT ''"
                ")"
        },
        {5, "CREATE TABLE department ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "department_id          INTEGER UNIQUE NOT NULL,"
                "name                   TEXT NOT NULL DEFAULT '',"
                "avatar_url             TEXT NOT NULL DEFAULT '',"
                "group_id               TEXT NOT NULL DEFAULT '',"
                "department_type        INTEGER NOT NULL DEFAULT 0,"
                "show_parent            INTEGER NOT NULL DEFAULT 0"
                ")"
        },
        {6, "CREATE TABLE department_user ("
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "department_id          INTEGER NOT NULL,"
                "user_id                INTEGER NOT NULL,"
                "PRIMARY KEY (department_id,user_id)"
                ")"
        },
        {7, "CREATE TABLE notice ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "notice_id              INTEGER  NOT NULL,"
                "content                TEXT NOT NULL DEFAULT '',"
                "attaches               TEXT NOT NULL DEFAULT '',"
                "from_user_id           INTEGER NOT NULL,"
                "sent_on                INTEGER NOT NULL,"
                "is_inbox               INTEGER NOT NULL,"
                "is_read                INTEGER NOT NULL DEFAULT 0,"
                "UNIQUE (notice_id,is_inbox) ON CONFLICT REPLACE"
                ")"
        },
        {8, "CREATE TABLE checkin ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "checkin_id             INTEGER UNIQUE NOT NULL,"
                "card_code              TEXT NOT NULL DEFAULT '',"
                "parent_name            TEXT,"
                "class_name             TEXT,"
                "attaches               TEXT NOT NULL DEFAULT '',"
                "user_id                INTEGER NOT NULL,"
                "username               INTEGER NOT NULL,"
                "checkin_time           INTEGER NOT NULL DEFAULT 0 ,"
                "garden_id              INTEGER NOT NULL,"
                "machine_id             INTEGER NOT NULL,"
                "client_key             INTEGER NOT NULL"
                ")"
        },
        {9, "CREATE TABLE feed ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "feed_id                INTEGER UNIQUE NOT NULL,"
                "is_inbox               INTEGER NOT NULL DEFAULT 0,"
                "content                TEXT NOT NULL DEFAULT '',"
                "attaches               TEXT NOT NULL DEFAULT '',"
                "user_id                INTEGER NOT NULL DEFAULT '',"
                "user_nick_name         TEXT NOT NULL DEFAULT '',"
                "user_avatar_url        TEXT NOT NULL DEFAULT ''"
                ")"
        },
        {10, "CREATE TABLE comment ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "comment_id             INTEGER UNIQUE NOT NULL DEFAULT 0,"
                "content                TEXT NOT NULL DEFAULT '',"
                "comment_type           INTEGER NOT NULL DEFAULT 0,"
                "target_id              INTEGER NOT NULL DEFAULT 0,"
                "target_user_id         INTEGER NOT NULL DEFAULT 0,"
                "target_type            INTEGER NOT NULL DEFAULT 0,"
                "to_user_id             INTEGER NOT NULL DEFAULT 0,"
                "to_user_nickname       TEXT NOT NULL DEFAULT '',"
                "user_id                INTEGER NOT NULL DEFAULT 0,"
                "user_nickname          TEXT NOT NULL DEFAULT '',"
                "user_avatar_url        TEXT NOT NULL DEFAULT ''"
                ")"
        },
        {11, "CREATE TABLE post ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "post_id                INTEGER UNIQUE  NOT NULL,"
                "title                  TEXT NOT NULL DEFAULT '',"
                "summary                TEXT NOT NULL DEFAULT '',"
                "content                TEXT NOT NULL DEFAULT '',"
                "cover_image_url        TEXT NOT NULL DEFAULT '',"
                "post_type              INTEGER NOT NULL DEFAULT 0,"
                "group_id               INTEGER NOT NULL DEFAULT -1,"
                "order_value            INTEGER NOT NULL DEFAULT 0"
                ")"
        },
        {12, "CREATE TABLE garden_mail ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "garden_mail_id         INTEGER UNIQUE  NOT NULL,"
                "garden_id              INTEGER NOT NULL DEFAULT 0,"
                "garden_name            TEXT NOT NULL DEFAULT '',"
                "garden_avatar_url      TEXT NOT NULL DEFAULT '',"
                "content                TEXT NOT NULL DEFAULT '',"
                "is_anonymous           INTEGER NOT NULL DEFAULT 0,"
                "from_user_id           INTEGER NOT NULL DEFAULT 0,"
                "from_user_name         TEXT NOT NULL DEFAULT '',"
                "from_user_avatar_url   TEXT NOT NULL DEFAULT '',"
                "is_read                INTEGER NOT NULL DEFAULT 0"
                ")"
        },
        {13, "CREATE TABLE feed_medicine_task ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "feed_medicine_task_id  INTEGER UNIQUE  NOT NULL,"
                "content                TEXT NOT NULL DEFAULT '',"
                "attaches               TEXT NOT NULL DEFAULT '',"
                "parent_user_id         INTEGER NOT NULL DEFAULT 0,"
                "parent_user_name       TEXT NOT NULL DEFAULT '',"
                "parent_user_avatar_url TEXT NOT NULL DEFAULT '',"
                "class_id               INTEGER NOT NULL DEFAULT 0,"
                "class_name             TEXT NOT NULL DEFAULT '',"
                "class_avatar_url       TEXT NOT NULL DEFAULT '',"
                "begin_date             INTEGER NOT NULL DEFAULT 0,"
                "is_read                INTEGER NOT NULL DEFAULT 0"
                ")"
        },
        {14, "ALTER TABLE notice ADD COLUMN sender_avatar TEXT NOT NULL DEFAULT ''"},
        {15, "ALTER TABLE notice ADD COLUMN sender_name TEXT NOT NULL DEFAULT ''"},
        {16, "ALTER TABLE post ADD COLUMN post_url TEXT NOT NULL DEFAULT ''"},
        {17, "ALTER TABLE user ADD COLUMN activated INTEGER NOT NULL DEFAULT ''"},
        {18, "CREATE TABLE deleted_message ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "msg_id                 TEXT UNIQUE NOT NULL DEFAULT '',"
                "cmd_msg_id             TEXT NOT NULL DEFAULT '',"
                "from_user_id           TEXT NOT NULL DEFAULT '',"
                "to_user_id             TEXT NOT NULL DEFAULT '',"
                "is_group               INTEGER NOT NULL DEFAULT 0"
                ")"
        },
        {19, "ALTER TABLE feed ADD COLUMN user_type INTEGER NOT NULL DEFAULT 0"},
        {20, "CREATE TABLE department_photo ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "department_photo_id    INTEGER UNIQUE NOT NULL DEFAULT 0,"
                "department_id          INTEGER NOT NULL DEFAULT 0,"
                "file_url               TEXT NOT NULL DEFAULT ''"
                ")"
        },
        {21, "CREATE TABLE qr_check_in_item ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "target_user_id         INTEGER NOT NULL DEFAULT 0,"
                "target_user_name       TEXT,"
                "target_user_type       TEXT,"
                "target_card_number     TEXT,"
                "status                 INTEGER NOT NULL DEFAULT 1"
                ")"
        },
        {22, "ALTER TABLE feed ADD COLUMN feed_type NOT NULL DEFAULT 0"},
        {23, "ALTER TABLE post ADD COLUMN garden_id NOT NULL DEFAULT 0"},
        /*
        {23, "CREATE TABLE track_played ("
                "id                     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "updated_on             INTEGER NOT NULL,"
                "created_on             INTEGER NOT NULL,"
                "track_id               INTEGER NOT NULL DEFAULT 0"
                ")"
        }
         */
        {24, "CREATE TABLE test ("
            "id                    INT PRIMARY KEY,"
            "testId                TEXT NOT NULL,"
            "testDescription       TEXT NOT NULL,"
            "name                  TEXT NOT NULL,"
            "associateTag          TEXT NOT NULL,"
            "animalPic             TEXT NOT NULL,"
            "colorValue            TEXT NOT NULL,"
            "status                INTEGER NOT NULL"
            ");"
        },
        {34, "CREATE TABLE course ("
            "id                   INT PRIMARY KEY,"
            "courseId             INT NOT NULL,"
            "createOn             INTEGER NOT NULL,"
            "updateOn             INTEGER NOT NULL,"
            "title                TEXT NOT NULL DEFAULT(''),"
            "videoUrl             TEXT NOT NULL,"
            "pic                  TEXT NOT NULL,"
            "duration             INTEGER NOT NULL,"
            "resourceType         INTEGER NOT NULL,"
            "teacherName          TEXT NOT NULL,"
            "teacherAvatar        TEXT NOT NULL"
            ");"
		},
		{35, "CREATE TABLE tblDataReport ("
			"id                   INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
			"userId               INT NOT NULL,"
			"eventType            INTEGER NOT NULL,"
			"bid				  TEXT,"
			"timestamp            INT NOT NULL,"
			"extendedInfo         TEXT,"
			"sendedState          INTEGER NOT NULL DEFAULT 0,"
			"serialNo             INT NOT NULL DEFAULT 0"
			");"
		}
};


#define TX_SETTING_KEY_SQL_MAX_IDX  @"sqlMaxIdx"

@implementation TXUserDbManager {
    FMDatabaseQueue *_databaseQueue;
}

- (void)registerDaoWithDatabaseQueue:(FMDatabaseQueue *)databaseQueue {
    _checkInDao = [[TXCheckInDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _commentDao = [[TXCommentDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _deletedMessageDao = [[TXDeletedMessageDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _departmentDao = [[TXDepartmentDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _feedDao = [[TXFeedDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _feedMedicineTaskDao = [[TXFeedMedicineTaskDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _gardenMailDao = [[TXGardenMailDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _noticeDao = [[TXNoticeDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _postDao = [[TXPostDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _settingDao = [[TXSettingDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _userDao = [[TXUserDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _departmentPhotoDao = [[TXDepartmentPhotoDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _qrCheckInItemDao = [[TXQrCheckInItemDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _testDao = [[XCSDTestDao alloc] initWithFMDatabaseQueue:_databaseQueue];
    _courseDao = [[XCSDCourseDao alloc] initWithFMDatabaseQueue:_databaseQueue];
	_dataReportDao = [[XCSDDataReportDao alloc] initWithFMDatabaseQueue:_databaseQueue];
}

- (instancetype)initWithUsername:(NSString *)username error:(NSError **)outError {
    NSString * documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, TRUE)[0];
    NSString * dbFileName = [NSString stringWithFormat:@"%@.sqlite", username];
    NSString * dbFilePath = [documentsPath stringByAppendingPathComponent:dbFileName];

    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
    NSLog(@"%@", dbFilePath);

    [self registerDaoWithDatabaseQueue:_databaseQueue];

    NSError * error;
    [self initDatabase:&error];
    if (error) {
        *outError = TX_ERROR_MAKE(TX_STATUS_DB_INIT_FAILED, @"数据异常，请重新登录");
        return nil;
    }

    return self;
}

- (void)initDatabase:(NSError **)outError {
    __block BOOL settingTableCreated = NO;
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        settingTableCreated = [db tableExists:@"setting"];
    }];

    int sqlMaxIdx = 0;
    if (settingTableCreated) {
        NSString * sqlMaxIdxStr = [_settingDao querySettingValueByKey:TX_SETTING_KEY_SQL_MAX_IDX];
        sqlMaxIdx = sqlMaxIdxStr ? sqlMaxIdxStr.intValue : 0;
    }

    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i = 0; i < sizeof(sql_table) / sizeof(tx_sql_t); i++) {
            if (sql_table[i].idx > sqlMaxIdx) {
                if (![db executeUpdate:@(sql_table[i].sql) withErrorAndBindings:outError]) {
                    FILL_OUT_ERROR_IF_NULL(@(sql_table[i].sql));
                    *rollback = TRUE;
                    break;
                }

                NSString * sql = @"UPDATE setting SET value=? WHERE key='sqlMaxIdx'";
                if (![db executeUpdate:sql withErrorAndBindings:outError, @(sql_table[i].idx)]) {
                    FILL_OUT_ERROR_IF_NULL(sql);
                    *rollback = TRUE;
                    break;
                }
            }
        }
    }];
}


@end
