//
//  settingViewController.m
//  AirBears
//
//  Created by Kentoku Matsunami on 10/11/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "settingViewController.h"
#import "VideoViewController.h"


@implementation settingViewController

@synthesize idField, passwordField, customField0, customField1;
@synthesize locationSlider, locationSliderLabel;
@synthesize locationSwitch;

// mine below

-(void)viewWillDisappear:(BOOL)animated {
	NSLog(@"viewWillDisappear called.");
}

-(IBAction)playTutorial:(id)sender {
    NSLog(@"playTutorial.");
    
    VideoViewController *view = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
	[[self navigationController] pushViewController:view animated:YES];
	[view release];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"mov"];
//
//    MPMoviePlayerViewController *playerViewController = 
//    [[MPMoviePlayerViewController alloc] 
//        initWithContentURL:[NSURL fileURLWithPath:path]];
//    
//    [[NSNotificationCenter defaultCenter] 
//        addObserver:self
//           selector:@selector(movieFinishedCallback:)
//               name:MPMoviePlayerPlaybackDidFinishNotification
//             object:[playerViewController moviePlayer]];
//    
//    playerViewController.view.frame = CGRectMake(184, 200, 400, 300);
//    [self.view addSubview:playerViewController.view];
//    
//    //---play movie---
//    MPMoviePlayerController *player = [playerViewController moviePlayer];
//    [player play];
   
}

//- (void) movieFinishedCallback:(NSNotification*) aNotification {
//    MPMoviePlayerController *player = [aNotification object];
//    [[NSNotificationCenter defaultCenter] 
//        removeObserver:self
//                  name:MPMoviePlayerPlaybackDidFinishNotification
//                object:player];
//    [player stop];
//    [self.view removeFromSuperView];
//    [player autorelease];      
//}

-(IBAction)saveData:(id)sender{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([idField text]) {
		[defaults setObject:[idField text] forKey:@"user_userName"];
	} else {
		[defaults setObject:@"" forKey:@"user_userName"];
	}
	if ([passwordField text]) {
		[defaults setObject:[passwordField text] forKey:@"user_password"];
	} else {
		[defaults setObject:@"" forKey:@"user_password"];
	}
	[defaults setBool:[autoQuitSwitch isOn] forKey:@"user_autoQuitEnabled"];
	[defaults setBool:[iAdSwitch isOn] forKey:@"user_iAdSwitchIsOn"];
	if ([segControl selectedSegmentIndex] == 1) {
		NSLog(@"TeleBears URL set are saved.");
		[defaults setInteger:1 forKey:@"segControlInteger"];
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
			[defaults setURL:[NSURL URLWithString:@"https://telebears.berkeley.edu"] forKey:@"firstURL"];
			[defaults setURL:[NSURL URLWithString:@"https://telebears.berkeley.edu/telebears/home"] forKey:@"completedURL"];
		}
	} else {
		NSLog(@"AirBears URL set are saved.");
		[defaults setInteger:0 forKey:@"segControlInteger"];
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
			[defaults setURL:[NSURL URLWithString:@"http://wlan.berkeley.edu/login/"] forKey:@"firstURL"];
			[defaults setURL:[NSURL URLWithString:@"https://wlan.berkeley.edu/cgi-bin/login/calnet.cgi?submit=CalNet&url="] forKey:@"completedURL"];
		}
	}
	
	if ([[defaults stringForKey:@"user_userName"] isEqualToString:@"kento_24"]) {
		[UIView beginAnimations:@"disolve" context:nil];
		[segControl setAlpha:1.0];
		[segControl setHidden:NO];
		[UIView commitAnimations];
	} else {

		[UIView beginAnimations:@"disolve" context:nil];
		[segControl setHidden:YES];
		[segControl setAlpha:0.0];
		[UIView commitAnimations];
		[segControl setSelectedSegmentIndex:0];
	}
    
    [defaults setURL:[NSURL URLWithString:[customField0 text]] forKey:@"customURL0"];
    [defaults setURL:[NSURL URLWithString:[customField1 text]] forKey:@"customURL1"];
}

-(IBAction)switchAdvancedMode:(id)sender {
    if([iAdSwitch isOn]) {
        [UIView beginAnimations:@"hideInstruceion" context:nil];
        [instruction setAlpha:0.0];
        [customField0 setAlpha:1.0];
        [customField1 setAlpha:1.0];
        [advLabal0 setAlpha:1.0];
        [advLabel1 setAlpha:1.0];
        
        [instruction setHidden:YES];
        [customField0 setHidden:NO];
        [customField1 setHidden:NO];
        [advLabal0 setHidden:NO];
        [advLabel1 setHidden:NO];
        
        //slider hidden
        [locationSlider setHidden:NO];
        //slider alpha
        [locationSlider setAlpha:1.0];
        //locationSwitch hidden
        [locationSwitch setHidden:NO];
        //locationSwitch alpha
        [locationSwitch setAlpha:1.0];
        /*
        //sliderLabel alpha
        [sliderLabel setAlpha:1.0];
        //locationSwitchLabel alpha
        [locationSwitchLabel setAlpha:1.0];*/
        
        
        [UIView commitAnimations];
        
        
    } else {
        [UIView beginAnimations:@"showInstruction" context:nil];
        [instruction setAlpha:1.0];
        [customField0 setAlpha:0.0];
        [customField1 setAlpha:0.0];
        [advLabal0 setAlpha:0.0];
        [advLabel1 setAlpha:0.0];
        
        [instruction setHidden:NO];
        [customField0 setHidden:YES];
        [customField1 setHidden:YES];
        [advLabal0 setHidden:YES];
        [advLabel1 setHidden:YES];
        
        //slider hidden
        [locationSlider setHidden:YES];
        //slider alpha
        [locationSlider setAlpha:0.0];
        //locationSwitch hidden
        [locationSwitch setHidden:YES];
        //locationSwitch alpha
        [locationSwitch setAlpha:0.0];
        /*
        //sliderLabel alpha
        [sliderLabel setAlpha:0.0];         
        //locationSwitchLabel alpha
        [locationSwitchLabel setAlpha:0.0];*/
        
        
        
        [UIView commitAnimations];
    }
}


-(void)loadData {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	idField.text = [defaults stringForKey:@"user_userName"];
	passwordField.text = [defaults stringForKey:@"user_password"];
	[autoQuitSwitch setOn:[defaults boolForKey:@"user_autoQuitEnabled"]];
	[iAdSwitch setOn:[defaults boolForKey:@"user_iAdSwitchIsOn"]];
	if ([defaults integerForKey:@"segControlInteger"]) {
		[segControl setSelectedSegmentIndex:[defaults integerForKey:@"segControlInteger"]];
	}
	
	if ([[defaults stringForKey:@"user_userName"] isEqualToString:@"kento_24"]) {
		[segControl setHidden:NO];
		[segControl setAlpha:1.0];
	} else {
		[segControl setHidden:YES];
		[segControl setAlpha:0.0];
	}
    
    [customField0 setText:[[defaults URLForKey:@"customURL0"] relativeString]];
    [customField1 setText:[[defaults URLForKey:@"customURL1"] relativeString]];
    if ( [defaults stringForKey:@"user_userName"] == nil ) {
        NSTimer *timer;
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(launchTutorial:) userInfo:nil repeats:NO];
    }
}

-(IBAction)locationSliderChanged:(UISlider*)slider {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* label0 = @"Best";
    NSString* label1 = @"nearestTenMeters";
    NSString* label2 = @"HundreadMeters";
    NSString* label3 = @"Power Efficient";
    NSLog(@"locationSliderChanged, value=%f",[slider value]);
    if([slider value] < 1) {
        [locationSliderLabel setText:label0];
        [defaults setInteger:0 forKey:@"locationFrequency"];
    } else if (1 <= [slider value] && [slider value] < 2) {
        [locationSliderLabel setText:label1];
        [defaults setInteger:1 forKey:@"locationFrequency"];
    } else if (2 <= [slider value] && [slider value] < 3) {
        [locationSliderLabel setText:label2];
        [defaults setInteger:2 forKey:@"locationFrequency"];
    } else if (3 <= [slider value] && [slider value] <= 4) {
        [locationSliderLabel setText:label3];
        [defaults setInteger:3 forKey:@"locationFrequency"];
    }

}


-(void)launchTutorial:(NSTimer*) timer {
    [self playTutorial:nil];
}


-(IBAction)hideKeyboard:(id)sender{
	[sender resignFirstResponder];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

//mine above

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
	[self loadData];
    [self switchAdvancedMode:nil];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [super dealloc];
}


@end
