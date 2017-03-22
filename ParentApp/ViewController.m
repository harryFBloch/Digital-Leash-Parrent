//
//  ViewController.m
//  ParentApp
//
//  Created by harry bloch on 2/1/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self internet];
    //get location services
    [self startLocationManager];
}

-(void)internet{
    Reachability * internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netstatus = [internetReach currentReachabilityStatus];
    if (netstatus!=ReachableViaWWAN)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"No internet available", @"AlertView") message:NSLocalizedString(@"you have no internet available. Please connect to the internet", @"AlertView") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"AlertView") otherButtonTitles:NSLocalizedString(@"open settings", @"AlertView"), nil];
        [alertView show];
    }
}

//open Wifi Settings
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
}

//location
-(void)startLocationManager
{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.location = [locations lastObject];
            NSLog(@"latitude %.6f, longitude %.6f",self.location.coordinate.latitude,self.location.coordinate.longitude);
    self.latitude = [[NSNumber alloc]init];
    self.longitude= [[NSNumber alloc]init];
    self.latitude = [NSNumber numberWithDouble:self.location.coordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:self.location.coordinate.longitude];
    //run dictionary method
    [self.locationManager stopUpdatingLocation];
}

-(void)convertDictionary{
    NSDictionary *userDetails = @{
                                  @"utf8" : @"✓",
                                  @"authenticity_token" : @"EvZva3cKnzo3Y0G5R3NktucCr99o/2UWOPVAmJYdBOc=",
                                  @"user": @{
                                          @"username" : self.userID,
                                          @"latitude" : self.latitude,
                                          @"longitude" : self.longitude,
                                          @"radius" : self.radius
                                          },
                                  @"commit" : @"Create User",
                                  @"action" : @"update",
                                  @"controller" : @"users"
                                  };
    //convert to json
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDetails options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData)
    {
        NSLog(@"Gor an error: %@",error);
    }else
    {
        NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON TEST->%@",jsonString);
        self.jSong = jsonString;
    }
}

-(void)postData {
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://protected-wildwood-8664.herokuapp.com/users"]];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[NSData dataWithBytes:[self.jSong UTF8String] length:strlen([self.jSong UTF8String])]];
    NSURLConnection *connections = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)childStatus:(id)sender {
    self.userID = self.userName.text;
    [self getChildData];
}

- (IBAction)updateZone:(id)sender {
    self.userID = self.userName.text;
    [self startLocationManager];
    self.radius = self.userRadius.text;
    [self convertDictionary];
    [self patchData];
    self.statusLabel.hidden = true;
}

- (IBAction)createUserID:(id)sender {
    self.userID = self.userName.text;
    self.radius = self.userRadius.text;
    [self convertDictionary];
    [self postData];
    self.statusLabel.hidden = true;
}

//getting child data
-(void)getChildData {
    NSString *urlString = [NSString stringWithFormat:@"http://protected-wildwood-8664.herokuapp.com/users/%@.json",self.userID];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    self.conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response {
    //a respons has been recieved
    _responseData = [[NSMutableData alloc]init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data
{
    //append the new data to the instance variable
    [_responseData appendData:data];
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(nonnull NSCachedURLResponse *)cachedResponse
{
    //retrun nil to indicate not necessar to store a cached response for this connection
    return nil;
}

-(void)connectionDidFinishLoading: (NSURLConnection *)connection
{
//    the request is complete the data has been recieved
//    you can parse the stuff in you instance variable now
    if (connection == self.conn)
    {
        BOOL tempbool=NO;
    NSError *error;
    self.statusLabel.hidden=false;
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[_responseData length]);
    NSDictionary *dictionary =[NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    NSLog(@"TEST JSon to dicctionary->%@",dictionary);
//    NSLog(@"%@",error);
    NSLog(@"test->%@",dictionary[@"is_in_zone"]);
        NSString *temp = dictionary[@"is_in_zone"];
        if ([temp isEqual:[NSNull null]]) {
            [self.statusLabel setText:@"Child location is unkhown!"];
            self.statusLabel.backgroundColor = [UIColor grayColor];
            return;
        }
        if (![temp isEqual:[NSNull null]]) {
            tempbool = [temp boolValue];
        }
        if (tempbool)
        {
            [self.statusLabel setText:@"Child is in the zone!"];
            self.statusLabel.backgroundColor = [UIColor greenColor];
        }else
        {
            [self.statusLabel setText:@"Child is out of the zone!"];
            self.statusLabel.backgroundColor = [UIColor redColor];
        }
    }

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

//patching zone data
-(void)patchData{

    NSString *urlString = [NSString stringWithFormat:@"http://protected-wildwood-8664.herokuapp.com/users/%@",self.userID];
    NSMutableURLRequest *patchRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [patchRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [patchRequest setHTTPMethod:@"PATCH"];
    [patchRequest setHTTPBody:[NSData dataWithBytes:[self.jSong UTF8String] length:strlen([self.jSong UTF8String])]];
    NSURLConnection *connections = [[NSURLConnection alloc]initWithRequest:patchRequest delegate:self];
    NSLog(@"%@",patchRequest);
}

@end

















