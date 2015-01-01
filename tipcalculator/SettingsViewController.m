//
//  SettingsViewController.m
//  tipcalculator
//
//  Created by Naeim Semsarilar on 12/21/14.
//  Copyright (c) 2014 naeim. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl* defaultTipControl;
- (void)updateDefaultTip;
- (IBAction)onDefautTipValueChanged:(id)sender;

@end


@implementation SettingsViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize the view with the current default tip percentage
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    int defaultTipSegmentIndex = [defaults integerForKey:@"default_tip_segment_index"];
    [self.defaultTipControl setSelectedSegmentIndex:defaultTipSegmentIndex];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self updateDefaultTip];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Called when the default tip percentage changes
- (IBAction)onDefautTipValueChanged:(id)sender {
    [self updateDefaultTip];
}

- (void)updateDefaultTip {
    // Save the default tip percentage
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.defaultTipControl.selectedSegmentIndex forKey:@"default_tip_segment_index"];
    [defaults synchronize];
}

@end
