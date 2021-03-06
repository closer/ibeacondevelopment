//
//  ViewController.m
//  iBeaconSampleCentral
//
//  Created by kakegawa.atsushi on 2013/09/25.
//  Copyright (c) 2013年 kakegawa.atsushi. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) NSUUID *venderUUID;
@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6A"];
        
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                               identifier:@"com.otoshimono.testregion"];
//        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID major:0 minor:0 identifier:@"com.otoshimono.testregion"];
        self.beaconRegion.notifyOnEntry = YES;
        self.beaconRegion.notifyOnExit = YES;
        self.beaconRegion.notifyEntryStateOnDisplay = YES;
        
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    _venderUUID = [UIDevice currentDevice].identifierForVendor;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    
    CLLocation *location = [manager location];
    NSLog(@"%f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
    [self sendLocalNotificationForMessage:@"Start Monitoring Region"];
    NSLog(@"Start Monitoring Region");
    [self sendNSURLRequest:[
                            NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/%@/long/%f/lat/%f/horizontalAccuracy/%f/verticalAccuracy/%f",
                            _venderUUID.UUIDString,
                            @"startMonitroing",
                            location.coordinate.latitude,
                            location.coordinate.longitude,
                            location.horizontalAccuracy,
                            location.verticalAccuracy]];

    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    
    CLLocation *location = [manager location];
    NSLog(@"%f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
    switch (state) {
        case CLRegionStateInside: // リージョン内にいる
            [self sendLocalNotificationForMessage:@"I'm standing by you!!"];
            NSLog(@"I'm standing by you!!");
            [self sendNSURLRequest:[
                                    NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/%@/long/%f/lat/%f/horizontalAccuracy/%f/verticalAccuracy/%f",
                                    _venderUUID.UUIDString,
                                    @"inside",
                                    location.coordinate.latitude,
                                    location.coordinate.longitude,
                                    location.horizontalAccuracy,
                                    location.verticalAccuracy]];

            break;
        case CLRegionStateOutside:
            [self sendLocalNotificationForMessage:@"Where you are??"];
            NSLog(@"Where you are??");
            [self sendNSURLRequest:[
                                    NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/%@/long/%f/lat/%f/horizontalAccuracy/%f/verticalAccuracy/%f",
                                    _venderUUID.UUIDString,
                                    @"ousside",
                                    location.coordinate.latitude,
                                    location.coordinate.longitude,
                                    location.horizontalAccuracy,
                                    location.verticalAccuracy]];


            break;
        case CLRegionStateUnknown:
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Enter Region");
    
    CLLocation *location = [manager location];
    NSLog(@"%f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
    [self sendNSURLRequest:[
                            NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/%@/long/%f/lat/%f/horizontalAccuracy/%f/verticalAccuracy/%f",
                            _venderUUID.UUIDString,
                            @"enter",
                            location.coordinate.latitude,
                            location.coordinate.longitude,
                            location.horizontalAccuracy,
                            location.verticalAccuracy
                            ]];
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
    NSLog(@"Exit Region");
    
    CLLocation *location = [manager location];
    NSLog(@"%f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
    [self sendNSURLRequest:[
                            NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/%@/long/%f/lat/%f/horizontalAccuracy/%f/verticalAccuracy/%f",
                            _venderUUID.UUIDString,
                            @"exit",
                            location.coordinate.latitude,
                            location.coordinate.longitude,
                            location.horizontalAccuracy,
                            location.verticalAccuracy
                            ]];
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        
        CLLocation *location = [manager location];
        
        NSString *status = NULL;
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            status = @"background";
        } else {
            status = @"notbackground";
        }

        [self sendNSURLRequest:[
                                NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/%@/long/%f/lat/%f/horizontalAccuracy/%f/verticalAccuracy/%f/major/%@/minor/%@/appstate/%@",
                                _venderUUID.UUIDString,
                                @"findBeacon",
                                location.coordinate.latitude,
                                location.coordinate.longitude,
                                location.horizontalAccuracy,
                                location.verticalAccuracy,
                                nearestBeacon.major,
                                nearestBeacon.minor,
                                status]];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self sendLocalNotificationForMessage:@"RegioningFailed"];
    NSLog(@"RegionFailed");

    CLLocation *location = [manager location];
    NSLog(@"%f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
    [self sendNSURLRequest:[
                            NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/%@/long/%f/lat/%f/horizontalAccuracy/%f/verticalAccuracy/%f",
                            _venderUUID.UUIDString,
                            @"regionFailed",
                            location.coordinate.latitude,
                            location.coordinate.longitude,
                            location.horizontalAccuracy,
                            location.verticalAccuracy]];

}

#pragma mark - Private methods

- (void)sendNSURLRequest:(NSString *)url
{
    NSLog(@"%@",url);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/appstate/%ld",url,[UIApplication sharedApplication].applicationState]]];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (error) {
            if (error.code == -1003) {
                NSLog(@"not found hostname. targetURL=%@", url);
            } else if (-1019) {
                NSLog(@"auth error. reason=%@", error);
            } else {
                NSLog(@"unknown error occurred. reason = %@", error);
            }
            
        } else {
            long httpStatusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (httpStatusCode == 404) {
                NSLog(@"404 NOT FOUND ERROR. targetURL=%@", url);
                // } else if (・・・) {
                // 他にも処理したいHTTPステータスがあれば書く。
            } else {
                NSLog(@"success request!!");
                NSLog(@"statusCode = %ld", (long)((NSHTTPURLResponse *)response).statusCode);
                NSLog(@"responseText = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                // ここはサブスレッドなので、メインスレッドで何かしたい場合には
                dispatch_async(dispatch_get_main_queue(), ^{
                    // ここに何か処理を書く。
                });
            }
        }
    }];
}


- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
@end
