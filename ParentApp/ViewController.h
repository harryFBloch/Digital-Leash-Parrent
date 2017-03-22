//
//  ViewController.h
//  ParentApp
//
//  Created by harry bloch on 2/1/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

@interface ViewController : UIViewController  <UIAlertViewDelegate,CLLocationManagerDelegate, NSURLConnectionDelegate>
{
    NSMutableData * _responseData;
}
@property (nonatomic,strong) NSURLConnection *connections;
@property (nonatomic,strong) NSURLConnection *conn;
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation* location;
@property (nonatomic,strong) NSNumber * latitude;
@property (nonatomic,strong) NSNumber * longitude;
@property (nonatomic,strong) NSString * radius;
@property (nonatomic,strong) NSString * jSong;

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userRadius;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)childStatus:(id)sender;

- (IBAction)updateZone:(id)sender;


- (IBAction)createUserID:(id)sender;



-(void)startLocationManager;
-(void)convertDictionary;
-(void)postData;
-(void)getChildData;
-(void)patchData;
-(void)internet;


@end

