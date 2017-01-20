//
//  MediaTypeDetailView.h
//  TXChatParent
//
//  Created by lyt on 16/1/6.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaTypeDetailView : UIView
@property(nonatomic, strong)UIButton *iconBtnView;
@property(nonatomic, strong)UIImageView *typeImgView;
@property(nonatomic, strong)UILabel *contentLabel;
@property(nonatomic, assign)TXPBResourceType resourceType;
@end
