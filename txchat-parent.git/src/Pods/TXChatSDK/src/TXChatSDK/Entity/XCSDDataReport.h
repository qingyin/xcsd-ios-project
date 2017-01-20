//
//  XCSDDataReport.h


#import "TXEntityBase.h"
#import "XCSDDataProto.pb.h"


@interface XCSDDataReport : TXEntityBase

@property (nonatomic, assign) SInt64 drid;
@property (nonatomic, assign) SInt64 userId;
@property (nonatomic, assign) SInt32 eventType;
@property (nonatomic, strong) NSString* bid;
@property (nonatomic, assign) SInt64 timestamp;
@property (nonatomic, strong) NSString* extendedInfo;
@property (nonatomic, assign) SInt32 sendedState;
@property (nonatomic, assign) SInt64 serialNo;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

//+ (instancetype)loadValueFromPB:(XCSDPBEvent *)lesson;

@end

