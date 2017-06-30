//
//  ViewController.m
//  AccelerometerAndGyro
//
//  Created by 王盛魁 on 2017/6/29.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()
@property (nonatomic,strong) CMMotionManager *motionManager;
@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation ViewController
- (CMMotionManager *)motionManager{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc]init];
    }
    return _motionManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.imageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    self.imageView.image = [UIImage imageNamed:@"arrow.jpg"];
    [self.view addSubview:self.imageView];
    // 测试 加速计push方式获取数据
//    [self testAccelerometerPush];
    
    // 测试 加速计pull方式获取数据
//    [self testAccelerometerPull];
    
    // 测试 陀螺仪push方式获取数据
//    [self testGyro];
    
    // 测试 push方式获取设备motion数据
//    [self testDeviceMotion1];
    
    [self testDeviceMotion2];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - 测试加速计
- (void)testAccelerometerPull{
    if ([self.motionManager isAccelerometerAvailable]) {
        if ([self.motionManager isAccelerometerActive]) {
            [self.motionManager setAccelerometerUpdateInterval:1/60.0];
            [self.motionManager startAccelerometerUpdates];
        }
        CMAccelerometerData *accelerometerData = self.motionManager.accelerometerData;
        NSLog(@"acceleration_X:%.2f",accelerometerData.acceleration.x);
        NSLog(@"acceleration_Y:%.2f",accelerometerData.acceleration.y);
        NSLog(@"acceleration_Z:%.2f",accelerometerData.acceleration.z);
    } else {
        NSLog(@">>加速计不可用");
    }
}
- (void)testAccelerometerPush{
    //判断加速计是否可用
    if ([self.motionManager isAccelerometerAvailable]) {
        // 设置加速计采样频率
        [self.motionManager setAccelerometerUpdateInterval:1/60.0];
        __weak typeof(self) weakself = self;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"acceleration_X:%.2f",accelerometerData.acceleration.x);
                NSLog(@"acceleration_Y:%.2f",accelerometerData.acceleration.y);
                NSLog(@"acceleration_Z:%.2f",accelerometerData.acceleration.z);
            }else{
                [weakself.motionManager stopAccelerometerUpdates];
            }
        }];
    } else {
        NSLog(@">>加速计不可用");
    }
}
#pragma mark - 测试陀螺仪(push方式获取数据)
- (void)testGyro{
    if ([self.motionManager isGyroAvailable]) {
        [self.motionManager setGyroUpdateInterval:1/60];
        __weak typeof(self) weakself = self;
        [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"rotationRate_X:%.2f",gyroData.rotationRate.x);
                NSLog(@"rotationRate_Y:%.2f",gyroData.rotationRate.y);
                NSLog(@"rotationRate_Z:%.2f",gyroData.rotationRate.z);
            }else{
                [weakself.motionManager stopAccelerometerUpdates];
            }
        }];
    }else{
        NSLog(@">>陀螺仪不可用");
    }
}
#pragma mark - testDeviceMotion
- (void)testDeviceMotion1{
    if ([self.motionManager isDeviceMotionAvailable]) {
        [self.motionManager setDeviceMotionUpdateInterval:1/60];
        
        __weak typeof(self) weakSelf = self;
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]withHandler:^(CMDeviceMotion * _Nullable motion,NSError * _Nullable error) {
            if (!error) {
                //获取这个然后使用这个角度进行view旋转，可以实现view保持水平的效果，设置一个图片可以测试
                double rotation = atan2(motion.gravity.x, motion.gravity.y) - M_PI;
                weakSelf.imageView.transform = CGAffineTransformMakeRotation(rotation);

                //2. Gravity 获取手机的重力值在各个方向上的分量，根据这个就可以获得手机的空间位置，倾斜角度等
                double gravityX = motion.gravity.x;
                double gravityY = motion.gravity.y;
                double gravityZ = motion.gravity.z;
                
                //获取手机的倾斜角度(zTheta是手机与水平面的夹角， xyTheta是手机绕自身旋转的角度)：
                double zTheta = atan2(gravityZ,sqrtf(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0;
                double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;
                NSLog(@"%f ====== %f",zTheta,xyTheta);
            }else{
                [weakSelf.motionManager stopDeviceMotionUpdates];
            }
        }];
    }
}
- (void)testDeviceMotion2{
    if ([self.motionManager isDeviceMotionAvailable]) {
        [self.motionManager setDeviceMotionUpdateInterval:1/60];
        
        __weak typeof(self) weakSelf = self;
        // CMAttitudeReferenceFrame：参考系
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            if (!error) {
                //获取这个然后使用这个角度进行view旋转，可以实现view保持水平的效果，设置一个图片可以测试
                double rotation = atan2(motion.gravity.x, motion.gravity.y) - M_PI;
                weakSelf.imageView.transform = CGAffineTransformMakeRotation(rotation);
                
                //2. Gravity 获取手机的重力值在各个方向上的分量，根据这个就可以获得手机的空间位置，倾斜角度等
                double gravityX = motion.gravity.x;
                double gravityY = motion.gravity.y;
                double gravityZ = motion.gravity.z;
                
                //获取手机的倾斜角度(zTheta是手机与水平面的夹角， xyTheta是手机绕自身旋转的角度)：
                double zTheta = atan2(gravityZ,sqrtf(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0;
                double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;
                                NSLog(@"%f ====== %f",zTheta,xyTheta);
            }else{
                [weakSelf.motionManager stopDeviceMotionUpdates];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}


@end
