//
//  TXJsbManager.m
//  TXChatSDK
//
//  Created by lingqingwan on 12/4/15.
//  Copyright © 2015 lingiqngwan. All rights reserved.
//

#import "TXJsbManager.h"
#import "TXApplicationManager.h"

@implementation TXJsbManager
- (void)fetchTagsWithTagType:(TXPBTagType)tagType onCompleted:(void (^)(NSError *error, NSArray/*<TXPBTag>*/ *tags))onCompleted {
    TXPBFetchTagsRequestBuilder *requestBuilder = [TXPBFetchTagsRequest builder];
    requestBuilder.type = tagType;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_tags"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchTagsResponse *txpbFetchTagsResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchTagsResponse, txpbFetchTagsResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txpbFetchTagsResponse.tags);
                                           });
                                       }
                                   }];
}

- (void)fetchHotQuestionsWithPageNum:(int32_t)pageNum onCompleted:(void (^)(NSError *error, NSArray/*<TXPBQuestion>*/ *questions, BOOL hasMore))onCompleted {
    TXPBFetchHotQuestionsRequestBuilder *requestBuilder = [TXPBFetchHotQuestionsRequest builder];
    requestBuilder.pageNum = pageNum;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_hot_questions"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchHotQuestionsResponse *txpbFetchHotQuestionsResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchHotQuestionsResponse, txpbFetchHotQuestionsResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txpbFetchHotQuestionsResponse.questions, txpbFetchHotQuestionsResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)fetchQuestionsWithTagId:(int64_t)tagId authorId:(int64_t)authorId maxId:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray/*<TXPBQuestion>*/ *questions, BOOL hasMore))onCompleted {
    TXPBFetchQuestionsRequestBuilder *requestBuilder = [TXPBFetchQuestionsRequest builder];
    if (authorId != 0)
        requestBuilder.authorId = authorId;
    if (tagId != 0)
        requestBuilder.tagId = tagId;
    requestBuilder.maxId = maxId;
    requestBuilder.sinceId = 0;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_questions"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchQuestionsResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchQuestionsResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, innerResponse.questions, innerResponse.hasMore);
                                           });
                                       }
                                   }];
}


- (void)askQuestionWithTagId:(int64_t)tagId
                    expertId:(int64_t)expertId title:(NSString *)title content:(NSString *)content
                   anonymous:(BOOL)anonymous
                    attaches:(NSArray/*<TXPBAttach>*/ *)attaches
                 onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBAskQuestionRequestBuilder *requestBuilder = [TXPBAskQuestionRequest builder];
    requestBuilder.tagId = tagId;
    if (expertId != 0) {
        requestBuilder.expertId = expertId;
    }
    requestBuilder.title = title;
    requestBuilder.content = content;
    requestBuilder.anonymous = anonymous;
    [requestBuilder setAttachesArray:attaches];

    [[TXHttpClient sharedInstance] sendRequest:@"/ask_question"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBAskQuestionResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBAskQuestionResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

- (void)fetchQuestionWithQuestionId:(int64_t)questionId onCompleted:(void (^)(NSError *error, TXPBQuestion *question))onCompleted {
    TXPBFetchQuestionDetailRequestBuilder *requestBuilder = [TXPBFetchQuestionDetailRequest builder];
    requestBuilder.questionId = questionId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_question_detail"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchQuestionDetailResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchQuestionDetailResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, innerResponse.question);
                                           });
                                       }
                                   }];
}

- (void)fetchQuestionAnswersWithQuestionId:(int64_t)questionId authorId:(int64_t)authorId userType:(TXPBUserType)userType
                                     maxId:(int64_t)maxId
                               onCompleted:(void (^)(NSError *error, NSArray/*<TXPBQuestionAnswer>*/ *answers, BOOL hasMore, NSArray/*<TXPBQuestionAnswer>*/ *expertAnswers, BOOL hasMoreExpertAnswers))onCompleted {
    TXPBFetchQuestionAnswersRequestBuilder *requestBuilder = [TXPBFetchQuestionAnswersRequest builder];
    if (questionId != 0) {
        requestBuilder.questionId = questionId;
    }
    if (authorId != 0) {
        requestBuilder.authorId = authorId;
    }
    if (userType != 0) {
        requestBuilder.userType = userType;
    }
    requestBuilder.maxId = maxId;
    requestBuilder.sinceId = 0;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_question_answers"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchQuestionAnswersResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchQuestionAnswersResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, innerResponse.answers, innerResponse.hasMore, innerResponse.expertAnswers, innerResponse.hasMoreExpertAnswer);
                                           });
                                       }
                                   }];
}

- (void)followQuestionWithQuestionId:(int64_t)questionId onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBFollowQuestionRequestBuilder *requestBuilder = [TXPBFollowQuestionRequest builder];
    requestBuilder.questionId = questionId;

    [[TXHttpClient sharedInstance] sendRequest:@"/follow_question"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

- (void)answerQuestionWithQuestionId:(int64_t)questionId content:(NSString *)content anonymous:(BOOL)anonymous
                            attaches:(NSArray/*<TXPBAttach>*/ *)attaches
                         onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBAnswerQuestionRequestBuilder *requestBuilder = [TXPBAnswerQuestionRequest builder];
    requestBuilder.questionId = questionId;
    requestBuilder.content = content;
    requestBuilder.anonymous = anonymous;
    [requestBuilder setAttachesArray:attaches];

    [[TXHttpClient sharedInstance] sendRequest:@"/answer_question"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

- (void)deleteQuestionAnswerWithAnswerId:(int64_t)answerId onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBDeleteQuestionAnswerRequestBuilder *requestBuilder = [TXPBDeleteQuestionAnswerRequest builder];
    requestBuilder.questionAnswerId = answerId;

    [[TXHttpClient sharedInstance] sendRequest:@"/delete_question_answer"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

- (void)fetchExpertsWithPageNum:(int64_t)pageNum onCompleted:(void (^)(NSError *error, NSArray/*<TXPBExpert>*/ *experts, BOOL hasMore))onCompleted {
    TXPBFetchExpertsRequestBuilder *requestBuilder = [TXPBFetchExpertsRequest builder];
    requestBuilder.pageNum=(int32_t)pageNum;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_experts"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchExpertsResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchExpertsResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, innerResponse.experts, innerResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)fetchRecommendExpertsWithCompleted:(void (^)(NSError *error, NSArray/*<TXPBExpert>*/ *experts))onCompleted {
    TXPBFetchRecommendExpertsRequestBuilder *requestBuilder = [TXPBFetchRecommendExpertsRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_recommend_experts"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchRecommendExpertsResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchRecommendExpertsResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, innerResponse.experts);
                                           });
                                       }
                                   }];
}

- (void)fetchExpertDetailsWithExpertId:(int64_t)expertId onCompleted:(void (^)(NSError *error, TXPBExpert *expert, NSArray/*<TXPBQuestionAnswer>*/ *answers, BOOL hasMoreAnswer, NSArray/*<TXPBKnowledge>*/ *knowledge, BOOL hasMoreKnowledge))onCompleted {
    TXPBFetchExpertRequestBuilder *requestBuilder = [TXPBFetchExpertRequest builder];
    requestBuilder.id = expertId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_expert"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchExpertResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchExpertResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, innerResponse.expert, innerResponse.answers, innerResponse.hasMoreAnswer, innerResponse.knowledges, innerResponse.hasMoreKnowledges);
                                           });
                                       }
                                   }];
}

- (void)followExpertWithExpertId:(int64_t)expertId isFollow:(BOOL)isFollow onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBFollowExpertRequestBuilder *requestBuilder = [TXPBFollowExpertRequest builder];
    requestBuilder.expertId = expertId;
    requestBuilder.isFollow = isFollow;

    [[TXHttpClient sharedInstance] sendRequest:@"/follow_expert"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

- (void)fetchHotKnowledgesWihtPageNum:(int32_t)pageNum onCompleted:(void (^)(NSError *error, NSArray/*<TXPBKnowledge>*/ *knowledge, BOOL hasMore))onCompleted {
    TXPBFetchHotKnowledgesRequestBuilder *requestBuilder = [TXPBFetchHotKnowledgesRequest builder];
    requestBuilder.pageNum = pageNum;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_hot_knowledges"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchHotKnowlegdesResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchHotKnowlegdesResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, innerResponse.knowledges, innerResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)fetchKnowledgesWithTagId:(int64_t)tagId auhtorId:(int64_t)authorId maxId:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray/*<TXPBKnowledge>*/ *knowledge, BOOL hasMore))onCompleted {
    TXPBFetchKnowledgesRequestBuilder *requestBuilder = [TXPBFetchKnowledgesRequest builder];
    if (tagId != 0) {
        requestBuilder.tagId = tagId;
    }
    if (authorId != 0) {
        requestBuilder.authorId = authorId;
    }
    requestBuilder.maxId = maxId;
    requestBuilder.sinceId = 0;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_knowledges"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchKnowledgesResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchKnowledgesResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, innerResponse.knowledges, innerResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)fetchKnowledgeWithKnowledgeId:(int64_t)knowledgeId onCompleted:(void (^)(NSError *error, TXPBKnowledge *knowledge))onCompleted {
    TXPBFetchKnowledgeDetailRequestBuilder *requestBuilder = [TXPBFetchKnowledgeDetailRequest builder];
    requestBuilder.knowledgeId = knowledgeId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_knowledge_detail"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchKnowledgeDetailResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchKnowledgeDetailResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, innerResponse.knowledge);
                                           });
                                       }
                                   }];
}

- (void)favoriteKnowledgeWithKnowledgeId:(int64_t)knowledgeId isFavorate:(BOOL)isFavorite onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBFavoriteKnowledgeRequestBuilder *requestBuilder = [TXPBFavoriteKnowledgeRequest builder];
    requestBuilder.knowledgeId = knowledgeId;

    [[TXHttpClient sharedInstance] sendRequest:@"/favorite_knowledge"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

-(void)fetchCommunionMessagesWithMaxId:(int64_t)maxId
                           onCompleted:(void (^)(NSError *error,NSArray/*<TXPBCommunionMessage>*/ *communionMessages,BOOL hasMore))onCompleted{
    TXPBFetchCommunionMessageRequestBuilder *requestBuilder = [TXPBFetchCommunionMessageRequest builder];
    requestBuilder.maxId=maxId;
    requestBuilder.sinceId=0;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_communion_message"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchCommunionMessageResponse *innerResponse;
                                       
                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchCommunionMessageResponse, innerResponse);
                                       
                                   completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError,innerResponse.msgs,innerResponse.hasMore);
                                           });
                                       }
                                   }];
}
@end
