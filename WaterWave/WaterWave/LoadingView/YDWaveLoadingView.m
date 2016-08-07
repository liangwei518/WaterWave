//
//  YDWaveLoadingView.m
//  WaterWave
//
//  Created by liangwei on 16/7/8.
//  Copyright © 2016年 liangwei. All rights reserved.
//

#import "YDWaveLoadingView.h"

typedef NS_ENUM(NSInteger, YDWavePathType) {
    YDWavePathType_Sin,
    YDWavePathType_Cos
};

@interface YDWaveLoadingView ()

@property (nonatomic, assign) CGFloat frequency;
@property (nonatomic, strong) UIImageView *grayImageView;
@property (nonatomic, strong) UIImageView *sineImageView;
@property (nonatomic, strong) UIImageView *cosineImageView;
@property (nonatomic, strong) CAShapeLayer *waveSinLayer;
@property (nonatomic, strong) CAShapeLayer *waveCosLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
//波浪相关的参数
@property (nonatomic, assign) CGFloat waveWidth;
@property (nonatomic, assign) CGFloat waveHeight;
@property (nonatomic, assign) CGFloat waveMid;
@property (nonatomic, assign) CGFloat maxAmplitude;

@property (nonatomic, assign) CGFloat phaseShift;
@property (nonatomic, assign) CGFloat phase;

@end

static CGFloat kWavePositionDuration = 5;

@implementation YDWaveLoadingView

+ (instancetype)loadingView
{
    return [[YDWaveLoadingView alloc] initWithFrame:CGRectMake(0, 0, 40, 31)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(40, 31);
}

#pragma mark - Public Methods
- (void)startLoading
{
    [_displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(updateWave:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSRunLoopCommonModes];
    CGPoint position = self.waveSinLayer.position;
    position.y = position.y - self.bounds.size.height - 10;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:self.waveSinLayer.position];
    animation.toValue = [NSValue valueWithCGPoint:position];
    animation.duration = kWavePositionDuration;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    [self.waveSinLayer addAnimation:animation forKey:@"positionWave"];
    [self.waveCosLayer addAnimation:animation forKey:@"positionWave"];
}

- (void)stopLoading
{
    [self.displayLink invalidate];
    [self.waveSinLayer removeAllAnimations];
    [self.waveCosLayer removeAllAnimations];
    self.waveSinLayer.path = nil;
    self.waveCosLayer.path = nil;
}

#pragma mark - Private Methods
- (void)setupSubViews
{
    self.waveSinLayer = [CAShapeLayer layer];
    _waveSinLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.waveSinLayer.fillColor = [[UIColor greenColor] CGColor];
    self.waveSinLayer.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
    
    self.waveCosLayer = [CAShapeLayer layer];
    _waveCosLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.waveCosLayer.fillColor = [[UIColor blueColor] CGColor];
    self.waveCosLayer.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
    
    self.waveHeight = CGRectGetHeight(self.bounds) * 0.5;
    self.waveWidth  = CGRectGetWidth(self.bounds);
    self.frequency = .3;
    self.phaseShift = 8;
    self.waveMid = self.waveWidth / 2.0f;
    self.maxAmplitude = self.waveHeight * .3;
    
    _grayImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _grayImageView.image = [UIImage imageNamed:@"du.png"];
    [self addSubview:_grayImageView];
    
    _cosineImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _cosineImageView.image = [UIImage imageNamed:@"gray.png"];
    [self addSubview:_cosineImageView];
    
    _sineImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _sineImageView.image = [UIImage imageNamed:@"blue.png"];
    [self addSubview:_sineImageView];
    
    _sineImageView.layer.mask = _waveSinLayer;
    _cosineImageView.layer.mask = _waveCosLayer;
}

- (void)updateWave:(CADisplayLink *)displayLink
{
    self.phase += self.phaseShift;
    self.waveSinLayer.path = [self createWavePathWithType:YDWavePathType_Sin].CGPath;
    self.waveCosLayer.path = [self createWavePathWithType:YDWavePathType_Cos].CGPath;
}

- (UIBezierPath *)createWavePathWithType:(YDWavePathType)pathType
{
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
    CGFloat endX = 0;
    for (CGFloat x = 0; x < self.waveWidth + 1; x += 1) {
        endX=x;
        CGFloat y = 0;
        if (pathType == YDWavePathType_Sin) {
            y = self.maxAmplitude * sinf(360.0 / _waveWidth * (x  * M_PI / 180) * self.frequency + self.phase * M_PI/ 180) + self.maxAmplitude;
        } else {
            y = self.maxAmplitude * cosf(360.0 / _waveWidth *(x  * M_PI / 180) * self.frequency + self.phase * M_PI/ 180) + self.maxAmplitude;
        }
        
        if (x == 0) {
            [wavePath moveToPoint:CGPointMake(x, y)];
        } else {
            [wavePath addLineToPoint:CGPointMake(x, y)];
        }
    }
    
    CGFloat endY = CGRectGetHeight(self.bounds) + 10;
    [wavePath addLineToPoint:CGPointMake(endX, endY)];
    [wavePath addLineToPoint:CGPointMake(0, endY)];
    
    return wavePath;
}

@end
