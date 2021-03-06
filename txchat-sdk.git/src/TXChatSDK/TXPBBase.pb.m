// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "TXPBBase.pb.h"
// @@protoc_insertion_point(imports)

@implementation TXPBTxpbbaseRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [TXPBTxpbbaseRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [ObjectivecDescriptorRoot registerAllExtensions:registry];
    extensionRegistry = registry;
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

@interface TXPBRequest ()
@property (strong) NSString* url;
@property (strong) NSData* body;
@property (strong) NSString* token;
@property (strong) NSString* version;
@end

@implementation TXPBRequest

- (BOOL) hasUrl {
  return !!hasUrl_;
}
- (void) setHasUrl:(BOOL) _value_ {
  hasUrl_ = !!_value_;
}
@synthesize url;
- (BOOL) hasBody {
  return !!hasBody_;
}
- (void) setHasBody:(BOOL) _value_ {
  hasBody_ = !!_value_;
}
@synthesize body;
- (BOOL) hasToken {
  return !!hasToken_;
}
- (void) setHasToken:(BOOL) _value_ {
  hasToken_ = !!_value_;
}
@synthesize token;
- (BOOL) hasVersion {
  return !!hasVersion_;
}
- (void) setHasVersion:(BOOL) _value_ {
  hasVersion_ = !!_value_;
}
@synthesize version;
- (instancetype) init {
  if ((self = [super init])) {
    self.url = @"";
    self.body = [NSData data];
    self.token = @"";
    self.version = @"";
  }
  return self;
}
static TXPBRequest* defaultTXPBRequestInstance = nil;
+ (void) initialize {
  if (self == [TXPBRequest class]) {
    defaultTXPBRequestInstance = [[TXPBRequest alloc] init];
  }
}
+ (instancetype) defaultInstance {
  return defaultTXPBRequestInstance;
}
- (instancetype) defaultInstance {
  return defaultTXPBRequestInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasUrl) {
    [output writeString:1 value:self.url];
  }
  if (self.hasBody) {
    [output writeData:2 value:self.body];
  }
  if (self.hasToken) {
    [output writeString:3 value:self.token];
  }
  if (self.hasVersion) {
    [output writeString:4 value:self.version];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (SInt32) serializedSize {
  __block SInt32 size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasUrl) {
    size_ += computeStringSize(1, self.url);
  }
  if (self.hasBody) {
    size_ += computeDataSize(2, self.body);
  }
  if (self.hasToken) {
    size_ += computeStringSize(3, self.token);
  }
  if (self.hasVersion) {
    size_ += computeStringSize(4, self.version);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (TXPBRequest*) parseFromData:(NSData*) data {
  return (TXPBRequest*)[[[TXPBRequest builder] mergeFromData:data] build];
}
+ (TXPBRequest*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TXPBRequest*)[[[TXPBRequest builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (TXPBRequest*) parseFromInputStream:(NSInputStream*) input {
  return (TXPBRequest*)[[[TXPBRequest builder] mergeFromInputStream:input] build];
}
+ (TXPBRequest*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TXPBRequest*)[[[TXPBRequest builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TXPBRequest*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (TXPBRequest*)[[[TXPBRequest builder] mergeFromCodedInputStream:input] build];
}
+ (TXPBRequest*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TXPBRequest*)[[[TXPBRequest builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TXPBRequestBuilder*) builder {
  return [[TXPBRequestBuilder alloc] init];
}
+ (TXPBRequestBuilder*) builderWithPrototype:(TXPBRequest*) prototype {
  return [[TXPBRequest builder] mergeFrom:prototype];
}
- (TXPBRequestBuilder*) builder {
  return [TXPBRequest builder];
}
- (TXPBRequestBuilder*) toBuilder {
  return [TXPBRequest builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasUrl) {
    [output appendFormat:@"%@%@: %@\n", indent, @"url", self.url];
  }
  if (self.hasBody) {
    [output appendFormat:@"%@%@: %@\n", indent, @"body", self.body];
  }
  if (self.hasToken) {
    [output appendFormat:@"%@%@: %@\n", indent, @"token", self.token];
  }
  if (self.hasVersion) {
    [output appendFormat:@"%@%@: %@\n", indent, @"version", self.version];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (void) storeInDictionary:(NSMutableDictionary *)dictionary {
  if (self.hasUrl) {
    [dictionary setObject: self.url forKey: @"url"];
  }
  if (self.hasBody) {
    [dictionary setObject: self.body forKey: @"body"];
  }
  if (self.hasToken) {
    [dictionary setObject: self.token forKey: @"token"];
  }
  if (self.hasVersion) {
    [dictionary setObject: self.version forKey: @"version"];
  }
  [self.unknownFields storeInDictionary:dictionary];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[TXPBRequest class]]) {
    return NO;
  }
  TXPBRequest *otherMessage = other;
  return
      self.hasUrl == otherMessage.hasUrl &&
      (!self.hasUrl || [self.url isEqual:otherMessage.url]) &&
      self.hasBody == otherMessage.hasBody &&
      (!self.hasBody || [self.body isEqual:otherMessage.body]) &&
      self.hasToken == otherMessage.hasToken &&
      (!self.hasToken || [self.token isEqual:otherMessage.token]) &&
      self.hasVersion == otherMessage.hasVersion &&
      (!self.hasVersion || [self.version isEqual:otherMessage.version]) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  __block NSUInteger hashCode = 7;
  if (self.hasUrl) {
    hashCode = hashCode * 31 + [self.url hash];
  }
  if (self.hasBody) {
    hashCode = hashCode * 31 + [self.body hash];
  }
  if (self.hasToken) {
    hashCode = hashCode * 31 + [self.token hash];
  }
  if (self.hasVersion) {
    hashCode = hashCode * 31 + [self.version hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface TXPBRequestBuilder()
@property (strong) TXPBRequest* resultRequest;
@end

@implementation TXPBRequestBuilder
@synthesize resultRequest;
- (instancetype) init {
  if ((self = [super init])) {
    self.resultRequest = [[TXPBRequest alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return resultRequest;
}
- (TXPBRequestBuilder*) clear {
  self.resultRequest = [[TXPBRequest alloc] init];
  return self;
}
- (TXPBRequestBuilder*) clone {
  return [TXPBRequest builderWithPrototype:resultRequest];
}
- (TXPBRequest*) defaultInstance {
  return [TXPBRequest defaultInstance];
}
- (TXPBRequest*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (TXPBRequest*) buildPartial {
  TXPBRequest* returnMe = resultRequest;
  self.resultRequest = nil;
  return returnMe;
}
- (TXPBRequestBuilder*) mergeFrom:(TXPBRequest*) other {
  if (other == [TXPBRequest defaultInstance]) {
    return self;
  }
  if (other.hasUrl) {
    [self setUrl:other.url];
  }
  if (other.hasBody) {
    [self setBody:other.body];
  }
  if (other.hasToken) {
    [self setToken:other.token];
  }
  if (other.hasVersion) {
    [self setVersion:other.version];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (TXPBRequestBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (TXPBRequestBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  PBUnknownFieldSetBuilder* unknownFields = [PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    SInt32 tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 10: {
        [self setUrl:[input readString]];
        break;
      }
      case 18: {
        [self setBody:[input readData]];
        break;
      }
      case 26: {
        [self setToken:[input readString]];
        break;
      }
      case 34: {
        [self setVersion:[input readString]];
        break;
      }
    }
  }
}
- (BOOL) hasUrl {
  return resultRequest.hasUrl;
}
- (NSString*) url {
  return resultRequest.url;
}
- (TXPBRequestBuilder*) setUrl:(NSString*) value {
  resultRequest.hasUrl = YES;
  resultRequest.url = value;
  return self;
}
- (TXPBRequestBuilder*) clearUrl {
  resultRequest.hasUrl = NO;
  resultRequest.url = @"";
  return self;
}
- (BOOL) hasBody {
  return resultRequest.hasBody;
}
- (NSData*) body {
  return resultRequest.body;
}
- (TXPBRequestBuilder*) setBody:(NSData*) value {
  resultRequest.hasBody = YES;
  resultRequest.body = value;
  return self;
}
- (TXPBRequestBuilder*) clearBody {
  resultRequest.hasBody = NO;
  resultRequest.body = [NSData data];
  return self;
}
- (BOOL) hasToken {
  return resultRequest.hasToken;
}
- (NSString*) token {
  return resultRequest.token;
}
- (TXPBRequestBuilder*) setToken:(NSString*) value {
  resultRequest.hasToken = YES;
  resultRequest.token = value;
  return self;
}
- (TXPBRequestBuilder*) clearToken {
  resultRequest.hasToken = NO;
  resultRequest.token = @"";
  return self;
}
- (BOOL) hasVersion {
  return resultRequest.hasVersion;
}
- (NSString*) version {
  return resultRequest.version;
}
- (TXPBRequestBuilder*) setVersion:(NSString*) value {
  resultRequest.hasVersion = YES;
  resultRequest.version = value;
  return self;
}
- (TXPBRequestBuilder*) clearVersion {
  resultRequest.hasVersion = NO;
  resultRequest.version = @"";
  return self;
}
@end

@interface TXPBResponse ()
@property SInt32 status;
@property (strong) NSString* statusTxt;
@property (strong) NSData* body;
@end

@implementation TXPBResponse

- (BOOL) hasStatus {
  return !!hasStatus_;
}
- (void) setHasStatus:(BOOL) _value_ {
  hasStatus_ = !!_value_;
}
@synthesize status;
- (BOOL) hasStatusTxt {
  return !!hasStatusTxt_;
}
- (void) setHasStatusTxt:(BOOL) _value_ {
  hasStatusTxt_ = !!_value_;
}
@synthesize statusTxt;
- (BOOL) hasBody {
  return !!hasBody_;
}
- (void) setHasBody:(BOOL) _value_ {
  hasBody_ = !!_value_;
}
@synthesize body;
- (instancetype) init {
  if ((self = [super init])) {
    self.status = 0;
    self.statusTxt = @"";
    self.body = [NSData data];
  }
  return self;
}
static TXPBResponse* defaultTXPBResponseInstance = nil;
+ (void) initialize {
  if (self == [TXPBResponse class]) {
    defaultTXPBResponseInstance = [[TXPBResponse alloc] init];
  }
}
+ (instancetype) defaultInstance {
  return defaultTXPBResponseInstance;
}
- (instancetype) defaultInstance {
  return defaultTXPBResponseInstance;
}
- (BOOL) isInitialized {
  if (!self.hasStatus) {
    return NO;
  }
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasStatus) {
    [output writeInt32:1 value:self.status];
  }
  if (self.hasStatusTxt) {
    [output writeString:2 value:self.statusTxt];
  }
  if (self.hasBody) {
    [output writeData:3 value:self.body];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (SInt32) serializedSize {
  __block SInt32 size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasStatus) {
    size_ += computeInt32Size(1, self.status);
  }
  if (self.hasStatusTxt) {
    size_ += computeStringSize(2, self.statusTxt);
  }
  if (self.hasBody) {
    size_ += computeDataSize(3, self.body);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (TXPBResponse*) parseFromData:(NSData*) data {
  return (TXPBResponse*)[[[TXPBResponse builder] mergeFromData:data] build];
}
+ (TXPBResponse*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TXPBResponse*)[[[TXPBResponse builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (TXPBResponse*) parseFromInputStream:(NSInputStream*) input {
  return (TXPBResponse*)[[[TXPBResponse builder] mergeFromInputStream:input] build];
}
+ (TXPBResponse*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TXPBResponse*)[[[TXPBResponse builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TXPBResponse*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (TXPBResponse*)[[[TXPBResponse builder] mergeFromCodedInputStream:input] build];
}
+ (TXPBResponse*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TXPBResponse*)[[[TXPBResponse builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TXPBResponseBuilder*) builder {
  return [[TXPBResponseBuilder alloc] init];
}
+ (TXPBResponseBuilder*) builderWithPrototype:(TXPBResponse*) prototype {
  return [[TXPBResponse builder] mergeFrom:prototype];
}
- (TXPBResponseBuilder*) builder {
  return [TXPBResponse builder];
}
- (TXPBResponseBuilder*) toBuilder {
  return [TXPBResponse builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasStatus) {
    [output appendFormat:@"%@%@: %@\n", indent, @"status", [NSNumber numberWithInteger:self.status]];
  }
  if (self.hasStatusTxt) {
    [output appendFormat:@"%@%@: %@\n", indent, @"statusTxt", self.statusTxt];
  }
  if (self.hasBody) {
    [output appendFormat:@"%@%@: %@\n", indent, @"body", self.body];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (void) storeInDictionary:(NSMutableDictionary *)dictionary {
  if (self.hasStatus) {
    [dictionary setObject: [NSNumber numberWithInteger:self.status] forKey: @"status"];
  }
  if (self.hasStatusTxt) {
    [dictionary setObject: self.statusTxt forKey: @"statusTxt"];
  }
  if (self.hasBody) {
    [dictionary setObject: self.body forKey: @"body"];
  }
  [self.unknownFields storeInDictionary:dictionary];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[TXPBResponse class]]) {
    return NO;
  }
  TXPBResponse *otherMessage = other;
  return
      self.hasStatus == otherMessage.hasStatus &&
      (!self.hasStatus || self.status == otherMessage.status) &&
      self.hasStatusTxt == otherMessage.hasStatusTxt &&
      (!self.hasStatusTxt || [self.statusTxt isEqual:otherMessage.statusTxt]) &&
      self.hasBody == otherMessage.hasBody &&
      (!self.hasBody || [self.body isEqual:otherMessage.body]) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  __block NSUInteger hashCode = 7;
  if (self.hasStatus) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.status] hash];
  }
  if (self.hasStatusTxt) {
    hashCode = hashCode * 31 + [self.statusTxt hash];
  }
  if (self.hasBody) {
    hashCode = hashCode * 31 + [self.body hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface TXPBResponseBuilder()
@property (strong) TXPBResponse* resultResponse;
@end

@implementation TXPBResponseBuilder
@synthesize resultResponse;
- (instancetype) init {
  if ((self = [super init])) {
    self.resultResponse = [[TXPBResponse alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return resultResponse;
}
- (TXPBResponseBuilder*) clear {
  self.resultResponse = [[TXPBResponse alloc] init];
  return self;
}
- (TXPBResponseBuilder*) clone {
  return [TXPBResponse builderWithPrototype:resultResponse];
}
- (TXPBResponse*) defaultInstance {
  return [TXPBResponse defaultInstance];
}
- (TXPBResponse*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (TXPBResponse*) buildPartial {
  TXPBResponse* returnMe = resultResponse;
  self.resultResponse = nil;
  return returnMe;
}
- (TXPBResponseBuilder*) mergeFrom:(TXPBResponse*) other {
  if (other == [TXPBResponse defaultInstance]) {
    return self;
  }
  if (other.hasStatus) {
    [self setStatus:other.status];
  }
  if (other.hasStatusTxt) {
    [self setStatusTxt:other.statusTxt];
  }
  if (other.hasBody) {
    [self setBody:other.body];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (TXPBResponseBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (TXPBResponseBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  PBUnknownFieldSetBuilder* unknownFields = [PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    SInt32 tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 8: {
        [self setStatus:[input readInt32]];
        break;
      }
      case 18: {
        [self setStatusTxt:[input readString]];
        break;
      }
      case 26: {
        [self setBody:[input readData]];
        break;
      }
    }
  }
}
- (BOOL) hasStatus {
  return resultResponse.hasStatus;
}
- (SInt32) status {
  return resultResponse.status;
}
- (TXPBResponseBuilder*) setStatus:(SInt32) value {
  resultResponse.hasStatus = YES;
  resultResponse.status = value;
  return self;
}
- (TXPBResponseBuilder*) clearStatus {
  resultResponse.hasStatus = NO;
  resultResponse.status = 0;
  return self;
}
- (BOOL) hasStatusTxt {
  return resultResponse.hasStatusTxt;
}
- (NSString*) statusTxt {
  return resultResponse.statusTxt;
}
- (TXPBResponseBuilder*) setStatusTxt:(NSString*) value {
  resultResponse.hasStatusTxt = YES;
  resultResponse.statusTxt = value;
  return self;
}
- (TXPBResponseBuilder*) clearStatusTxt {
  resultResponse.hasStatusTxt = NO;
  resultResponse.statusTxt = @"";
  return self;
}
- (BOOL) hasBody {
  return resultResponse.hasBody;
}
- (NSData*) body {
  return resultResponse.body;
}
- (TXPBResponseBuilder*) setBody:(NSData*) value {
  resultResponse.hasBody = YES;
  resultResponse.body = value;
  return self;
}
- (TXPBResponseBuilder*) clearBody {
  resultResponse.hasBody = NO;
  resultResponse.body = [NSData data];
  return self;
}
@end


// @@protoc_insertion_point(global_scope)
