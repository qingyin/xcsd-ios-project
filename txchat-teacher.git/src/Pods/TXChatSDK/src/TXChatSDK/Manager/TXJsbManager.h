//
//  TXJsbManager.h
//  TXChatSDK
//
//  Created by lingqingwan on 12/4/15.
//  Copyright © 2015 lingiqngwan. All rights reserved.
//

#import "TXChatManagerBase.h"

@interface TXJsbManager : TXChatManagerBase

/**
 * 获取分类列表
 */
- (void)fetchTagsWithTagType:(TXPBTagType)tagType
                 onCompleted:(void (^)(NSError *error, NSArray/*<TXPBTag>*/ *tags))onCompleted;

/**
 * 获取推荐问题列表,pageNum第一次为1,以后每次+1
 */
- (void)fetchHotQuestionsWithPageNum:(int32_t)pageNum
                         onCompleted:(void (^)(NSError *error, NSArray/*<TXPBQuestion>*/ *questions, BOOL hasMore))onCompleted;

/**
 * 获取问题列表
 */
- (void)fetchQuestionsWithTagId:(int64_t)tagId //optional
                       authorId:(int64_t)authorId //optional
                          maxId:(int64_t)maxId
                    onCompleted:(void (^)(NSError *error, NSArray/*<TXPBQuestion>*/ *questions, BOOL hasMore))onCompleted;

/**
 * 提问
 */
- (void)askQuestionWithTagId:(int64_t)tagId
                    expertId:(int64_t)expertId //optional
                       title:(NSString *)title
                     content:(NSString *)content
                   anonymous:(BOOL)anonymous
                    attaches:(NSArray/*<TXPBAttach>*/ *)attaches
                 onCompleted:(void (^)(NSError *error))onCompleted;

/**
 * 获取指定id的question
 */
- (void)fetchQuestionWithQuestionId:(int64_t)questionId
                        onCompleted:(void (^)(NSError *error, TXPBQuestion *question))onCompleted;

/**
 * 获取问题答案,可选参数如果没有,传0
 * - 我的回答
 */
- (void)fetchQuestionAnswersWithQuestionId:(int64_t)questionId //optional
                                  authorId:(int64_t)authorId //optional
                                  userType:(TXPBUserType)userType //optional
                                     maxId:(int64_t)maxId
                               onCompleted:(void (^)(NSError *error, NSArray/*<TXPBQuestionAnswer>*/ *answers, BOOL hasMore, NSArray/*<TXPBQuestionAnswer>*/ *expertAnswers, BOOL hasMoreExpertAnswers))onCompleted;

/**
 * 关注问题
 */
- (void)followQuestionWithQuestionId:(int64_t)questionId
                         onCompleted:(void (^)(NSError *error))onCompleted;

/**
 * 回答问题
 */
- (void)answerQuestionWithQuestionId:(int64_t)questionId
                             content:(NSString *)content
                           anonymous:(BOOL)anonymous
                            attaches:(NSArray/*<TXPBAttach>*/ *)attaches
                         onCompleted:(void (^)(NSError *error))onCompleted;

/**
 * 删除自己的答案
 */
- (void)deleteQuestionAnswerWithAnswerId:(int64_t)answerId
                             onCompleted:(void (^)(NSError *error))onCompleted;

/**
 * 获取专家列表
 */
- (void)fetchExpertsWithPageNum:(int64_t)pageNum
                  onCompleted:(void (^)(NSError *error, NSArray/*<TXPBExpert>*/ *experts, BOOL hasMore))onCompleted;

/**
 * 获取推荐专家列表
 */
- (void)fetchRecommendExpertsWithCompleted:(void (^)(NSError *error, NSArray/*<TXPBExpert>*/ *experts))onCompleted;

/**
 * 获取专家详情
 */
- (void)fetchExpertDetailsWithExpertId:(int64_t)expertId
                           onCompleted:(void (^)(NSError *error, TXPBExpert *expert, NSArray/*<TXPBQuestionAnswer>*/ *answers, BOOL hasMoreAnswer, NSArray/*<TXPBKnowledge>*/ *knowledge, BOOL hasMoreKnowledge))onCompleted;

/**
 * 关注专家
 */
- (void)followExpertWithExpertId:(int64_t)expertId
                        isFollow:(BOOL)isFollow
                     onCompleted:(void (^)(NSError *error))onCompleted;

/*
 * 获取推荐文章列表
 */
- (void)fetchHotKnowledgesWihtPageNum:(int32_t)pageNum
                          onCompleted:(void (^)(NSError *error, NSArray/*<TXPBKnowledge>*/ *knowledge, BOOL hasMore))onCompleted;

/**
 * 获取指定分类文章列表
 */
- (void)fetchKnowledgesWithTagId:(int64_t)tagId
                        auhtorId:(int64_t)authorId
                           maxId:(int64_t)maxId
                     onCompleted:(void (^)(NSError *error, NSArray/*<TXPBKnowledge>*/ *knowledge, BOOL hasMore))onCompleted;

/*
 * 获取指定id的文章
 */
- (void)fetchKnowledgeWithKnowledgeId:(int64_t)knowledgeId
                          onCompleted:(void (^)(NSError *error, TXPBKnowledge *knowledge))onCompleted;

/**
 * 收藏文章
 */
- (void)favoriteKnowledgeWithKnowledgeId:(int64_t)knowledgeId
                              isFavorate:(BOOL)isFavorite
                             onCompleted:(void (^)(NSError *error))onCompleted;

/**
 * 获取教师帮消息
 */
-(void)fetchCommunionMessagesWithMaxId:(int64_t)maxId
                           onCompleted:(void (^)(NSError *error,NSArray/*<TXPBCommunionMessage>*/ *communionMessages,BOOL hasMore))onCompleted;

@end
