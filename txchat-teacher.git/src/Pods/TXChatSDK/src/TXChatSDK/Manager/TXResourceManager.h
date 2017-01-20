//
// Created by lingqingwan on 1/7/16.
// Copyright (c) 2016 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatManagerBase.h"
#import "TXPBResource.pb.h"

@interface TXResourceManager : TXChatManagerBase

/**
 * 获取banner图片
 
 */
- (void)fetchResourceBannersWithCompleted:(void (^)(NSError *error, NSArray *banners))onCompleted;

/**
 * 获取分类
 */
- (void)fetchResourceCategoriesWithCompleted:(void (^)(NSError *error, NSArray *categories))onCompleted;

/**
 * 获取首页上的资源列表
 */
- (void)fetchHomePageResourcesWithCompleted:(void (^)(NSError *error, NSArray *hot, NSArray *latest, NSArray *recommended, NSArray *providers))onCompleted;

/**
 * 获取热门资源
 */
- (void)fetchHotResourcesWithPage:(int32_t)page
                      onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted;

/**
 * 获取推荐资源
 */
- (void)fetchRecommendedResourcesWithPage:(int32_t)page
                              onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted;

/**
 * 分页获取资源列表
 */
- (void)fetchResourcesWithMaxId:(int64_t)maxId
                    onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted;

/**
 * 获取资源提供商
 */
- (void)fetchProvidersWithMaxId:(int64_t)maxId
                    onCompleted:(void (^)(NSError *error, NSArray *providers, BOOL hasMore))onCompleted;


- (void)fetchProvidersByUpdateWithPage:(int32_t)page
                           onCompleted:(void (^)(NSError *error, NSArray *providers, BOOL hasMore))onCompleted;

- (void)fetchPlayHistoryWithPage:(int32_t)page
                     onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted;

- (void)fetchSearchKeywordsWithCompleted:(void (^)(NSError *error, NSArray *hot, NSArray *recommended))onCompleted;

- (void)searchResourcesWithKeyword:(NSString *)keyword
                              page:(int32_t)page
                          category:(TXPBSearchResultCategory)category
                       onCompleted:(void (^)(NSError *error, NSArray *albums, NSArray *resources, NSArray *providers, NSArray *combinedObjects, TXPBSearchResultCategory cate, BOOL hasMore))onCompleted;

- (void)fetchAlbumsWithCategoryId:(int64_t)categoryId
                            maxId:(int64_t)maxId
                      onCompleted:(void (^)(NSError *error, NSArray *albums, BOOL hasMore))onCompleted;

- (void)fetchResourceWithCategoryId:(int64_t)categoryId
                              maxId:(int64_t)maxId
                        onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted;

- (void)fetchAlbumsWithProviderId:(int64_t)providerId
                            maxId:(int64_t)maxId
                      onCompleted:(void (^)(NSError *error, NSArray *albums, BOOL hasMore))onCompleted;

- (void)fetchResourceWithProviderId:(int64_t)providerId
                              maxId:(int64_t)maxId
                        onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted;

- (void)fetchResourceWithAlbumId:(int64_t)albumId
                            page:(int32_t)page
                     onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted;

- (void)fetchNextResourceWithResourceId:(int64_t)resourceId
                             isPlayList:(BOOL)isPlayList
                            onCompleted:(void (^)(NSError *error, TXPBResource *resource, BOOL isLast))onCompleted;

- (void)fetchPreviousResourceWithResourceId:(int64_t)resourceId
                                 isPlayList:(BOOL)isPlayList
                                onCompleted:(void (^)(NSError *error, TXPBResource *resource, BOOL isLast))onCompleted;

- (void)fetchNearResourcesWithCurrentResourceId:(int64_t)currentResourceId
                                          count:(int32_t)count
                                        forward:(BOOL)forward
                                    onCompleted:(void (^)(NSError *error, NSArray *resources, BOOL hasMore))onCompleted;

- (void)fetchResourcePicturesWithResourceId:(int64_t)resourceId
                                onCompleted:(void (^)(NSError *error, NSArray *pictures))onCompleted;

- (void)fetchResourceWithResourceId:(int64_t)resourceId
                        onCompleted:(void (^)(NSError *error, TXPBResource *resource))onCompleted;

- (void)fetchAlbumWithAlbumId:(int64_t)albumId
                  onCompleted:(void (^)(NSError *error, TXPBAlbum *album))onCompleted;

- (void)fetchProviderWithProviderId:(int64_t)providerId
                        onCompleted:(void (^)(NSError *error, TXPBProvider *provider))onCompleted;

- (void)playResourceWithResourceId:(int64_t)resourceId
                       onCompleted:(void (^)(NSError *error))onCompleted;
@end