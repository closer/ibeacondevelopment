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
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
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
    [self sendLocalNotificationForMessage:@"Start Monitoring Region"];
    NSLog(@"Start Monitoring Region");
    [self sendNSURLRequest:[NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/startMonitroing/",_venderUUID.UUIDString]];
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside: // リージョン内にいる
            [self sendLocalNotificationForMessage:@"I'm standing by you!!"];
            NSLog(@"I'm standing by you!!");
            [self sendNSURLRequest:[NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/inside/",_venderUUID.UUIDString]];
            break;
        case CLRegionStateOutside:
            [self sendLocalNotificationForMessage:@"Where you are??"];
            NSLog(@"Where you are??");
            [self sendNSURLRequest:[NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/ousside/",_venderUUID.UUIDString]];

            break;
        case CLRegionStateUnknown:
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Enter Region"];
    NSLog(@"Enter Region");
    [self sendNSURLRequest:[NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/enter/",_venderUUID.UUIDString]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
    NSLog(@"Exit Region");
    [self sendNSURLRequest:[NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/exit/",_venderUUID.UUIDString]];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self sendLocalNotificationForMessage:@"RegioningFailed"];
    NSLog(@"RegionFailed");
    [self sendNSURLRequest:[NSString stringWithFormat:@"http://lab.exer.jp/tag/regist/userid/%@/state/regionFailed/",_venderUUID.UUIDString]];
}

#pragma mark - Private methods

- (void)sendNSURLRequest:(NSString *)url
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
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
