//
//  VideoViewController.m
//  AirBears
//
//  Created by Kentoku Matsunami on 11/11/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"

@implementation VideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"mov"];
    
    MPMoviePlayerController *player = 
        [[MPMoviePlayerController alloc] 
            initWithContentURL:[NSURL fileURLWithPath:path]];
    
    [[NSNotificationCenter defaultCenter] 
        addObserver:self
           selector:@selector(movieFinishedCallback:)                                                 
               name:MPMoviePlayerPlaybackDidFinishNotification
             object:player];
    player.view.frame = CGRectMake(0, 0, 320, 416);
    [self.view addSubview:player.view];
    
    //---play movie---
    [player play];    
       
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void) movieFinishedCallback:(NSNotification*) aNotification {
//    MPMoviePlayerController *player = [aNotification object];
//    [[NSNotificationCenter defaultCenter] 
//        removeObserver:self
//                  name:MPMoviePlayerPlaybackDidFinishNotification
//                object:player];
//    [player stop];
//    [self.view removeFromSuperView];
//    [player autorelease];  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
