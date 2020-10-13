//
//  TransImageTool.m
//  图片操作
//
//  Created by LUOSU on 2019/2/13.
//  Copyright © 2019 LUOSU. All rights reserved.
//

#import "TransImageTool.h"

#define kSCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define kSCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)
#define kMaxZoom 3

@interface TransImageTool ()<UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) BOOL isTwiceTaping;
@property (nonatomic, assign) BOOL isDoubleTapingForZoom;
@property (nonatomic, assign) CGFloat currentScale;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) CGFloat touchX;
@property (nonatomic, assign) CGFloat touchY;

@property (nonatomic, strong) UIImageView *transImageView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *userBtn ;
@property (nonatomic, strong) UIView *userBtnContainer ;




@end

static CGRect oldframe;

@implementation TransImageTool

- (void)showImage:(UIImageView *)avatarImageView{
    
    UIImage *image = avatarImageView.image;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    oldframe = [avatarImageView convertRect:avatarImageView.bounds toView:window];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:oldframe];
    imageView.image = image;
    
    self.transImageView = imageView;
 
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
    
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.maximumZoomScale = 5.0;
    
    CGFloat ratio = _width / _height * kSCREEN_HEIGHT / kSCREEN_WIDTH;
    CGFloat min = MIN(ratio, 1.0);
    scrollView.minimumZoomScale = min;
    
    self.scrollView = scrollView;
    
    UITapGestureRecognizer *onetap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    
    [self.scrollView addGestureRecognizer:onetap];
    [self.scrollView addSubview:imageView];
    
    
    UITapGestureRecognizer *tapImgViewTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgViewHandleTwice:)];
    tapImgViewTwice.numberOfTapsRequired = 2;
    tapImgViewTwice.numberOfTouchesRequired = 1;
    
    [scrollView addGestureRecognizer:tapImgViewTwice];
    //如果双击失败就单击
    [onetap requireGestureRecognizerToFail:tapImgViewTwice];
    
    [window addSubview:self.scrollView];
    
    CGFloat imageViewX = 0;
    CGFloat imageViewY = (kSCREEN_HEIGHT - image.size.height*kSCREEN_WIDTH/image.size.width) / 2;
    CGFloat imageViewW =  kSCREEN_WIDTH;
    CGFloat imageViewH = image.size.height * kSCREEN_WIDTH/image.size.width;
    
    [UIView animateWithDuration:0.3
                     animations:^
    {
        imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
                         
    }
    completion:^(BOOL finished)
    {
                         
    }];
    
    
}



- (void)hideImage:(UITapGestureRecognizer*)tap{
    
    UIView *backgroundView = tap.view;

    self.userBtnContainer.alpha = 0;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.transImageView.frame = oldframe;
                         self.scrollView.alpha = 0;
                         
                     } completion:^(BOOL finished) {
                         
                         [backgroundView removeFromSuperview];
                         [self.scrollView removeFromSuperview];
                         [self.userBtnContainer removeFromSuperview];
                         
                     }];
    
}

#pragma mark - UIScrollViewDelegate -

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    self.currentScale = scale;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.transImageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    CGFloat xcenter = scrollView.center.x;
    CGFloat ycenter = scrollView.center.y;

    xcenter = scrollView.contentSize.width > kSCREEN_WIDTH?scrollView.contentSize.width / 2 : xcenter;
    ycenter = scrollView.contentSize.height > kSCREEN_HEIGHT ?scrollView.contentSize.height / 2 : ycenter;
    
    if(_isDoubleTapingForZoom)//是否是双击放大的
    {
        if (_touchX>0 && _touchY>0)
        {
            //点击在图片上
            CGFloat transformX = _touchX * kMaxZoom;
            CGFloat transformY = _touchY * kMaxZoom;
            CGFloat contentW = scrollView.contentSize.width;
            CGFloat contentH = scrollView.contentSize.height;

            if (transformX + kSCREEN_WIDTH *.5>=contentW)
            {
                //右边太大。
                transformX = kSCREEN_WIDTH*(kMaxZoom-1);
            }
            else
            {
                if (transformX-kSCREEN_WIDTH *.5 < 0)
                {//左边太小
                    transformX = 0;
                }
                else
                {
                    transformX = transformX-kSCREEN_WIDTH *0.5;
                }
            }
            //计算Y
            //Y的放大比例跟图片的本身有关，需要从新计算内容的高度和屏幕的尺寸关系

            int maxCount = contentH /([UIScreen mainScreen].bounds.size.height);
            
            if (maxCount >= 1)
            {
                //智能移动到中心
                if (transformY-contentH *0.5 < 0)
                {
                    //上边太小，智能移动到边界
                    transformY = 0;
                }
                else
                {
                    
                    if (transformY +kSCREEN_HEIGHT *.5 > contentH) {
                       //下边太大，智能移动到边界
                        transformY = contentH - kSCREEN_HEIGHT;
                    }
                    else
                    {
                        transformY = transformY - kSCREEN_HEIGHT *.5;

                    }
                    
                }
            }
            else
            {
                if (transformY-contentH *0.5 < 0)
                {
                    //上边太小，智能移动到边界
                    transformY = 0;
                }
                else
                {
                    //下边太大，智能移动到边界
                    transformY = ycenter - kSCREEN_HEIGHT*0.5;
                }
            }
            
            [scrollView setContentOffset:CGPointMake(transformX, transformY)];
        }
        else
        {
        //默认放大位置
          [scrollView setContentOffset:CGPointMake(xcenter- kSCREEN_WIDTH *.5, ycenter - kSCREEN_HEIGHT*0.5)];
        }
        
    }
   [self.transImageView setCenter:CGPointMake(xcenter, ycenter)];
    _touchY = 0;
    _touchX = 0;
}

-(void)tapImgViewHandleTwice:(UIGestureRecognizer *)sender{
    
    _touchX = [sender locationInView:self.transImageView].x;
    _touchY = [sender locationInView:self.transImageView].y;
    
    if (_touchY >CGRectGetHeight(self.transImageView.frame))
    {
        //如果大于最大的就是在图片外面，默认放大
        _touchY = 0;
    }
 
    if(_isTwiceTaping)//双击
    {
        return;
    }
    _isTwiceTaping = YES;
    
    
    if(_currentScale > 1.0)
    {
        _currentScale = 1.0;
        [_scrollView setZoomScale:1.0 animated:YES];
    }
    else
    {
        _isDoubleTapingForZoom = YES;
        _currentScale = kMaxZoom;
        [_scrollView setZoomScale:kMaxZoom animated:YES];
    }
    _isDoubleTapingForZoom = NO;
    //延时做标记判断，使用户点击3次时的单击效果不生效。
    [self performSelector:@selector(twiceTaping) withObject:nil afterDelay:0.65];
}

-(void)twiceTaping{

    _isTwiceTaping = NO;
}

//是否添加其他按钮
- (void)addTooBtnView
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kSCREEN_WIDTH, 80)];
    containerView.backgroundColor = [UIColor clearColor];
    self.userBtnContainer = containerView;
    // [window addSubview:containerView];
    /*添加button*/
    UIButton *userBtnright = [UIButton buttonWithType:UIButtonTypeSystem];
    userBtnright.frame =CGRectMake(kSCREEN_WIDTH - 100, 0, 60, 30);
    [userBtnright setTitle:@"正确" forState:UIControlStateNormal];
    [userBtnright setBackgroundColor:[UIColor blueColor]];
    self.userBtn = userBtnright;
    //[containerView addSubview:userBtnright];
    /*添加button*/
    UIButton *userBtnerror = [UIButton buttonWithType:UIButtonTypeSystem];
    userBtnerror.frame =CGRectMake(kSCREEN_WIDTH - 170, 0, 60, 30);
    [userBtnerror setTitle:@"错误" forState:UIControlStateNormal];
    [userBtnerror setBackgroundColor:[UIColor blueColor]];
    self.userBtn = userBtnerror;
    //[containerView addSubview:userBtnerror];
}

@end
