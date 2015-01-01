//
//  TipViewController.m
//  tipcalculator
//
//  Created by Naeim Semsarilar on 12/20/14.
//  Copyright (c) 2014 naeim. All rights reserved.
//

#import "TipViewController.h"
#import "SettingsViewController.h"

@interface TipViewController ()

@property (weak, nonatomic) IBOutlet UITextField* billTextField;
@property (weak, nonatomic) IBOutlet UILabel* tipLabel;
@property (weak, nonatomic) IBOutlet UILabel* totalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl* tipControl;
@property (weak, nonatomic) IBOutlet UIView *resultsView;

- (IBAction)onBillValueChanged:(id)sender;
- (IBAction)onTipPercentageChanged:(id)sender;
- (void)onSettingsButton;
- (void)updateValues;
- (void)showResultsView;
- (void)showInputOnlyView;
- (void)showResultsViewWithAnimation:(BOOL)animated;
- (void)showInputOnlyViewWithAnimation:(BOOL)animated;

@end

@implementation TipViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.title = @"Tip Calculator";
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onApplicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onApplicationWillResignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up the Settings button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action: @selector(onSettingsButton)];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Set the default tip percentage from the user settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int defaultTipSegmentIndex = [defaults integerForKey:@"default_tip_segment_index"];
    [self.tipControl setSelectedSegmentIndex:defaultTipSegmentIndex];

    // Update values since the tip percentage may have changed
    [self updateValues];
    
    // Put focus on the text field to make sure the keyboard shows
    [self.billTextField becomeFirstResponder];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    // Remove the application life-cycle observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}

// Called when the tip percentage changes
- (IBAction)onTipPercentageChanged:(id)sender {
    // When the tip percentage changes, update the values in the UI
    [self updateValues];
}

// Called when the bill value changes
- (IBAction)onBillValueChanged:(id)sender {
    // When the bill value changes, update the values in the UI
    [self updateValues];

    // Changing the bill value may cause a view animation. Bill value 0 shows
    // the input-only view, and bill value > 0 shows the results view.
    [self updateViewWithAnimation:YES];
}

- (void)updateValues {
    // Obtain the bill amount input by the user
    float billAmount = [self.billTextField.text floatValue];
    
    // Calculate the tip and total amounts
    NSArray* tipValues = @[@(0.1), @(0.15), @(0.2)];
    float tipAmount = billAmount * [tipValues[self.tipControl.selectedSegmentIndex] floatValue];
    float totalAmount = tipAmount + billAmount;
    
    // Use the user's locale to format the currency and set the tip and total labels
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.tipLabel.text = [numberFormatter stringFromNumber:[[NSNumber alloc] initWithFloat:tipAmount]];
    self.totalLabel.text = [numberFormatter stringFromNumber:[[NSNumber alloc] initWithFloat:totalAmount]];
}

- (void)updateViewWithAnimation:(BOOL)animated {
    // Obtain the bill amount input by the user
    float billAmount = [self.billTextField.text floatValue];

    // If bill value is 0, show the input-only view.
    // If bill value > 0, show the results view.
    if (billAmount == 0) {
        [self showInputOnlyViewWithAnimation:animated];
    } else {
        [self showResultsViewWithAnimation:animated];
    }
}

// Called when the user clicks the settings button
- (void)onSettingsButton {
    SettingsViewController* svc = [[SettingsViewController alloc] init];
    svc.edgesForExtendedLayout = UIRectEdgeNone;

    [self.navigationController pushViewController:svc animated:YES];
}

- (void)onApplicationDidBecomeActive {
    // Get the date at which the application last became inactive
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate* lastBillDate = [defaults valueForKey:@"last_bill_date"];
    NSDate* now = [NSDate date];
    
    // Figure out how long it's been since the application became inactive last
    NSTimeInterval interval = [now timeIntervalSinceDate:lastBillDate];
    
    // If it's been less than 10 minutes, resume the last bill amount and tip percentage.
    // Otherwise, clear the bill amount field.
    if (interval < 600) {
        self.billTextField.text = [defaults valueForKey:@"last_bill_amount"];
        self.tipControl.selectedSegmentIndex = [defaults integerForKey:@"last_tip_segment_index"];
    } else {
        self.billTextField.text = @"";
    }

    // Update the values in the UI.
    [self updateValues];
    
    // Update the view to either input-only or results, based on the newly set bill value.
    // Don't animate the view change, because it looks weird if you animate the view on first load.
    [self updateViewWithAnimation:NO];
}

- (void)onApplicationWillResignActive {
    
    // Save the current bill amount, tip percentage, and the current time.
    // If the user comes back to the app before 10 minutes, we restore these values.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.billTextField.text forKey:@"last_bill_amount"];
    [defaults setObject:[NSDate date] forKey:@"last_bill_date"];
    [defaults setInteger:self.tipControl.selectedSegmentIndex forKey:@"last_tip_segment_index"];
    [defaults synchronize];
}

- (void)showResultsView {
    // Fade in the tip percentage control
    self.tipControl.alpha = 1;
    
    // Slide up the tip percentage control
    CGRect tipControlFrame = self.tipControl.frame;
    tipControlFrame.origin.y = 110;
    self.tipControl.frame = tipControlFrame;

    // Slide up the tip value and total fields
    CGRect resultFrame = self.resultsView.frame;
    resultFrame.origin.y = 160;
    self.resultsView.frame = resultFrame;
    
    // Slide up the bill value field
    CGRect textFrame = self.billTextField.frame;
    textFrame.origin.y = 10;
    self.billTextField.frame = textFrame;
}

- (void)showInputOnlyView {
    // Face out the tip percentage control
    self.tipControl.alpha = 0;
    
    // Slide down the tip percentage control
    CGRect tipControlFrame = self.tipControl.frame;
    tipControlFrame.origin.y = 250;
    self.tipControl.frame = tipControlFrame;

    // Slide down the tip value and total fields
    CGRect resultFrame = self.resultsView.frame;
    resultFrame.origin.y = 300;
    self.resultsView.frame = resultFrame;
    
    // Slide down the bill value field
    CGRect textFrame = self.billTextField.frame;
    textFrame.origin.y = 110;
    self.billTextField.frame = textFrame;
}

- (void)showResultsViewWithAnimation:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self showResultsView];
        } completion:^(BOOL finished) {
        }];
    }
    else {
        [self showResultsView];
    }
}

- (void)showInputOnlyViewWithAnimation:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self showInputOnlyView];
        } completion:^(BOOL finished) {
        }];
    }
    else {
        [self showInputOnlyView];
    }
}

@end
