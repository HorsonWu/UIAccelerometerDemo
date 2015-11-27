//
//  ViewController.m
//  UIAccelerometerDemo
//
//  Created by HorsonWu on 15/11/24.
//  Copyright © 2015年 elovega. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
@interface ViewController ()<UIAlertViewDelegate>
{
    //数据滤波后的数值
    UIAccelerationValue filteredAccelX;
    UIAccelerationValue filteredAccelY;
    UIAccelerationValue filteredAccelZ;
}
@property (strong ,nonatomic)CMMotionManager *motionManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self accelerometerOfCoreMotionType];
//    [self gyroOfCoreMotionType];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
//    [self getTheDeviceOrientation];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
//    [self removeNotificationOfGetDeviceOrientation];
//    [self resignFirstResponder];
    
    
//    [self.motionManager stopGyroUpdates];
//    [self.motionManager stopAccelerometerUpdates];
//    [self.motionManager stopDeviceMotionUpdates];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
//    [self becomeFirstResponder];
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}
#pragma mark -------------------------------- 加速度计 -------------------------------
//以CoreMotion方式获取加速度计的参数 (ios 5系统以后)
-(void)accelerometerOfCoreMotionType{
    self.motionManager = [CMMotionManager new];
    self.motionManager.accelerometerUpdateInterval = 0.1;
    [self startShake];
}

//- (void)alertViewCancel:(UIAlertView *)alertView{
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self startShake];

    }
}
-(void)startShake{
    if ([self.motionManager isAccelerometerAvailable]) {
        [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init]
                                                 withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
                                                     if (error) {
                                                         
                                                         [self.motionManager stopAccelerometerUpdates];
                                                     }
                                                     else
                                                         
                                                     {
                                                         
                                                         //综合3个方向的加速度
                                                         double accelerameter =sqrt( pow(accelerometerData.acceleration.x , 2 ) + pow(accelerometerData.acceleration.y , 2 ) + pow(accelerometerData.acceleration.z , 2) );
                                                         //当综合加速度大于2.3时，就激活效果（此数值根据需求可以调整，数据越小，用户摇动的动作就越小，越容易激活，反之加大难度，但不容易误触发）
                                                         if (accelerameter>2.3f) {
                                                             //立即停止更新加速仪（很重要！）
                                                             
                                                             
                                                             NSLog(@"hahahaha......");
                                                             
                                                             [self.motionManager stopAccelerometerUpdates];
                                                             
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 //UI线程必须在此block内执行，例如摇一摇动画、UIAlertView之类
                                                                 
                                                                 UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:@"摇到个人头" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                                 
                                                                 [alertView show];
                                                                 
                                                             });
                                                         }
                                                         
                                                         //                                                         NSLog(@"x = %f,y = %f,z = %f",accelerometerData.acceleration.x, accelerometerData.acceleration.y,accelerometerData.acceleration.z);
                                                         
                                                         
                                                     }
                                                 }];
    }

}

//感知设备方向
-(void)getTheDeviceOrientation{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedRotation:) name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}
-(void)receivedRotation:(NSNotification *)notification{
    UIDevice *device = [UIDevice currentDevice];
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
            NSLog(@"竖直向上");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"竖直向下");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"水平向左");
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"水平向右");
            break;
        case UIDeviceOrientationFaceUp:
            NSLog(@"面朝上");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"面朝下");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知");
            break;
        default:
            NSLog(@"未知");
            break;
    }
}

-(void)removeNotificationOfGetDeviceOrientation{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


#pragma mark -------------------------------- 陀螺仪 -------------------------------

-(void)gyroOfCoreMotionType{
    self.motionManager = [CMMotionManager new];
    self.motionManager.accelerometerUpdateInterval = 0.1;
    if ([self.motionManager isGyroAvailable]) {
        [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            if (error) {
                [self.motionManager stopGyroUpdates];
            }
            else
            {
                CMRotationRate rotate = gyroData.rotationRate;
                NSLog(@"x = %f,y = %f,z = %f",rotate.x, rotate.y,rotate.z);
                CGFloat x =  [self calculatehighPassFilteredDataWithNewAcceleration:filteredAccelX andPreviousValue:rotate.x];
                CGFloat y =  [self calculatehighPassFilteredDataWithNewAcceleration:filteredAccelX andPreviousValue:rotate.y];
                CGFloat z =  [self calculatehighPassFilteredDataWithNewAcceleration:filteredAccelX andPreviousValue:rotate.z];
                filteredAccelX = x;
                filteredAccelY = y;
                filteredAccelZ = z;
                
                 NSLog(@"filteredAccelX = %f,filteredAccelY = %f,filteredAccelZ = %f",filteredAccelX, filteredAccelY,filteredAccelZ);
            }
        }];
    }
    
}


#pragma mark -------------------------------- 数据滤波的处理 -------------------------------
//低通滤波计算  目的:找出设备的方向
-(CGFloat)calculateLowPassFilteredDataWithNewAcceleration:(CGFloat)newAcceleration andPreviousValue:(CGFloat)previousValue{
    CGFloat lowPassFiltered = (newAcceleration * 0.1)+ previousValue * (1.0 - 0.1);
    return lowPassFiltered;
}

//高通滤波计算  目的:检测用户的移动
-(CGFloat)calculatehighPassFilteredDataWithNewAcceleration:(CGFloat)newAcceleration andPreviousValue:(CGFloat)previousValue{
    CGFloat highPassFiltered = newAcceleration - (newAcceleration * 0.1)+ previousValue * (1.0 - 0.1);
    return highPassFiltered;
}


#pragma mark -------------------------------- 晃动检测的处理 -------------------------------

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"晃动开始");
    }
}
-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"晃动取消");
    }
}
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"晃动结束");
    }
}

#pragma mark ----------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
