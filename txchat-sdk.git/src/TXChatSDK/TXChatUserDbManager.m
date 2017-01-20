//
//  TXChatUserDbManager.m
//  TXChatSDK
//
//  Created by lingiqngwan on 6/7/15.
//  Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXChatUserDbManager.h"
#import "TXChatDef.h"

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
};


#define FILL_OUT_ERROR_IF_NULL(errorMessage)                                                    \
    if (outError && !*outError) {                                                               \
        *outError = TX_ERROR_MAKE(TX_CLIENT_STATUS_UN_KNOW_ERROR, errorMessage );               \
    }

#define SET_BASE_PROPERTIES_FROM_RESULT_SET(object)                                             \
    object.id = [resultSet longLongIntForColumn:@"id"];                                         \
    object.updatedOn = [resultSet longLongIntForColumn:@"updated_on"];                          \
    object.createdOn = [resultSet longLongIntForColumn:@"created_on"];                          \

#define TX_SETTING_KEY_SQL_MAX_IDX  @"sqlMaxIdx"

@implementation TXChatUserDbManager {
    FMDatabaseQueue *_databaseQueue;
}

- (void)setTXDeletedMessageProperties:(TXDeletedMessage *)txDeletedMessage fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txDeletedMessage);
    txDeletedMessage.msgId = [resultSet stringForColumn:@"msg_id"];
    txDeletedMessage.cmdMsgId = [resultSet stringForColumn:@"cmd_msg_id"];
    txDeletedMessage.fromUserId = [resultSet stringForColumn:@"from_user_id"];
    txDeletedMessage.toUserId = [resultSet stringForColumn:@"to_user_id"];
    txDeletedMessage.isGroup = [resultSet boolForColumn:@"is_group"];
}

- (void)setTXFeedMedicineTaskProperties:(TXFeedMedicineTask *)txFeedMedicineTask fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txFeedMedicineTask);
    txFeedMedicineTask.feedMedicineTaskId = [resultSet longLongIntForColumn:@"feed_medicine_task_id"];
    txFeedMedicineTask.content = [resultSet stringForColumn:@"content"];
    NSString *attaches = [resultSet stringForColumn:@"attaches"];
    txFeedMedicineTask.attaches = attaches.length == 0 ? [NSMutableArray array] : [[attaches componentsSeparatedByString:@","] mutableCopy];
    txFeedMedicineTask.parentUserId = [resultSet longLongIntForColumn:@"parent_user_id"];
    txFeedMedicineTask.parentUsername = [resultSet stringForColumn:@"parent_user_name"];
    txFeedMedicineTask.parentAvatarUrl = [resultSet stringForColumn:@"parent_user_avatar_url"];
    txFeedMedicineTask.classId = [resultSet longLongIntForColumn:@"class_id"];
    txFeedMedicineTask.className = [resultSet stringForColumn:@"class_name"];
    txFeedMedicineTask.classAvatarUrl = [resultSet stringForColumn:@"class_avatar_url"];
    txFeedMedicineTask.beginDate = [resultSet intForColumn:@"begin_date"];
    txFeedMedicineTask.isRead = [resultSet boolForColumn:@"is_read"];
}

- (void)setTXGardenMailProperties:(TXGardenMail *)txGardenMail fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txGardenMail);
    txGardenMail.gardenMailId = [resultSet longLongIntForColumn:@"garden_mail_id"];
    txGardenMail.gardenId = [resultSet longLongIntForColumn:@"garden_id"];
    txGardenMail.gardenName = [resultSet stringForColumn:@"garden_name"];
    txGardenMail.gardenAvatarUrl = [resultSet stringForColumn:@"garden_avatar_url"];
    txGardenMail.isAnonymous = [resultSet boolForColumn:@"is_anonymous"];
    txGardenMail.fromUserId = (TXPBPostType) [resultSet intForColumn:@"from_user_id"];
    txGardenMail.fromUsername = [resultSet stringForColumn:@"from_user_name"];
    txGardenMail.fromUserAvatarUrl = [resultSet stringForColumn:@"from_user_avatar_url"];
    txGardenMail.isRead = [resultSet boolForColumn:@"is_read"];
    txGardenMail.content = [resultSet stringForColumn:@"content"];
}

- (void)setTXPostProperties:(TXPost *)txPost fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txPost);
    txPost.postId = [resultSet longLongIntForColumn:@"post_id"];
    txPost.title = [resultSet stringForColumn:@"title"];
    txPost.summary = [resultSet stringForColumn:@"summary"];
    txPost.content = [resultSet stringForColumn:@"content"];
    txPost.coverImageUrl = [resultSet stringForColumn:@"cover_image_url"];
    txPost.postType = (TXPBPostType) [resultSet intForColumn:@"post_type"];
    txPost.groupId = [resultSet longLongIntForColumn:@"group_id"];
    txPost.orderValue = [resultSet longLongIntForColumn:@"order_value"];
    txPost.postUrl = [resultSet stringForColumn:@"post_url"];
}

- (void)setTXUserProperties:(TXUser *)txUser fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txUser);
    txUser.userId = [resultSet longLongIntForColumn:@"user_id"];
    txUser.username = [resultSet stringForColumn:@"username"];
    txUser.avatarUrl = [resultSet stringForColumn:@"avatar_url"];
    txUser.mobilePhoneNumber = [resultSet stringForColumn:@"mobile_phone_number"];
    txUser.sign = [resultSet stringForColumn:@"sign"];
    txUser.userType = (TXPBUserType) [resultSet longForColumn:@"user_type"];
    txUser.childUserId = [resultSet longLongIntForColumn:@"child_user_id"];
    txUser.sex = (TXPBSexType) [resultSet longForColumn:@"sex"];
    txUser.birthday = [resultSet longLongIntForColumn:@"birthday"];
    txUser.className = [resultSet stringForColumn:@"class_name"];
    txUser.gardenName = [resultSet stringForColumn:@"garden_name"];
    txUser.classId = [resultSet longLongIntForColumn:@"class_id"];
    txUser.gardenId = [resultSet longLongIntForColumn:@"garden_id"];
    txUser.location = [resultSet stringForColumn:@"location"];
    txUser.positionName = [resultSet stringForColumn:@"position_name"];
    txUser.nickname = [resultSet stringForColumn:@"nickname"];
    txUser.nicknameFirstLetter = [resultSet stringForColumn:@"nickname_first_letter"];
    txUser.realName = [resultSet stringForColumn:@"real_name"];
    txUser.parentType = (TXPBParentType) [resultSet longForColumn:@"parent_type"];
    txUser.positionId = [resultSet longLongIntForColumn:@"position_id"];
    txUser.guarder = [resultSet stringForColumn:@"guarder"];
    txUser.activated = [resultSet boolForColumn:@"activated"];
}

- (void)setTXDepartmentProperties:(TXDepartment *)txDepartment fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txDepartment);
    txDepartment.name = [resultSet stringForColumn:@"name"];
    txDepartment.avatarUrl = [resultSet stringForColumn:@"avatar_url"];
    txDepartment.departmentId = [resultSet longForColumn:@"department_id"];
    txDepartment.groupId = [resultSet stringForColumn:@"group_id"];
    txDepartment.showParent = [resultSet boolForColumn:@"show_parent"];
    txDepartment.departmentType = (TXPBDepartmentType) [resultSet intForColumn:@"department_type"];
}

- (void)setTXNoticeProperties:(TXNotice *)txNotice fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txNotice);
    txNotice.sentOn = [resultSet longLongIntForColumn:@"sent_on"];
    txNotice.content = [resultSet stringForColumn:@"content"];
    txNotice.fromUserId = [resultSet longLongIntForColumn:@"from_user_id"];
    txNotice.noticeId = [resultSet longLongIntForColumn:@"notice_id"];
    txNotice.isInbox = [resultSet boolForColumn:@"is_inbox"];
    NSString *attaches = [resultSet stringForColumn:@"attaches"];
    txNotice.attaches = attaches.length == 0 ? [NSMutableArray array] : [[attaches componentsSeparatedByString:@","] mutableCopy];
    txNotice.isRead = [resultSet boolForColumn:@"is_read"];
    txNotice.senderAvatar = [resultSet stringForColumn:@"sender_avatar"];
    txNotice.senderName = [resultSet stringForColumn:@"sender_name"];
}

- (void)setTXCheckInProperties:(TXCheckIn *)txCheckIn fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txCheckIn);
    txCheckIn.clientKey = [resultSet longLongIntForColumn:@"client_key"];
    txCheckIn.userId = [resultSet longLongIntForColumn:@"user_id"];
    txCheckIn.username = [resultSet stringForColumn:@"username"];
    txCheckIn.gardenId = [resultSet longLongIntForColumn:@"garden_id"];
    txCheckIn.machineId = [resultSet longLongIntForColumn:@"machine_id"];
    txCheckIn.checkInId = [resultSet longLongIntForColumn:@"checkin_id"];
    txCheckIn.checkInTime = [resultSet longLongIntForColumn:@"checkin_time"];
    txCheckIn.className = [resultSet stringForColumn:@"class_name"];
    txCheckIn.parentName = [resultSet stringForColumn:@"parent_name"];
    txCheckIn.cardCode = [resultSet stringForColumn:@"card_code"];
    NSString *attaches = [resultSet stringForColumn:@"attaches"];
    txCheckIn.attaches = attaches.length == 0 ? [NSMutableArray array] : [[attaches componentsSeparatedByString:@","] mutableCopy];
}

- (void)setTXFeedProperties:(TXFeed *)txFeed fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txFeed);
    txFeed.userAvatarUrl = [resultSet stringForColumn:@"user_avatar_url"];
    txFeed.userNickName = [resultSet stringForColumn:@"user_nick_name"];
    txFeed.userId = [resultSet longLongIntForColumn:@"user_id"];
    txFeed.feedId = [resultSet longLongIntForColumn:@"feed_id"];
    txFeed.content = [resultSet stringForColumn:@"content"];
    txFeed.isInbox = [resultSet boolForColumn:@"is_inbox"];
    NSString *attaches = [resultSet stringForColumn:@"attaches"];
    txFeed.attaches = attaches.length == 0 ? [NSMutableArray array] : [[attaches componentsSeparatedByString:@","] mutableCopy];
    txFeed.userType = (TXPBUserType) [resultSet longLongIntForColumn:@"user_type"];
}

- (void)setTXCommentProperties:(TXComment *)txComment fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txComment);
    txComment.commentId = [resultSet longLongIntForColumn:@"comment_id"];
    txComment.targetId = [resultSet longLongIntForColumn:@"target_id"];
    txComment.content = [resultSet stringForColumn:@"content"];
    txComment.targetUserId = [resultSet longLongIntForColumn:@"target_user_id"];
    txComment.targetType = (TXPBTargetType) [resultSet longLongIntForColumn:@"target_type"];
    txComment.commentType = (TXPBCommentType) [resultSet longLongIntForColumn:@"comment_type"];
    txComment.toUserId = [resultSet longLongIntForColumn:@"to_user_id"];
    txComment.toUserNickname = [resultSet stringForColumn:@"to_user_nickname"];
    txComment.userId = [resultSet longLongIntForColumn:@"user_id"];
    txComment.userNickname = [resultSet stringForColumn:@"user_nickname"];
    txComment.userAvatarUrl = [resultSet stringForColumn:@"user_avatar_url"];
}

- (instancetype)initWithUsername:(NSString *)username error:(NSError **)outError {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, TRUE)[0];
    NSString *dbFileName = [NSString stringWithFormat:@"%@.sqlite", username];
    NSString *dbFilePath = [documentsPath stringByAppendingPathComponent:dbFileName];

    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
    NSLog(@"%@", dbFilePath);

    NSError *error;
    [self initDatabase:&error];
    if (error) {
        *outError = TX_ERROR_MAKE(TX_CLIENT_STATUS_DB_INIT_FAILED, @"数据异常，请重新登录");
        return nil;
    }

    _txChatCheckInDao = [[TXChatCheckInDao alloc] initWithFMDatabaseQueue:_databaseQueue];

    return self;
}

- (void)initDatabase:(NSError **)outError {
    __block BOOL settingTableCreated = NO;
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        settingTableCreated = [db tableExists:@"setting"];
    }];

    int sqlMaxIdx = 0;
    if (settingTableCreated) {
        NSString *sqlMaxIdxStr = [self getSettingValueByKey:TX_SETTING_KEY_SQL_MAX_IDX];
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

                NSString *sql = @"UPDATE setting SET value=? WHERE key='sqlMaxIdx'";
                if (![db executeUpdate:sql withErrorAndBindings:outError, @(sql_table[i].idx)]) {
                    FILL_OUT_ERROR_IF_NULL(sql);
                    *rollback = TRUE;
                    break;
                }
            }
        }
    }];
}

- (void)saveSettingValue:(NSString *)value forKey:(NSString *)key error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO setting(key,value) VALUES(?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, key, value]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (NSString *)getSettingValueByKey:(NSString *)key {
    __block NSString *value = nil;
    NSString *sql = @"SELECT * FROM setting WHERE key=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, key];
        if (resultSet.next) {
            value = [resultSet stringForColumn:@"value"];
        }
        [resultSet close];
    }];
    return value;
}

#pragma mark Users

- (TXUser *)getUserByUserId:(int64_t)userId error:(NSError **)outError {
    __block TXUser *txUser = nil;
    NSString *sql = @"SELECT * FROM user WHERE user_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(userId)];
        if (resultSet.next) {
            txUser = [[TXUser alloc] init];
            [self setTXUserProperties:txUser fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txUser;
}

- (TXUser *)getUserByUsername:(NSString *)username error:(NSError **)outError {
    __block TXUser *txUser = nil;
    NSString *sql = @"SELECT * FROM user WHERE username=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, username];
        if (resultSet.next) {
            txUser = [[TXUser alloc] init];
            [self setTXUserProperties:txUser fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txUser;
}

- (NSArray *)getPosts:(TXPBPostType)postType maxPostId:(int64_t)maxPostId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *posts = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM post WHERE post_type=? AND post_id<? ORDER BY created_on DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql,
                                                  @(postType),
                                                  @(maxPostId),
                                                  @(count)];
        while (resultSet.next) {
            TXPost *txPost = [[TXPost alloc] init];
            [self setTXPostProperties:txPost fromResultSet:resultSet];
            [posts addObject:txPost];
        }
        [resultSet close];
    }];
    return posts;
}

- (int64_t)getLastGroupId:(TXPBPostType)postType error:(NSError **)outError {
    __block int64_t groupId;
    NSString *sql = @"SELECT * FROM post WHERE post_type=? ORDER BY group_id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(postType)];
        if (resultSet.next) {
            groupId = [resultSet longLongIntForColumn:@"group_id"];
        }
        [resultSet close];
    }];
    return groupId;
}

- (TXPost *)getLastPostOfGroup:(TXPBPostType)postType groupId:(int64_t)groupId error:(NSError **)outError {
    __block TXPost *txPost;
    NSString *sql = @"SELECT * FROM post WHERE post_type=? AND group_id=? ORDER BY order_value ASC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(postType), @(groupId)];
        if (resultSet.next) {
            txPost = [[TXPost alloc] init];
            [self setTXPostProperties:txPost fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txPost;
}

- (void)addGardenMail:(TXGardenMail *)txGardenMail error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO garden_mail(updated_on,created_on,garden_mail_id,garden_id,garden_name,garden_avatar_url,content,is_anonymous,from_user_id,from_user_name,from_user_avatar_url,is_read) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txGardenMail.updatedOn),
                               @(txGardenMail.createdOn),
                               @(txGardenMail.gardenMailId),
                               @(txGardenMail.gardenMailId),
                               txGardenMail.gardenName,
                               txGardenMail.gardenAvatarUrl,
                               txGardenMail.content,
                               @(txGardenMail.isAnonymous),
                               @(txGardenMail.fromUserId),
                               txGardenMail.fromUsername,
                               txGardenMail.fromUserAvatarUrl,
                               @(txGardenMail.isRead)
        ]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)addFeedMedicineTask:(TXFeedMedicineTask *)txFeedMedicineTask error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO feed_medicine_task"
            "(updated_on,created_on,feed_medicine_task_id,content,attaches,"
            "parent_user_id,parent_user_name,parent_user_avatar_url,"
            "class_id,class_name,class_avatar_url,begin_date,is_read) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";

    NSString *attachesValue = @"";
    for (uint i = 0; i < txFeedMedicineTask.attaches.count; ++i) {
        BOOL isLast = i == txFeedMedicineTask.attaches.count - 1;
        attachesValue = isLast
                ? [attachesValue stringByAppendingFormat:@"%@", txFeedMedicineTask.attaches[i]]
                : [attachesValue stringByAppendingFormat:@"%@,", txFeedMedicineTask.attaches[i]];
    }

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txFeedMedicineTask.updatedOn),
                               @(txFeedMedicineTask.createdOn),
                               @(txFeedMedicineTask.feedMedicineTaskId),
                               txFeedMedicineTask.content,
                               attachesValue,
                               @(txFeedMedicineTask.parentUserId),
                               txFeedMedicineTask.parentUsername,
                               txFeedMedicineTask.parentAvatarUrl,
                               @(txFeedMedicineTask.classId),
                               txFeedMedicineTask.className,
                               txFeedMedicineTask.classAvatarUrl,
                               @(txFeedMedicineTask.beginDate),
                               @(txFeedMedicineTask.isRead)
        ]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteAllNotice {
    NSString *sql = @"DELETE FROM notice";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)deleteAllNotice:(BOOL)isInbox {
    NSString *sql = @"DELETE FROM notice WHERE is_inbox=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(isInbox)];
    }];
}


- (void)deleteAllCheckIn {
    NSString *sql = @"DELETE FROM checkin";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)deleteAllFeed {
    NSString *sql = @"DELETE FROM feed";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)deleteAllFeedByUserId:(int64_t)userId {
    NSString *sql = @"DELETE FROM feed WHERE user_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(userId)];
    }];
}


- (void)deleteAllPostByType:(TXPBPostType)txpbPostType {
    NSString *sql = @"DELETE FROM post where post_type=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(txpbPostType)];
    }];
}

- (void)deleteAllGardenMail {
    NSString *sql = @"DELETE FROM garden_mail";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)deleteAllFeedMedicineTask {
    NSString *sql = @"DELETE FROM feed_medicine_task";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (NSArray *)getAllDeletedMessage {
    __block NSMutableArray *deletedMessages = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM deleted_message";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            TXDeletedMessage *txDeletedMessage = [[TXDeletedMessage alloc] init];
            [self setTXDeletedMessageProperties:txDeletedMessage fromResultSet:resultSet];
            [deletedMessages addObject:txDeletedMessage];
        }
        [resultSet close];
    }];
    return deletedMessages;
}

- (void)addDeletedMessage:(TXDeletedMessage *)txDeletedMessage error:(NSError **)outError {
    NSString *sql = @"INSERT INTO deleted_message(msg_id,cmd_msg_id,from,to,is_group,created_on,updated_on) VALUES(?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               txDeletedMessage.msgId,
                               txDeletedMessage.cmdMsgId,
                               txDeletedMessage.fromUserId,
                               txDeletedMessage.toUserId,
                               @(txDeletedMessage.isGroup),
                               @(TIMESTAMP_OF_NOW),
                               @(TIMESTAMP_OF_NOW)
        ]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteDeletedMessageByMsgId:(NSString *)msgId {
    NSString *sql = @"DELETE FROM deleted_message WHERE msg_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, msgId];
    }];
}


- (TXPost *)getLastPost:(TXPBPostType)postType error:(NSError **)outError {
    __block TXPost *txPost;
    NSString *sql = @"SELECT * FROM post WHERE post_type=? ORDER BY id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(postType)];
        if (resultSet.next) {
            txPost = [[TXPost alloc] init];
            [self setTXPostProperties:txPost fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txPost;
}

- (void)addPost:(TXPost *)txPost error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO post(updated_on,created_on,post_id,title,summary,content,cover_image_url,post_type,group_id,order_value,post_url) VALUES(?,?,?,?,?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txPost.updatedOn),
                               @(txPost.createdOn),
                               @(txPost.postId),
                               txPost.title,
                               txPost.summary,
                               txPost.content,
                               txPost.coverImageUrl,
                               @(txPost.postType),
                               @(txPost.groupId),
                               @(txPost.orderValue),
                               txPost.postUrl
        ]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)addUser:(TXUser *)txUser error:(NSError **)outError {
    NSString *sql = @
            "REPLACE INTO user(updated_on,created_on,class_id,garden_id,user_id,username,is_init,child_user_id,"
            "mobile_phone_number,sign,user_type,avatar_url,birthday,class_name,garden_name,location,position_name,"
            "nickname,nickname_first_letter,real_name,parent_type,sex,position_id,guarder,activated) "
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(TIMESTAMP_OF_NOW),
                               @(txUser.createdOn),
                               @(txUser.classId),
                               @(txUser.gardenId),
                               @(txUser.userId),
                               txUser.username,
                               @(txUser.isInit),
                               @(txUser.childUserId),
                               txUser.mobilePhoneNumber,
                               txUser.sign != nil ? txUser.sign : @"",
                               @(txUser.userType),
                               txUser.avatarUrl,
                               @(txUser.birthday),
                               txUser.className != nil ? txUser.className : @"",
                               txUser.gardenName != nil ? txUser.gardenName : @"",
                               txUser.location != nil ? txUser.location : @"",
                               txUser.positionName,
                               txUser.nickname != nil ? txUser.nickname : @"",
                               txUser.nicknameFirstLetter != nil ? txUser.nicknameFirstLetter : @"",
                               txUser.realName != nil ? txUser.realName : @"",
                               @(txUser.parentType),
                               @(txUser.sex),
                               @(txUser.positionId),
                               txUser.guarder,
                               @(txUser.activated)

        ]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteUserById:(int64_t)id error:(NSError **)outError {
    NSString *sql = @"DELETE FROM user WHERE id=?";
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(id)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteUserByUserId:(int64_t)userId error:(NSError **)outError {
    NSString *sql = @"DELETE FROM user WHERE user_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(userId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (TXDepartment *)getDepartmentByGroupId:(NSString *)groupId error:(NSError **)outError {
    __block TXDepartment *txDepartment;
    NSString *sql = @"SELECT * FROM department WHERE group_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, groupId];
        if (resultSet.next) {
            txDepartment = [[TXDepartment alloc] init];
            [self setTXDepartmentProperties:txDepartment fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txDepartment;
}

- (TXDepartment *)getDepartmentByDepartmentId:(int64_t)departmentId error:(NSError **)outError {
    __block TXDepartment *txDepartment;
    NSString *sql = @"SELECT * FROM department WHERE department_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(departmentId)];
        if (resultSet.next) {
            txDepartment = [[TXDepartment alloc] init];
            [self setTXDepartmentProperties:txDepartment fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txDepartment;
}

- (NSArray *)getAllDepartment:(NSError **)outError {
    __block NSMutableArray *departments = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM department";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            TXDepartment *txDepartment = [[TXDepartment alloc] init];
            [self setTXDepartmentProperties:txDepartment fromResultSet:resultSet];
            [departments addObject:txDepartment];
        }
    }];
    return departments;
}

- (void)addDepartment:(TXDepartment *)department error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO department(department_id,name,avatar_url,group_id,department_type,show_parent,created_on,updated_on) VALUES (?,?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(department.departmentId),
                               department.name,
                               department.avatarUrl,
                               department.groupId,
                               @(department.departmentType),
                               @(department.showParent),
                               @(TIMESTAMP_OF_NOW),
                               @(TIMESTAMP_OF_NOW)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteDepartmentByDepartmentId:(int64_t)departmentId error:(NSError **)outError {
    NSString *sql = @"DELETE FROM department WHERE department_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(departmentId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteDepartmentMembersByDepartmentId:(int64_t)departmentId error:(NSError **)outError {
    NSString *sql = @"DELETE FROM department_user WHERE department_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(departmentId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}


- (NSArray *)getUsersByDepartmentId:(int64_t)departmentId userType:(TXPBUserType)userType error:(NSError **)outError {
    __block NSMutableArray *txUsers = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM user LEFT JOIN department_user on user.user_id=department_user.user_id WHERE department_user.department_id=?  ";
    if (userType > 0) {
        sql = [sql stringByAppendingString:@" and user_type=?"];
    }

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(departmentId), @(userType)];
        while (resultSet.next) {
            TXUser *txUser = [[TXUser alloc] init];
            [self setTXUserProperties:txUser fromResultSet:resultSet];
            [txUsers addObject:txUser];
        }
        [resultSet close];
    }];
    return txUsers;
}

- (void)putUsers:(NSArray *)userIds toDepartment:(int64_t)departmentId error:(NSError **)outError {
    NSString *sqlInsert = @"REPLACE INTO department_user(department_id,user_id,updated_on,created_on) VALUES (?,?,?,?)";

    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (uint i = 0; i < userIds.count; ++i) {
            if (![db executeUpdate:sqlInsert
              withErrorAndBindings:outError,
                                   @(departmentId),
                                   userIds[i],
                                   @(TIMESTAMP_OF_NOW),
                                   @(TIMESTAMP_OF_NOW)]) {
                FILL_OUT_ERROR_IF_NULL(sqlInsert);
                *rollback = TRUE;
                break;
            }
        }
    }];
}

- (NSArray *)getParentUsersByChildUserId:(int64_t)childUserId error:(NSError **)outError {
    __block NSMutableArray *txUsers = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM user where child_user_id=? ";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(childUserId)];
        while (resultSet.next) {
            TXUser *txUser = [[TXUser alloc] init];
            [self setTXUserProperties:txUser fromResultSet:resultSet];
            [txUsers addObject:txUser];
        }
        [resultSet close];
    }];
    return txUsers;
}

- (void)markNoticeAsRead:(int64_t)noticeId error:(NSError **)outError {
    NSString *sql = @"UPDATE notice SET is_read=1 WHERE notice_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(noticeId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)markGardenMailAsRead:(int64_t)gardenMailId error:(NSError **)outError {
    NSString *sql = @"UPDATE garden_mail SET is_read=1 WHERE garden_mail_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(gardenMailId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)markFeedMedicineTaskAsRead:(int64_t)feedMedicineTaskId error:(NSError **)outError {
    NSString *sql = @"UPDATE feed_medicine_task SET is_read=1 WHERE feed_medicine_task_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(feedMedicineTaskId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)addNotice:(TXNotice *)txNotice error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO notice(notice_id,content,attaches,from_user_id,sender_avatar,sender_name, sent_on,is_inbox,is_read,updated_on,created_on) VALUES(?,?,?,?,?,?,?,?,?,?,?)";

    NSString *attachesValue = @"";
    for (int i = 0; i < txNotice.attaches.count; ++i) {
        BOOL isLast = i == txNotice.attaches.count - 1;
        attachesValue = isLast
                ? [attachesValue stringByAppendingFormat:@"%@", txNotice.attaches[i]]
                : [attachesValue stringByAppendingFormat:@"%@,", txNotice.attaches[i]];
    }

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txNotice.noticeId),
                               txNotice.content,
                               attachesValue,
                               @(txNotice.fromUserId),
                               txNotice.senderAvatar,
                               txNotice.senderName,
                               @(txNotice.sentOn),
                               @(txNotice.isInbox),
                               @(txNotice.isRead),
                               @(TIMESTAMP_OF_NOW),
                               @(txNotice.createdOn )]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (NSArray *)getGardenMails:(int64_t)maxId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *mails = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM garden_mail WHERE garden_mail_id<? ORDER BY updated_on DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxId), @(count)];
        while (resultSet.next) {
            TXGardenMail *txGardenMail = [[TXGardenMail alloc] init];
            [self setTXGardenMailProperties:txGardenMail fromResultSet:resultSet];
            [mails addObject:txGardenMail];
        }
        [resultSet close];
    }];
    return mails;
}

- (NSArray *)getFeedMedicineTasks:(int64_t)maxId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *tasks = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM feed_medicine_task WHERE feed_medicine_task_id<? ORDER BY updated_on DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxId), @(count)];
        while (resultSet.next) {
            TXFeedMedicineTask *txFeedMedicineTask = [[TXFeedMedicineTask alloc] init];
            [self setTXFeedMedicineTaskProperties:txFeedMedicineTask fromResultSet:resultSet];
            [tasks addObject:txFeedMedicineTask];
        }
        [resultSet close];
    }];
    return tasks;
}

- (NSArray *)getNotices:(int64_t)maxNoticeId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *notices = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM notice WHERE notice_id<? ORDER BY notice_id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxNoticeId), @(count)];
        while (resultSet.next) {
            TXNotice *txNotice = [[TXNotice alloc] init];
            [self setTXNoticeProperties:txNotice fromResultSet:resultSet];
            [notices addObject:txNotice];
        }
        [resultSet close];
    }];
    return notices;
}

- (NSArray *)getNotices:(int64_t)maxNoticeId count:(int64_t)count isInbox:(BOOL)isInbox error:(NSError **)outError {
    __block NSMutableArray *notices = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM notice WHERE notice_id<? AND is_inbox=? ORDER BY notice_id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxNoticeId), @(isInbox), @(count)];
        while (resultSet.next) {
            TXNotice *txNotice = [[TXNotice alloc] init];
            [self setTXNoticeProperties:txNotice fromResultSet:resultSet];
            [notices addObject:txNotice];
        }
        [resultSet close];
    }];
    return notices;
}


- (TXNotice *)getNoticeById:(int64_t)id error:(NSError **)outError {
    __block TXNotice *txNotice;
    NSString *sql = @"SELECT * FROM notice WHERE id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(id)];
        if (resultSet.next) {
            txNotice = [[TXNotice alloc] init];
            [self setTXNoticeProperties:txNotice fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txNotice;
}

- (TXNotice *)getNoticeByNoticeId:(int64_t)noticeId error:(NSError **)outError {
    __block TXNotice *txNotice;
    NSString *sql = @"SELECT * FROM notice WHERE notice_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(noticeId)];
        if (resultSet.next) {
            txNotice = [[TXNotice alloc] init];
            [self setTXNoticeProperties:txNotice fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txNotice;
}

- (TXNotice *)getLastInboxNotice {
    __block TXNotice *txNotice;
    NSString *sql = @"SELECT * FROM notice WHERE is_inbox=1 ORDER BY notice_id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if (resultSet.next) {
            txNotice = [[TXNotice alloc] init];
            [self setTXNoticeProperties:txNotice fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txNotice;
}

- (TXNotice *)getLastNotice {
    __block TXNotice *txNotice;
    NSString *sql = @"SELECT * FROM notice ORDER BY notice_id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if (resultSet.next) {
            txNotice = [[TXNotice alloc] init];
            [self setTXNoticeProperties:txNotice fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txNotice;
}

#pragma mark 刷卡

- (NSArray *)getCheckIns:(int64_t)maxCheckInId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *checkIns = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM checkin WHERE checkin_id<? ORDER BY checkin_id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxCheckInId), @(count)];
        while (resultSet.next) {
            TXCheckIn *txCheckIn = [[TXCheckIn alloc] init];
            [self setTXCheckInProperties:txCheckIn fromResultSet:resultSet];
            [checkIns addObject:txCheckIn];
        }
        [resultSet close];
    }];
    return checkIns;
}

- (void)addCheckIn:(TXCheckIn *)txCheckIn error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO checkin(checkin_id,card_code,attaches,user_id,username,checkin_time,garden_id,machine_id,client_key,parent_name,class_name,updated_on,created_on) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";

    NSString *attachesValue = @"";
    for (uint i = 0; i < txCheckIn.attaches.count; ++i) {
        BOOL isLast = i == txCheckIn.attaches.count - 1;
        attachesValue = isLast
                ? [attachesValue stringByAppendingFormat:@"%@", txCheckIn.attaches[i]]
                : [attachesValue stringByAppendingFormat:@"%@,", txCheckIn.attaches[i]];
    }

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txCheckIn.checkInId),
                               txCheckIn.cardCode,
                               attachesValue,
                               @(txCheckIn.userId),
                               txCheckIn.username,
                               @(txCheckIn.checkInTime),
                               @(txCheckIn.gardenId),
                               @(txCheckIn.machineId),
                               @(txCheckIn.clientKey),
                               txCheckIn.parentName,
                               txCheckIn.className,
                               @(TIMESTAMP_OF_NOW),
                               @(txCheckIn.createdOn)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (NSArray *)getFeeds:(int64_t)maxFeedId count:(int64_t)count isInbox:(BOOL)isInbox error:(NSError **)outError {
    __block NSMutableArray *txFeeds = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM feed WHERE feed_id<? AND is_inbox=? ORDER BY feed_id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxFeedId), @(isInbox), @(count)];
        while (resultSet.next) {
            TXFeed *txFeed = [[TXFeed alloc] init];
            [self setTXFeedProperties:txFeed fromResultSet:resultSet];
            [txFeeds addObject:txFeed];
        }
        [resultSet close];
    }];
    return txFeeds;
}

- (NSArray *)getFeeds:(int64_t)maxFeedId count:(int64_t)count userId:(int64_t)userId error:(NSError **)outError {
    __block NSMutableArray *txFeeds = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM feed WHERE feed_id<? AND user_id=? ORDER BY feed_id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxFeedId), @(userId), @(count)];
        while (resultSet.next) {
            TXFeed *txFeed = [[TXFeed alloc] init];
            [self setTXFeedProperties:txFeed fromResultSet:resultSet];
            [txFeeds addObject:txFeed];
        }
        [resultSet close];
    }];
    return txFeeds;
}

- (NSArray *)getComments:(int64_t)targetId targetType:(TXPBTargetType)targetType commentType:(TXPBCommentType)commentType maxCommentId:(int64_t)maxCommentId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *txComments = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM comment WHERE target_id=? AND target_type=? AND comment_type=? AND comment_id<? ORDER BY comment_id ASC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql,
                                                  @(targetId),
                                                  @(targetType),
                                                  @(commentType),
                                                  @(maxCommentId),
                                                  @(count)];
        while (resultSet.next) {
            TXComment *txComment = [[TXComment alloc] init];
            [self setTXCommentProperties:txComment fromResultSet:resultSet];
            [txComments addObject:txComment];
        }
        [resultSet close];
    }];
    return txComments;
}

- (TXFeed *)getLastFeed {
    return nil;
}

- (void)addFeed:(TXFeed *)txFeed error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO feed(created_on,updated_on,feed_id,is_inbox,content,attaches,"
            "user_id,user_nick_name,user_avatar_url,user_type) "
            "VALUES(?,?,?,?,?,?,?,?,?,?)";

    NSString *attachesValue = @"";
    for (uint i = 0; i < txFeed.attaches.count; ++i) {
        BOOL isLast = i == txFeed.attaches.count - 1;
        attachesValue = isLast
                ? [attachesValue stringByAppendingFormat:@"%@", txFeed.attaches[i]]
                : [attachesValue stringByAppendingFormat:@"%@,", txFeed.attaches[i]];
    }

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txFeed.createdOn),
                               @(txFeed.updatedOn),
                               @(txFeed.feedId),
                               @(txFeed.isInbox),
                               txFeed.content,
                               attachesValue,
                               @(txFeed.userId),
                               txFeed.userNickName,
                               txFeed.userAvatarUrl,
                               @(txFeed.userType)]
                ) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteFeedByFeedId:(int64_t)feedId error:(NSError **)outError {
    NSString *sql = @"DELETE FROM feed WHERE feed_id=?";
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(feedId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteCommentByCommentId:(int64_t)commentId error:(NSError **)outError {
    NSString *sql = @"DELETE FROM comment WHERE comment_id=?";
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(commentId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}


- (void)addComment:(TXComment *)txComment error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO comment(created_on,updated_on,comment_id,content,comment_type,target_id,target_user_id,target_type,to_user_id,to_user_nickname,user_id,user_nickname,user_avatar_url) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txComment.createdOn),
                               @(TIMESTAMP_OF_NOW),
                               @(txComment.commentId),
                               txComment.content,
                               @(txComment.commentType),
                               @(txComment.targetId),
                               @(txComment.targetUserId),
                               @(txComment.targetType),
                               @(txComment.toUserId),
                               txComment.toUserNickname,
                               @(txComment.userId),
                               txComment.userNickname,
                               txComment.userAvatarUrl]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}


- (TXCheckIn *)getLastCheckIn {
    __block TXCheckIn *txCheckIn;
    NSString *sql = @"SELECT * FROM checkin ORDER BY checkin_id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if (resultSet.next) {
            txCheckIn = [[TXCheckIn alloc] init];
            [self setTXCheckInProperties:txCheckIn fromResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txCheckIn;
}


@end
