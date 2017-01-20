//
// Created by lingqingwan on 1/7/16.
// Copyright (c) 2016 lingiqngwan. All rights reserved.
//

#import "TXResourceManager.h"
#import "TXApplicationManager.h"

@implementation TXResourceManager {

}
- (void)fetchResourceBannersWithCompleted:(void (^)(NSError *error, NSArray *banners))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    TXPBGetResourceBannersRequestBuilder *requestBuilder = [TXPBGetResourceBannersRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/get_resource_banners"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBGetResourceBannersResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBGetResourceBannersResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.banners);
                                           )
                                       }
                                   }];
}

- (void)fetchResourceCategoriesWithCompleted:(void (^)(NSError *error, NSArray *categories))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    TXPBGetResourceCategoryRequestBuilder *requestBuilder = [TXPBGetResourceCategoryRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/get_resource_category"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBGetResourceCategoryResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBGetResourceCategoryResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.catogories);
                                           );
                                       }
                                   }];
}

- (void)fetchHomePageResourcesWithCompleted:(void (^)(NSError *error, NSArray *hot, NSArray *latest, NSArray *recommended, NSArray *providers))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    TXPBFetchHomePageResourcesRequestBuilder *requestBuilder = [TXPBFetchHomePageResourcesRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_home_page_resources"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchHomePageResourcesResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchHomePageResourcesResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.hot, innerResponse.latest, innerResponse.recommended, innerResponse.providers);
                                           );
                                       }
                                   }];
}

- (void)fetchHotResourcesWithPage:(int32_t)page onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s page=%lld", __FUNCTION__, page);

    TXPBFetchHotResourceRequestBuilder *requestBuilder = [TXPBFetchHotResourceRequest builder];
    requestBuilder.page = page;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_hot_resource"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchHotResourceResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchHotResourceResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.resources, innerResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchRecommendedResourcesWithPage:(int32_t)page onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s page=%lld", __FUNCTION__, page);

    TXPBFetchRecommendedResourceRequestBuilder *requestBuilder = [TXPBFetchRecommendedResourceRequest builder];
    requestBuilder.page = page;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_recommended_resource"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchRecommendedResourceResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchRecommendedResourceResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.resources, innerResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchResourcesWithMaxId:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s maxId=%lld", __FUNCTION__, maxId);

    TXPBFetchResourceRequestBuilder *requestBuilder = [TXPBFetchResourceRequest builder];
    requestBuilder.sinceId = 0;
    requestBuilder.maxId = maxId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_resource"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchResourceResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchResourceResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.resources, innerResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchProvidersWithMaxId:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *providers, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s maxId=%lld", __FUNCTION__, maxId);

    TXPBFetchProviderRequestBuilder *requestBuilder = [TXPBFetchProviderRequest builder];
    requestBuilder.sinceId = 0;
    requestBuilder.maxId = maxId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_provider"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchProviderResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchProviderResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.provides, innerResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchProvidersByUpdateWithPage:(int32_t)page onCompleted:(void (^)(NSError *error, NSArray *providers, BOOL hasMore))onCompleted {
    TXPBFetchProviderByUpdateRequestBuilder *requestBuilder = [TXPBFetchProviderByUpdateRequest builder];
    requestBuilder.page = page;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_provider_by_update"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchProviderByUpdateResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchProviderByUpdateResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.provides, innerResponse.hasMore);
                                           );
                                       }
                                   }];

}

- (void)fetchPlayHistoryWithPage:(int32_t)page onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted {
    TXPBFetchPlayHistoryRequestBuilder *requestBuilder = [TXPBFetchPlayHistoryRequest builder];
    requestBuilder.page = page;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_play_history"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchPlayHistoryResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchPlayHistoryResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.resources, innerResponse.hasMore);
                                           );
                                       }
                                   }];

}

- (void)fetchSearchKeywordsWithCompleted:(void (^)(NSError *error, NSArray *hot, NSArray *recommended))onCompleted {
    TXPBFetchSearchKeywordsRequestBuilder *requestBuilder = [TXPBFetchSearchKeywordsRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_search_keywords"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchSearchKeywordsResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchSearchKeywordsResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.hot, innerResponse.recommended);
                                           );
                                       }
                                   }];
}

- (void)searchResourcesWithKeyword:(NSString *)keyword
                              page:(int32_t)page
                          category:(TXPBSearchResultCategory)category
                       onCompleted:(void (^)(NSError *error, NSArray *albums, NSArray *resources, NSArray *providers, NSArray *combinedObjects, TXPBSearchResultCategory cate, BOOL hasMore))onCompleted {
    TXPBSearchResourceRequestBuilder *requestBuilder = [TXPBSearchResourceRequest builder];
    requestBuilder.keyword = keyword;
    requestBuilder.page = page;
    requestBuilder.category = category;

    [[TXHttpClient sharedInstance] sendRequest:@"/search_resource"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBSearchResourceResponse *innerResponse;
                                       NSMutableArray *combined;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBSearchResourceResponse, innerResponse);

                                       combined = [NSMutableArray array];
                                       if (innerResponse.albums) {
                                           [combined addObjectsFromArray:innerResponse.albums];
                                       }
                                       if (innerResponse.resources) {
                                           [combined addObjectsFromArray:innerResponse.resources];
                                       }
                                       if (innerResponse.providers) {
                                           [combined addObjectsFromArray:innerResponse.providers];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError,
                                                           innerResponse.albums,
                                                           innerResponse.resources,
                                                           innerResponse.providers,
                                                           combined,
                                                           category,
                                                           innerResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchAlbumsWithCategoryId:(int64_t)categoryId maxId:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *albums, BOOL hasMore))onCompleted {
    TXPBFetchAlbumByCategoryRequestBuilder *requestBuilder = [TXPBFetchAlbumByCategoryRequest builder];
    requestBuilder.sinceId = 0;
    requestBuilder.maxId = maxId;
    requestBuilder.categoryId = categoryId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_album_by_category"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchAlbumByCategoryResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchAlbumByCategoryResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.albums, innerResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchResourceWithCategoryId:(int64_t)categoryId maxId:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted {
    TXPBFetchResourceByCategoryRequestBuilder *requestBuilder = [TXPBFetchResourceByCategoryRequest builder];
    requestBuilder.sinceId = 0;
    requestBuilder.maxId = maxId;
    requestBuilder.categoryId = categoryId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_resource_by_category"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchResourceByCategoryResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchResourceByCategoryResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.resources, innerResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchAlbumsWithProviderId:(int64_t)providerId maxId:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *albums, BOOL hasMore))onCompleted {
    TXPBFetchAlbumByProviderRequestBuilder *requestBuilder = [TXPBFetchAlbumByProviderRequest builder];
    requestBuilder.sinceId = 0;
    requestBuilder.maxId = maxId;
    requestBuilder.providerId = providerId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_album_by_provider"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchAlbumByProviderResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchAlbumByProviderResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.albums, innerResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchResourceWithProviderId:(int64_t)providerId maxId:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted {
    TXPBFetchResourceByProviderRequestBuilder *requestBuilder = [TXPBFetchResourceByProviderRequest builder];
    requestBuilder.sinceId = 0;
    requestBuilder.maxId = maxId;
    requestBuilder.providerId = providerId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_resource_by_provider"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchResourceByProviderResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchResourceByProviderResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.resources, innerResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchResourceWithAlbumId:(int64_t)albumId page:(int32_t)page onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted {
    TXPBFetchResourceByAlbumRequestBuilder *requestBuilder = [TXPBFetchResourceByAlbumRequest builder];
    requestBuilder.page = page;
    requestBuilder.albumId = albumId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_resource_by_album"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchResourceByAlbumResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchResourceByAlbumResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.resources, innerResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchNextResourceWithResourceId:(int64_t)resourceId isPlayList:(BOOL)isPlayList onCompleted:(void (^)(NSError *error, TXPBResource *resource, BOOL isLast))onCompleted {
    TXPBPlayNextRequestBuilder *requestBuilder = [TXPBPlayNextRequest builder];
    requestBuilder.resourceId = resourceId;
    requestBuilder.isPlayList = isPlayList;

    [[TXHttpClient sharedInstance] sendRequest:@"/play_next"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBPlayNextResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBPlayNextResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.hasResource ? innerResponse.resource : nil, innerResponse.isLast);
                                           );
                                       }
                                   }];
}

- (void)fetchPreviousResourceWithResourceId:(int64_t)resourceId isPlayList:(BOOL)isPlayList onCompleted:(void (^)(NSError *error, TXPBResource *resource, BOOL isLast))onCompleted {
    TXPBPlayPreviousRequestBuilder *requestBuilder = [TXPBPlayPreviousRequest builder];
    requestBuilder.resourceId = resourceId;
    requestBuilder.isPlayList = isPlayList;

    [[TXHttpClient sharedInstance] sendRequest:@"/play_previous"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBPlayPreviousResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBPlayPreviousResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.hasResource ? innerResponse.resource : nil, innerResponse.isFirst);
                                           );
                                       }
                                   }];
}

- (void)fetchNearResourcesWithCurrentResourceId:(int64_t)currentResourceId count:(int32_t)count forward:(BOOL)forward onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted {
    TXPBFetchNearResourcesRequestBuilder *requestBuilder = [TXPBFetchNearResourcesRequest builder];
    requestBuilder.currentResourceId = currentResourceId;
    requestBuilder.count = count;
    requestBuilder.forward = forward;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_near_resources"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchNearResourcesResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchNearResourcesResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.resource, innerResponse.hasMore);
                                           );
                                       }
                                   }];
}


- (void)fetchResourcePicturesWithResourceId:(int64_t)resourceId onCompleted:(void (^)(NSError *error, NSArray *pictures))onCompleted {
    TXPBFetchResourcePicturesRequestBuilder *requestBuilder = [TXPBFetchResourcePicturesRequest builder];
    requestBuilder.resId = resourceId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_resource_pictures"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchResourcePicturesResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchResourcePicturesResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.pictures);
                                           );
                                       }
                                   }];
}

- (void)fetchResourceWithResourceId:(int64_t)resourceId onCompleted:(void (^)(NSError *error, TXPBResource *resource))onCompleted {
    TXPBFetchResourceByIdRequestBuilder *requestBuilder = [TXPBFetchResourceByIdRequest builder];
    requestBuilder.resId = resourceId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_resource_by_id"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchResourceByIdResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchResourceByIdResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.resource);
                                           );
                                       }
                                   }];
}

- (void)fetchAlbumWithAlbumId:(int64_t)albumId onCompleted:(void (^)(NSError *error, TXPBAlbum *album))onCompleted {
    TXPBFetchAlbumByIdRequestBuilder *requestBuilder = [TXPBFetchAlbumByIdRequest builder];
    requestBuilder.albumId = albumId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_album_by_id"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchAlbumByIdResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchAlbumByIdResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.album);
                                           );
                                       }
                                   }];
}

- (void)fetchProviderWithProviderId:(int64_t)providerId onCompleted:(void (^)(NSError *error, TXPBProvider *provider))onCompleted {
    TXPBFetchProviderByIdRequestBuilder *requestBuilder = [TXPBFetchProviderByIdRequest builder];
    requestBuilder.providerId = providerId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_provider_by_id"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchProviderByIdResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchProviderByIdResponse, innerResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.provider);
                                           );
                                       }
                                   }];
}


- (void)playResourceWithResourceId:(int64_t)resourceId onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBPlayResourceRequestBuilder *requestBuilder = [TXPBPlayResourceRequest builder];
    requestBuilder.resId = resourceId;

    [[TXHttpClient sharedInstance] sendRequest:@"/play_resource"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError);
                                           );
                                       }
                                   }];
}


@end