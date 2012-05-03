//
//  webViewController.h
//  AirBears
//
//  Created by Kentoku Matsunami on 10/11/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <iAd/iAd.h>
#import <CoreLocation/CoreLocation.h>

#import "Reachability.h"
@class Reachability;

const double THRESH = 50.0;
const int    COUNTMAX = 4;

@interface webViewController : UIViewController <UIWebViewDelegate, ADBannerViewDelegate> {
	IBOutlet UIWebView *WebView;
	IBOutlet UIActivityIndicatorView *indicator;
	IBOutlet UILabel *iAdLabel1, *iAdLabel2;
	IBOutlet ADBannerView *adView;
	int      loadCount, countMax;
    BOOL     allowedToDeployNotification;
    
    CLLocationManager *locationManager;
    NSDate* lastDate;
    CLLocation* lastLocation;
	
	Reachability* AirBearsReach;
	Reachability* ResCompReach;
	Reachability* appleReach;
	Reachability* hostReach;
	Reachability* internetReach;
    Reachability* wifiReach;
	
	SystemSoundID soundID;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, retain) IBOutlet UIWebView *WebView;
@property (nonatomic, retain) CLLocation* lastLocation;
@property (nonatomic, retain) NSDate* lastDate;
@property (nonatomic, retain) CLLocationManager *locationManager;


-(IBAction)pushSetting:(id)sender;
-(IBAction)startOver:(id)sender;
-(IBAction)startOverWithRescomp:(id)sender;
-(void)loadURL:(id)sender withURL:(NSURL*)url;
-(void)initializeDataArray;
-(void)clickSubmit;
-(void)fillOutForms;
-(void)exitAppAfterSeconds:(float)seconds;
-(void)iAdOnOff;
-(void)redirectProcessAccordingToReachability: (Reachability*) curReach;

@end
