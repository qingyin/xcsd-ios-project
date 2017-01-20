//
//  uploadImageView.m
//  TXChat
//
//  Created by lyt on 15-6-29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "uploadImageView.h"
#import "DAProgressOverlayView.h"
@interface uploadImageView()
{
    UIImageView *_showImageView;//显示图片
    UIImageView *_delImageView;//删除图标
    UIView *_uploadingView;//上传图标
    UIView *_failedView;//失败图标
    UPLOADIMAGE_STATUS_T viewStatus;//当前状态
    BOOL _isShowDelImage;//有些图片不显示删除图标
    DAProgressOverlayView *_vProgress;//进度提醒
    
}
@property(nonatomic, strong)UIImage *showImage;//显示图片

@end


#define KINDICATORTAG 0x1000 //上传进度图标
@implementation uploadImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupViews];
    }
    return self;
}

-(id)initWithImage:(UIImage *)image isShowDelImage:(BOOL)isShowDelImage
{
    self = [super init];
    if(self)
    {
        _showImage = image;
        [_showImageView setImage:image];
        _isShowDelImage = isShowDelImage;
        if(!_isShowDelImage)
        {
            [_delImageView removeFromSuperview];
        }
    }
    return self;
}

-(void)setupViews
{
    //显示图片
    _showImageView = [UIImageView new];
    _showImageView.contentMode = UIViewContentModeScaleAspectFill;
    _showImageView.clipsToBounds = YES;
    [self addSubview:_showImageView];
    [_showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];


    
    //上传控件
    _uploadingView = [UIView new];
    [_uploadingView setAlpha:1.0f];
    [_uploadingView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_uploadingView];
    [_uploadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    _vProgress = [[DAProgressOverlayView alloc] init];
    _vProgress.userInteractionEnabled = NO;
    _vProgress.progress = 0.0;
    [_uploadingView addSubview:_vProgress];
    [_vProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [_uploadingView setHidden:YES];
    
    _failedView = [UIView new];
    [_failedView setBackgroundColor:[UIColor blackColor]];
    [_failedView setAlpha:0.8f];
    [self addSubview:_failedView];
    [_failedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UIImageView *failedImage = [UIImageView new];
    failedImage.contentMode = UIViewContentModeScaleAspectFill;
    [failedImage setImage:[UIImage imageNamed:@"chat_sendFail"]];
    
    [_failedView addSubview:failedImage];
    CGFloat margin = 5.0f;
    [failedImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).with.offset(margin);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    UILabel *failedText = [UILabel new];
    [failedText setText:@"失败"];
    [failedText setTextColor:kColorWhite];
    [failedText setFont:kFontSmall];
    [failedText setTextAlignment:NSTextAlignmentCenter];
    [_failedView addSubview:failedText];
    [failedText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).with.offset(margin);
        make.right.mas_equalTo(self).with.offset(-margin);
        make.top.mas_equalTo(failedImage).with.offset(margin);
        make.bottom.mas_equalTo(self).with.offset(margin);
    }];
    [_failedView setHidden:YES];
    
    //删除图片按钮
    _delImageView = [UIImageView new];
    [_delImageView setImage:[UIImage imageNamed:@"deteleIdentifier"]];
    CGFloat delWidth = _delImageView.image.size.width/2.0f;
    _delImageView.userInteractionEnabled = YES;
    [self addSubview:_delImageView];
    [_delImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).with.offset(-delWidth/2);
        make.right.mas_equalTo(self.mas_right).with.offset(+delWidth/2);
        make.size.mas_equalTo(_delImageView.image.size);
    }];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delTapEvent:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.cancelsTouchesInView = NO;
    self.userInteractionEnabled = YES;
    [_delImageView addGestureRecognizer:tap];
    [_delImageView setHidden:NO];
    
    viewStatus = UPLOADIMAGE_STATUS_NORMAL;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)delTapEvent:(UITapGestureRecognizer*)recognizer
{
    NSInteger index = self.tag ;
    DLog(@"tag:%ld", (long)index);
    if(_delegate && [_delegate respondsToSelector:@selector(delItem:)])
    {
        [_delegate delItem:index];
    }    
}



-(void)setImage:(UIImage *)image
{
    _showImage = image;
    [_showImageView setImage:image];
}
//更新view状态
-(void)updateViewStatus:(UPLOADIMAGE_STATUS_T)newStatus
{
    if(viewStatus != newStatus)
    {
        viewStatus = newStatus;
    }
    else
    {
        return;
    }
    
    switch (newStatus) {
        case UPLOADIMAGE_STATUS_NORMAL:
        {
            [_failedView setHidden:YES];
            [_uploadingView setHidden:YES];
            [_delImageView setHidden:NO];
        
        }
            break;
        case UPLOADIMAGE_STATUS_UPLOADING:
        {
            [_failedView setHidden:YES];
            [_uploadingView setHidden:NO];
            [_delImageView setHidden:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                _vProgress.progress = 0.0f;
            });
            
        }
            break;
        case UPLOADIMAGE_STATUS_FAILED:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _vProgress.progress = 0.0f;
            });
            [_failedView setHidden:NO];
            [_uploadingView setHidden:YES];
            [_delImageView setHidden:YES];

        }
            break;
        default:
            break;
    }

}
//获取当前状态
-(UPLOADIMAGE_STATUS_T)getCurrentStatus
{
    return viewStatus;
}

//更新进度 通知
-(void)updateUploadProcess:(CGFloat)process
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _vProgress.progress = process;
        [_vProgress setNeedsDisplay];
    });
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
