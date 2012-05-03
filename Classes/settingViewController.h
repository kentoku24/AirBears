//
//  settingViewController.h
//  AirBears
//
//  Created by Kentoku Matsunami on 10/11/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>



@interface settingViewController : UIViewController {
	IBOutlet UITextField *idField;
	IBOutlet UITextField *passwordField;
	IBOutlet UISwitch    *autoQuitSwitch;
	IBOutlet UISwitch	 *iAdSwitch;
	IBOutlet UISegmentedControl *segControl;
    
    IBOutlet UITextView  *instruction;
    IBOutlet UILabel     *advLabal0;
    IBOutlet UILabel     *advLabel1;
    IBOutlet UITextField *customField0;
    IBOutlet UITextField *customField1;
    IBOutlet UISlider    *locationSlider;
    IBOutlet UISwitch    *locationSwitch;
    IBOutlet UILabel     *locationSliderLabel;
}

-(IBAction)saveData:(id)sender;
-(IBAction)hideKeyboard:(id)sender;
-(IBAction)locationSliderChanged:(UISlider*)slider;

@property (nonatomic, retain) IBOutlet UISlider    *locationSlider;
@property (nonatomic, retain) IBOutlet UILabel     *locationSliderLabel;
@property (nonatomic, retain) IBOutlet UISwitch    *locationSwitch;
@property (nonatomic, retain) IBOutlet UITextField *idField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITextField *customField0;
@property (nonatomic, retain) IBOutlet UITextField *customField1;

@end
