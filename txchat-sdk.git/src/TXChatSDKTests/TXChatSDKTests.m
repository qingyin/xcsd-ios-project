//
//  TXChatSDKTests.m
//  TXChatSDKTests
//
//  Created by lingiqngwan on 6/4/15.
//  Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TXChatTestDef.h"
#import "TXChatSDK.h"

@interface TXChatSDKTests : XCTestCase
@end

@implementation TXChatSDKTests {
    TXChatClient *client;
}

- (void)setUp {
    [super setUp];
    client = [TXChatClient sharedInstance];
    [client setupWithVersion:@"teacher_1.0.0"];
    NSLog(@"-----------------------------------------------------------------------------");
}

- (void)tearDown {
    [super tearDown];
}

- (void)test1LoginWithCorrectUsernameAndPassword {
    [client.userManager loginWithUsername:@"18600026672"
                                 password:@"111111"
                              onCompleted:^(NSError *error, TXUser *txUser) {
                                  XCTAssertEqualObjects(error, nil);
                                  NSLog(@"%@", txUser);

                                  XCTAssertNotNil(txUser);
                                  TXUser *currentUser = [client getUserByUsername:txUser.username error:nil];
                                  XCTAssertEqual(currentUser.userId, txUser.userId);
                              }];
}

-(void)testPost{
    [client.postManager markPostAsReadWithPostId:764];
    
    [client .postManager fetchPosts:LLONG_MAX gardenId:1026429 postType:TXPBPostTypeActivity onCompleted:^(NSError *error, NSArray *posts, BOOL hasMore) {
        XCTAssertEqualObjects(error, nil);
        NSLog(@"%@", posts);
    }];
}

- (void)testFetchContacts {
    [client.userManager fetchDepartments:^(NSError *error, NSArray *txpbDepartments) {
        XCTAssertEqualObjects(error, nil);

        NSArray *departments = [client getAllDepartments:nil];
        XCTAssertTrue(departments.count > 0);
    }];
}

- (void)testFetchDepartmentMember {
    [client.userManager fetchDepartmentMembers:1026430 clearLocalData:FALSE onCompleted:^(NSError *error) {
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testFetchDepartmentByGroupId {
    [client fetchDepartmentByGroupId:@"1434265609395934" onCompleted:^(NSError *error) {
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testGetDepartmentByGroupId {
    NSError *error;
    TXDepartment *txDepartment = [client getDepartmentByGroupId:@"1434265609395934" error:&error];
    NSLog(@"ERROR=%@", error);
    NSLog(@"txDepartment=%@", txDepartment);
    XCTAssertEqualObjects(error, nil);
}

- (void)testGetDepartmentMembers {
    NSError *error;
    NSArray *txUsers = [client getDepartmentMembers:379 userType:TXPBUserTypeChild error:&error];
    XCTAssertEqualObjects(error, nil);
}

- (void)testGetNotices {
    NSError *error;
    NSArray *notices = [client getNotices:0 count:10 error:&error];
    for (int i = 0; i < notices.count; ++i) {
        TXNotice *txNotice = notices[i];
        for (int j = 0; j < txNotice.attaches.count; ++j) {
            NSLog(@"%@", txNotice.attaches[j]);
        }
    }

    NSLog(@"%@", notices);
}

- (void)testFetchUserByUserId {
    [client fetchUserByUserId:3 onCompleted:^(NSError *error, TXUser *txUser) {
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testGetLastNotice {
    NSError *error;
    TXNotice *txNotice = [client getLastNotice:&error];
    NSLog(@"%@", txNotice);
}


- (void)testGetParentUsersByChildUserId {
    NSError *error;
    NSArray *parentUsers = [client getParentUsersByChildUserId:2 error:&error];
    NSLog(@"ERROR=%@", error);
    NSLog(@"%@", parentUsers);
}


- (void)testMarkNoticeHasRead {
    WAIT_START;
    [client markNoticeHasRead:822 onCompleted:^(NSError *error) {
        NSLog(@"ERROR=%@", error);
        XCTAssertEqualObjects(error, nil);
        WAIT_DONE;
    }];

    WAIT_UNTIL_DONE;
}

- (void)testFetchFileUploadTokenWithCompleted {
    WAIT_START;
    [client fetchFileUploadTokenWithCompleted:^(NSError *error, NSString *token) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"UPLOAD TOKEN %@", token);
        XCTAssertEqualObjects(error, nil);
        WAIT_DONE;
    }];
    WAIT_UNTIL_DONE;
}

- (void)testUploadData {
    [client uploadData:[@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding] uuidKey:[NSUUID UUID] fileExtension:@"txt" cancellationSignal:^BOOL {
        return NO;
    }  progressHandler:^(NSString *key, float percent) {
        NSLog(@"%f", percent);

    }      onCompleted:^(NSError *error, NSString *serverFileKey, NSString *serverFileUrl) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"UPLOAD KEY %@ %@", serverFileKey, serverFileUrl);
        XCTAssertEqualObjects(error, nil);
    }];

}


- (void)testFetchChild {
    [client fetchChild:^(NSError *error, TXUser *childUser) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"fetchChild %@", childUser);
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testChangePassword {
    [client changePassword:@"111111" mobilePhoneNumber:@"11111" verifyCode:@"111" onCompleted:^(NSError *error) {
        NSLog(@"ERROR=%@", error);
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testUpdateUserInfo {
    TXUser *user = [client getCurrentUser:nil];
    user.sex = TXPBSexTypeFemale;
    user.sign = @"HELLO WORLD";

    [client updateUserInfo:user onCompleted:^(NSError *error) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"CURRENT USER=%@", [client getCurrentUser:nil]);

        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testChangeMobilePhoneNumber {
    [client changeMobilePhoneNumber:@"12345678901" verifyCode:@"123456" onCompleted:^(NSError *error) {
        NSLog(@"ERROR=%@", error);
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testSendFeedMedicineTask {
    TXPBAttachBuilder *txpbAttachBuilder = [TXPBAttach builder];
    txpbAttachBuilder.attachType = TXPBAttachTypePic;
    txpbAttachBuilder.fileurl = @"xxxxxxxxxxxxx-xxxxxxxxx-xxxxxxx-x.jpg";
    TXPBAttach *txpbAttach = [txpbAttachBuilder build];

    [client sendFeedMedicineTask:@"sdfsdf"
                        attaches:@[txpbAttach, txpbAttach, txpbAttach, txpbAttach]
                       beginDate:(int64_t) [[NSDate date] timeIntervalSince1970]
                     onCompleted:^(NSError *error, int64_t feedMedicineTaskId) {
                         NSLog(@"ERROR=%@", error);
                         XCTAssertEqualObjects(error, nil);
                     }];
}

- (void)testFeeds {
    [client fetchFeeds:LLONG_MAX
               isInbox:TRUE
           onCompleted:^(NSError *error, NSArray *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore) {
               XCTAssertEqualObjects(error, nil);
               NSLog(@"FEED %@", feeds);
               for(TXFeed *feed in feeds){
                   NSLog(@"%@",feed.content);
               }
           }];

}


- (void)testFetchFeedMedicineTasks {
    [client fetchFeedMedicineTasks:LLONG_MAX onCompleted:^(NSError *error, NSArray *txFeedMedicineTasks, BOOL hasMore) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"FEED %@", txFeedMedicineTasks);
        XCTAssertEqualObjects(error, nil);
    }];

}

- (void)testFetchBoundParents {
    [client fetchBoundParents:^(NSError *error, NSArray *parentMap) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"parentMap %@", parentMap);
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testSendGardenMail {
    [client sendGardenMail:@"园长，别跑。" isAnonymous:TRUE onCompleted:^(NSError *error, int64_t gardenMailId) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"gardenMailId = %qi", gardenMailId);
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testSaveUserProfiles {
    NSMutableDictionary *profiles = [NSMutableDictionary dictionary];
    profiles[@"open_sound"] = @"0";

    [client saveUserProfiles:profiles onCompleted:^(NSError *error) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"CURRENT PROFILES %@", [client getCurrentUserProfiles:nil]);
        XCTAssertEqualObjects(error, nil);
    }];

}

- (void)testFetchUserProfiles {
    [client fetchUserProfiles:^(NSError *error, NSDictionary *profiles) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"CURRENT PROFILES %@", [client getCurrentUserProfiles:nil]);
        NSLog(@"%@", profiles);
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testActiveInviteUser {
}

- (void)testFetchPosts {
    [client.txJsbMansger fetchKnowledgesWithTagId:0 auhtorId:0 maxId:100000 onCompleted:^(NSError *error, NSArray *knowledge, BOOL hasMore) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"datas=%@", knowledge);
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testSendComment {
    [client sendComment:@"hahha"
            commentType:TXPBCommentTypeReply
               toUserId:0
               targetId:124
             targetType:TXPBTargetTypeGardenMail
            onCompleted:^(NSError *error, int64_t commentId) {
                NSLog(@"ERROR=%@", error);
                XCTAssertEqualObjects(error, nil);
            }];
}


- (void)testFetchCounters {
    [client fetchCounters:^(NSError *error, NSMutableDictionary *countersDictionary) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"countersDictionary=%@", countersDictionary);
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testDeleteComment {
    [client deleteComment:13 onCompleted:^(NSError *error) {
        NSLog(@"ERROR=%@", error);
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testGetGardenMails {
    NSArray *results = [client getGardenMails:LLONG_MAX count:1000 error:nil];
    NSLog(@"results=%@", results);
}

- (void)testGetFeedMedicineTasks {
    NSArray *results = [client getFeedMedicineTasks:LLONG_MAX count:1000 error:nil];
    NSLog(@"results=%@", results);
}

- (void)testDepartmentPhotos {
}

typedef struct attach {
    char *url;
} attach_t;

- (void)testQrCheckIn {
    TXPBAttachBuilder *txpbAttachBuilder = [TXPBAttach builder];
    txpbAttachBuilder.fileurl = @"sdfsd";
    txpbAttachBuilder.attachType = TXPBAttachTypeAudio;


    NSMutableArray *attaches = [NSMutableArray array];

    [attaches addObject:@{@"type" : @"1", @"url" : @"http://2222.com/a.jpg"}];
    [attaches addObject:@{@"type" : @"1", @"url" : @"http://2222.com/a.jpg"}];
    [attaches addObject:@{@"type" : @"1", @"url" : @"http://2222.com/a.jpg"}];


    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:attaches options:0 error:nil]
                                                 encoding:NSUTF8StringEncoding];

    NSLog(@"%@", jsonString);


    NSArray *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0
                                                      error:nil];
    for (NSDictionary *dictionary in json) {
        NSLog(@"%@", [dictionary valueForKey:@"url"]);
    }
}

- (void)testTracks {
    int64_t progressValue = [client.trackManager queryTrackPlayProgressValue:1];
    NSLog(@"%lld", progressValue);

    [client.trackManager resetTrackPlayProgressValue:1 progressValue:10];

    progressValue = [client.trackManager queryTrackPlayProgressValue:1];
    NSLog(@"%lld", progressValue);
}

- (void)test_fetchCommunionMessagesWithMaxId {
    [client.txJsbMansger fetchCommunionMessagesWithMaxId:LLONG_MAX onCompleted:^(NSError *error, NSArray *communionMessages, BOOL hasMore) {
        NSLog(@"ERROR=%@", error);
        NSLog(@"DATA=%@", communionMessages);
        XCTAssertEqualObjects(error, nil);
    }];
}

@end
