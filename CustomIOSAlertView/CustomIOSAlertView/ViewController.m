//
//  ViewController.m
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Just a subtle background color
    [self.view setBackgroundColor:[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f]];

    // A simple button to launch the demo
    UIButton *launchDialog = [UIButton buttonWithType:UIButtonTypeCustom];
    [launchDialog setFrame:CGRectMake(10, 30, self.view.bounds.size.width-20, 50)];
    [launchDialog addTarget:self action:@selector(launchDialog:) forControlEvents:UIControlEventTouchDown];
    [launchDialog setTitle:@"Launch Dialog" forState:UIControlStateNormal];
    [launchDialog setBackgroundColor:[UIColor whiteColor]];
    [launchDialog setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [launchDialog.layer setBorderWidth:0];
    [launchDialog.layer setCornerRadius:5];
    [self.view addSubview:launchDialog];
}

- (IBAction)launchDialog:(id)sender
{
    // Here we need to pass a full frame
    REMCustomAlertView *alertView = [[REMCustomAlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView createDialogContainerViewWithTitle:@"YO" content:@"你需要开启你的地理位置权限，\n 设置 > 一天 > 地理位置 你需要开启你的地理位置权限，\n 设置 > 一天 > 地理位置 你需要开启你的地理位置权限，\n 设置 > 一天 > 地理位置"];

    // Modify the parameters
    [alertView setButtonTitles:@[@"OK", @"去设置"]];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(REMCustomAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];

    // And launch the dialog
    [alertView show];
}


@end
