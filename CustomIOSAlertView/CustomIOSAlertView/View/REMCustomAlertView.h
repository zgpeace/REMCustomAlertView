//
//  CustomIOSAlertView.h
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>


@interface REMCustomAlertView : UIView

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)

@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, strong) NSArray *buttonNormalColors;  //normal color
@property (nonatomic, strong) NSArray *buttonHighlightColors; //highlight color
@property (nonatomic, assign) BOOL useMotionEffects;
@property (nonatomic, assign) BOOL closeOnTouchUpOutside;       // Closes the AlertView when finger is lifted outside the bounds.

@property (copy) void (^onButtonTouchUpInside)(REMCustomAlertView *alertView, int buttonIndex) ;

- (id)init;

- (void)show;
- (void)close;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;

// create dialog ContainerView with title, content string
- (void)createDialogContainerViewWithTitle:(NSString *)title content:(NSString *)content;

@end
