//
//  webViewController.m
//  AirBears
//
//  Created by Kentoku Matsunami on 10/11/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "webViewController.h"
#import "settingViewController.h"


@implementation webViewController

@synthesize WebView, indicator;
@synthesize locationManager;
@synthesize lastDate;
@synthesize lastLocation;


// --------Delegate ↓ 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"webViewDidStardLoad.");
	[indicator startAnimating];
	[UIView beginAnimations:@"disolve" context:nil];
	[indicator setAlpha:1.0];
	[UIView commitAnimations];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"webView didFailLoadWithError.");
	[UIView beginAnimations:@"disolve" context:nil];
	[indicator setAlpha:0.0];
	[UIView commitAnimations];
	[indicator stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *) webView {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[UIView beginAnimations:@"disolve" context:nil];
	[indicator setAlpha:0.0];
	[UIView commitAnimations];
	[indicator stopAnimating];
	
    NSLog(@"===== currentURL=%@", [NSURL URLWithString:[WebView stringByEvaluatingJavaScriptFromString: @"document.URL"]]);
    loadCount++;
	//completedURLに到達したら終了プロセス実行
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
		//3.0デバイス用の急場しのぎ。loadCountが到達するまでひたすらfillとsubmit.完了チェックもしない。
		// segControl is selected to AirBears
		if ([defaults integerForKey:@"segControlInteger"] == 0) {
			//do nothing like vibrating or anything
		}
		[self fillOutForms];
		[self clickSubmit];
	} else if ( [[defaults URLForKey:@"completedURL"] isEqual:[NSURL URLWithString:[WebView stringByEvaluatingJavaScriptFromString: @"document.URL"]]] ) {
		//iAdスイッチが入ってない場合最後の画面のロードが終了したタイミングで振動
		if (![defaults boolForKey:@"user_iAdSwitchIsOn"]){
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		}
		
		//execute quit sequence
		if ([defaults boolForKey:@"user_autoQuitEnabled"] == YES) {
			[self exitAppAfterSeconds:0.1];
		}
		AudioServicesPlaySystemSound(soundID);
		if ([defaults boolForKey:@"user_iAdSwitchIsOn"]) {
			[UIView beginAnimations:@"disolve" context:nil];
			[iAdLabel1 setAlpha:1.0];
			[iAdLabel2 setAlpha:1.0];
			[UIView commitAnimations];
		}
		
	} else if (loadCount < COUNTMAX){
        NSLog(@"loadCount = %d, max=%d", loadCount, COUNTMAX);
		[self fillOutForms];
		[self clickSubmit];
	}
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	//iAd非対応デバイス対策
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
		return;
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
	} else {
		adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
	}

}

//ADBannerViewDelegate
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	NSLog(@"BannerViewDidFailToReceiveAdWithError.");
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	NSLog(@"BannerViewDidLoad.");
	
	//iAdスイッチが入ってる場合Adのロードが終了したタイミングで振動させる
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults boolForKey:@"user_iAdSwitchIsOn"]){
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	}
}


// --------Delegete ↑

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(&UIApplicationWillEnterForegroundNotification != nil)
    {
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(start) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //initialize location manager
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    [locationManager setDelegate:self];
    //Only applies when in foreground otherwise it is very significant changes
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    /*
    switch ((NSInteger)[defaults valueForKey:@"locationFrequency"]) {
        case 0:
            [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            locationManager.distanceFilter = 5;
            break;
        case 1:
            [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
            locationManager.distanceFilter = 10;
            break;
        case 2:
            [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
            locationManager.distanceFilter = 50;
            break;
        case 3:
        default:
            break;
    }*/
    

    // set location and date for next time
    // fire notification iff distance is more than threshold
    lastLocation = [[locationManager location] retain];
    lastDate = [[NSDate date] retain];
    
    if ((NSInteger)[defaults valueForKey:@"locationFrequency"] == 3) {
        [locationManager startMonitoringSignificantLocationChanges];
    } else {
        [locationManager startUpdatingLocation];
    }
        
	
	//ここから接続チェック
	//接続状態をチェック
	//[[Reachability sharedReachability] setHostName:@"http://wlan.berkeley.edu/login/"];
	//NSString* hostName = [NSString stringWithString: @"http://wlan.berkeley.edu/login/"];
	//NSString* hostName = [NSString stringWithString: @"https://telebears.berkeley.edu"];
	
	// 自動検知するためにNotificationに登録する
	 [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	
	
	// 指定したホストに接続確認する場合
	hostReach = [[Reachability reachabilityWithHostName: @"www.google.com"] retain];
    [hostReach startNotifier];
	[self redirectProcessAccordingToReachability:hostReach];
	
	// インターネットに接続できるか確認
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [internetReach startNotifier];
    [self redirectProcessAccordingToReachability: internetReach];
	
	// Wifi接続かどうか確認
    wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
    [wifiReach startNotifier];
    [self redirectProcessAccordingToReachability: wifiReach];
	
	AirBearsReach  = [[Reachability reachabilityWithHostName: @"wlan.berkeley.edu/login/"] retain];
	[AirBearsReach startNotifier];
	[self redirectProcessAccordingToReachability:AirBearsReach];
	
	ResCompReach   = [[Reachability reachabilityWithHostName: @"net-auth-b.housing.berkeley.edu/"] retain];
	[ResCompReach startNotifier];
	[self redirectProcessAccordingToReachability:ResCompReach];

    
    appleReach  = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
	[appleReach startNotifier];
	[self redirectProcessAccordingToReachability:appleReach];

    
	//ここまで接続チェック
	
    
	[self setTitle:@"AirBears"];
	[self initializeDataArray];
	
	WebView.delegate = self;
	WebView.scalesPageToFit = YES;
	WebView.multipleTouchEnabled = YES;
	loadCount = 0;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
		if ([defaults integerForKey:@"segControlInteger"] == 0) {
			[self loadURL:nil withURL:[NSURL URLWithString:@"http://wlan.berkeley.edu/login/"]];
		} else {
			[self loadURL:nil withURL:[NSURL URLWithString:@"https://telebears.berkeley.edu"]];
		}
	} else {
		[self loadURL:nil withURL:[defaults URLForKey:@"firstURL"]];
	}
	
	
	//iAd対応のデバイスでのみの処理
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
		//iAd初期化
		//CGRect bannerSize = self.view.frame;
		//bannerSize.origin.y = self.view.frame.size.height - adView.frame.size.height;
		//adView = [[ADBannerView alloc] initWithFrame: CGRectMake(0.0, 322.0, 320.0, 50.0)];
		//adView.delegate = self;

		
		adView.requiredContentSizeIdentifiers = [NSSet setWithObjects:
												 ADBannerContentSizeIdentifierPortrait,
												 ADBannerContentSizeIdentifierLandscape,
												 nil];
		adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		//[self.view addSubview:adView];
		//[adView release];
			

	}


	
	
	//サウンド初期化関連
	NSString *path  = [[NSBundle mainBundle] pathForResource:@"ping" ofType:@"wav"];
	NSURL *soundURL = [NSURL fileURLWithPath:path];
	AudioServicesCreateSystemSoundID(soundURL, &soundID);
}

- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self redirectProcessAccordingToReachability: curReach];
}

-(void)redirectProcessAccordingToReachability: (Reachability*) curReach
{
    if(curReach == hostReach)
	{
        BOOL connectionRequired= [curReach connectionRequired];
		
		NSMutableString* info = [NSMutableString stringWithString:@"at hostReach: "];
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		if (netStatus == ReachableViaWWAN) {
			[info appendString:@"WAN "];
		}
		if (netStatus == ReachableViaWiFi) {
			[info appendString:@"WiFi "];
		}
		if (netStatus == NotReachable) {
			[info appendString:@"NotReachable"];
		}
		NSLog(@"%@",info);
        if(connectionRequired)
        {
            //@"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.";
        }
        else
        {
            //@"Cellular data network is active.\n  Internet traffic will be routed through it.";
        }

    }
	if (curReach == AirBearsReach) {
		NSMutableString* info = [NSMutableString stringWithString:@"at AirBears: "];
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		if (netStatus == ReachableViaWWAN) {
			[info appendString:@"WAN "];
		}
		if (netStatus == ReachableViaWiFi) {
			[info appendString:@"WiFi "];
		}
		if (netStatus == NotReachable) {
			[info appendString:@"NotReachable"];
		}
		NSLog(@"%@",info);
	}
	if (curReach == ResCompReach) {
		NSMutableString* info = [NSMutableString stringWithString:@"at ResComp: "];
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		if (netStatus == ReachableViaWWAN) {
			[info appendString:@"WAN "];
		}
		if (netStatus == ReachableViaWiFi) {
			[info appendString:@"WiFi "];
		}
		if (netStatus == NotReachable) {
			[info appendString:@"NotReachable"];
		}
		NSLog(@"%@",info);
	}
	if (curReach == appleReach) {
		NSMutableString* info = [NSMutableString stringWithString:@"to apple: "];
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		if (netStatus == ReachableViaWWAN) {
			[info appendString:@"WAN "];
		}
		if (netStatus == ReachableViaWiFi) {
			[info appendString:@"WiFi "];
		}
		if (netStatus == NotReachable) {
			[info appendString:@"NotReachable"];
		}
		NSLog(@"%@",info);
	}
	if(curReach == internetReach)
	{	
		NSMutableString* info = [NSMutableString stringWithString:@"at internetReach: "];
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		if (netStatus == ReachableViaWWAN) {
			[info appendString:@"WAN "];
		}
		if (netStatus == ReachableViaWiFi) {
			[info appendString:@"WiFi "];
		}
		if (netStatus == NotReachable) {
			[info appendString:@"NotReachable"];
		}
		NSLog(@"%@",info);
	}
	if(curReach == wifiReach)
	{	
		NSMutableString* info = [NSMutableString stringWithString:@"at WifiReach: "];
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		if (netStatus == ReachableViaWWAN) {
			[info appendString:@"WAN "];
		}
		if (netStatus == ReachableViaWiFi) {
			[info appendString:@"WiFi "];
		}
		if (netStatus == NotReachable) {
			[info appendString:@"NotReachable"];
		}
		NSLog(@"%@",info);
	}
	
}

// ===== my own methods below

-(void)iAdOnOff{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//iAd対応じゃない場合そもそも処理をしない
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
		return;
	//iAdスイッチがオフの場合iAdを表示させない
	if ([defaults boolForKey:@"user_iAdSwitchIsOn"]) {
		[adView setHidden:NO];
		[iAdLabel1 setHidden:NO];
		[iAdLabel2 setHidden:NO];
		NSLog(@"Banners display.");
	}else {
		[adView setHidden:YES];
		[iAdLabel1 setHidden:YES];
		[iAdLabel2 setHidden:YES];
		NSLog(@"Banner are hidden.");
	}
}



-(IBAction)pushSetting:(id)sender{
	settingViewController *view = [[settingViewController alloc] initWithNibName:@"settingViewController" bundle:nil];
	[[self navigationController] pushViewController:view animated:YES];
	[settingViewController release];
}

-(void)start {
    allowedToDeployNotification = YES;
    [self startOver:nil];
}

-(IBAction)startOver:(id)sender{
	[WebView stopLoading];
	loadCount = 0;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
		[self loadURL:nil withURL:[NSURL URLWithString:@"http://wlan.berkeley.edu/login/"]];
	} else {
		[self loadURL:nil withURL:[defaults URLForKey:@"firstURL"]];
	}
	
	[self iAdOnOff];
}

-(IBAction)startOverWithRescomp:(id)sender {
	[WebView stopLoading];
	loadCount = 0;
    
	[self loadURL:nil withURL:[NSURL URLWithString:@"http://net-auth-b.housing.berkeley.edu/"]];
	[self iAdOnOff];
}

-(IBAction)startWithCustomURL:(UIButton*)sender {
    [WebView stopLoading];
    loadCount = 0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults URLForKey:@"customURL0"]) {
        [self loadURL:nil withURL:[defaults URLForKey:@"customURL0"]];
    }
    [self iAdOnOff];

}

-(void)loadURL:(id)sender withURL:(NSURL*)url {
	[WebView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)initializeDataArray {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//バージョンアップ時に更新する項目を以下に
	NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
	NSString *version = [infoDict objectForKey:@"CFBundleVersion"];
	
	//バージョンアップ時にこのifを実行 == なにか新しいData Structureを加えたらそのバージョンのみここに足す
	if ( ![version isEqualToString: [defaults stringForKey:@"version"]] ) {
		//versionに現在のバージョンを保存
		[defaults setObject:version forKey:@"version"];
        [defaults setInteger:3 forKey:@"locationFrequency"];
	}
	
	//初回起動のみの項目を以下に書く
	if ([defaults boolForKey:@"launchedBefore"]) {
		return;
	}
    
    [defaults setURL:[NSURL URLWithString: @"https://wireless-lc2.sfsu.edu"] forKey:@"customURL0"];
    [defaults setURL:nil forKey:@"customURL1"];
    [defaults setURL:nil forKey:@"customURL2"];
	[defaults setBool:NO forKey:@"user_iAdSwitchIsOn"];
	[defaults setBool:YES forKey:@"launchedBefore"];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
		//do nothingent
	} else {
		[defaults setURL:[NSURL URLWithString:@"http://wlan.berkeley.edu/login/"] forKey:@"firstURL"];
		[defaults setURL:[NSURL URLWithString:@"https://wlan.berkeley.edu/cgi-bin/login/calnet.cgi?submit=CalNet&url="] forKey:@"completedURL"];
	}
	NSLog(@"initial setting stuff is executed.");
	[self pushSetting:nil];
}

// TODO ６行目のgetElementsByValue 動くかどうか確認
-(void)clickSubmit {
	NSLog(@"%@", [WebView stringByEvaluatingJavaScriptFromString: @"document.URL"] );
	if( [[NSString stringWithString: @"http://wlan.berkeley.edu/login/"]
		 isEqualToString: [WebView stringByEvaluatingJavaScriptFromString: @"document.URL"]]){ 
		NSLog(@"URL matched to AirBears.");
		[WebView stringByEvaluatingJavaScriptFromString: @"document.getElementsByName('submit').item(0).click()"];
	} else if ([[NSString stringWithString: @"http://net-auth-b.housing.berkeley.edu/"]
				isEqualToString: [WebView stringByEvaluatingJavaScriptFromString: @"document.URL"]]) {
		NSLog(@"URL matched to Rescomp.");
		[WebView stringByEvaluatingJavaScriptFromString: @"document.getElementsByName('submit_button').item(0).click()"];
	} else {
		NSLog(@"URL doesn't match to neither AirBears nor Rescomp. OR, it's in ID-Pass page after fillOutForm is called.");
		[WebView stringByEvaluatingJavaScriptFromString:@"document.forms[0].submit()"];
	}
}

-(void)fillOutForms {
	NSLog(@"Filling out CalNet forms...");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *loadedID;
	NSString *loadedPass = [defaults stringForKey:@"user_password"];

	if([defaults stringForKey:@"user_userName"])
		loadedID   = [defaults stringForKey:@"user_userName"];
	else
		loadedID = @"";
	if([defaults stringForKey:@"user_password"])
		loadedPass = [defaults stringForKey:@"user_password"];
	else
		loadedPass = @"";
	NSLog(@"loaded ID is %@, and Pass is %@.", loadedID, loadedPass);
	
	NSString *js_string1 = [NSString stringWithFormat:@"document.getElementsByName('username').item(0).value='%@'",loadedID];
	NSString *js_string2 = [NSString stringWithFormat:@"document.getElementsByName('password').item(0).value='%@'",loadedPass];
	
	[WebView stringByEvaluatingJavaScriptFromString:js_string1];
	[WebView stringByEvaluatingJavaScriptFromString:js_string2];
}

// seconds 秒後にタイマー発動→アプリ終了
-(void)exitAppAfterSeconds:(float)seconds {
	NSTimer *timer;
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(killApp:) userInfo:nil repeats:NO];
}
-(void)killApp:(NSTimer *)timer {
	exit(0);
}

// ===== my own methods above


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    
    if (oldLocation != nil) {
        CLLocationDistance distanceChange = [newLocation distanceFromLocation:oldLocation];
        NSTimeInterval sinceLastUpdate = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
        NSLog(@"real dist change and speed %fm, %fs, %fkph",distanceChange, sinceLastUpdate,(distanceChange/sinceLastUpdate)*3.6);
    }
    
    CLLocationDistance dist = 0;
    if (lastLocation != nil) {
        dist = [newLocation distanceFromLocation:lastLocation];
        NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:lastDate];
        NSLog(@"other way, dist=%f,time=%f,speed=%f",dist,timeDiff, (dist/timeDiff) * 3.6 );
    }
    //calculate distance from last time
    
    //NSLog(@"dist=%f, THRESH=%f",dist,THRESH);
    if (dist > THRESH) {
        NSLog(@"more than THRESH, send notification and update last location.");
        [lastDate release];
        lastDate = [[NSDate date] retain];
        [lastLocation release];
        lastLocation = [[locationManager location] retain];
        
        
        //from here just getting current time
        /*
        NSDate *fireTime = [NSDate date];
        NSLog(@"FireTime = %@", [fireTime description]);
        //set up the notifier
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = fireTime;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        
        localNotification.alertBody = @"Attempted to login automatically.";
        //localNotification.alertBody = @"You moved more than 50m, parhaps you are in the different building?";
        localNotification.alertAction = @"Launch";
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"obj" forKey: @"key" ];
        localNotification.userInfo = dict;
        //notification is disabled since FULL backgrounding is WAAAAAY better
         
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [localNotification release];
         */
        
        //I don't want to deploy multiply notification since user is ignoring it
        allowedToDeployNotification = NO;
        
        NSLog(@"============ try entire process in background");
        [self start];
        
    }
    
    

    

    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
    
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	adView.delegate = nil;
	WebView.delegate = nil;
	[WebView release];
	[indicator release];
	[adView release];
	
    [super dealloc];

}


@end
