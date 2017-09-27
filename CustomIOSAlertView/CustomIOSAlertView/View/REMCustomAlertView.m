//
//  CustomIOSAlertView.m
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import "REMCustomAlertView.h"
#import <QuartzCore/QuartzCore.h>

const static CGFloat kCustomIOSAlertViewDefaultButtonHeight       = 50;
const static CGFloat kCustomIOSAlertViewDefaultButtonSpacerHeight = 0.5;
const static CGFloat kCustomIOSAlertViewCornerRadius              = 7;
const static CGFloat kCustomIOS7MotionEffectExtent                = 10.0;

@implementation REMCustomAlertView

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

        _useMotionEffects = false;
        _closeOnTouchUpOutside = false;
        _buttonTitles = @[@"Close"];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

// Create the dialog view, and animate opening the dialog
- (void)show
{
    _dialogView = [self createContainerView];
  
    _dialogView.layer.shouldRasterize = YES;
    _dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
  
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];

#if (defined(__IPHONE_7_0))
    if (_useMotionEffects) {
        [self applyMotionEffects];
    }
#endif

    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

    [self addSubview:_dialogView];

    // Can be attached to a view or to the top most window
    // Attached to a view:
    if (_parentView != NULL) {
        [_parentView addSubview:self];

    // Attached to the top most window
    } else {

        // On iOS7, calculate with orientation
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            
            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            switch (interfaceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                    break;
                    
                case UIInterfaceOrientationLandscapeRight:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                    break;
                    
                case UIInterfaceOrientationPortraitUpsideDown:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
                    break;
                    
                default:
                    break;
            }
            
            [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

        // On iOS8, just place the dialog in the middle
        } else {

            CGSize screenSize = [self countScreenSize];
            CGSize dialogSize = [self countDialogSize];
            CGSize keyboardSize = CGSizeMake(0, 0);

            _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);

        }

        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }

    _dialogView.layer.opacity = 0.5f;
    _dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         _dialogView.layer.opacity = 1.0f;
                         _dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
					 }
					 completion:NULL
     ];

}

// Button has been touched
- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender
{
    if (_onButtonTouchUpInside != NULL) {
        _onButtonTouchUpInside(self, (int)[sender tag]);
    }
}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close
{
    CATransform3D currentTransform = _dialogView.layer.transform;

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat startRotation = [[_dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);

        _dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    }

    _dialogView.layer.opacity = 1.0f;

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         _dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         _dialogView.layer.opacity = 0.0f;
					 }
					 completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
					 }
	 ];
}

- (void)setSubView: (UIView *)subView
{
    _containerView = subView;
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (UIView *)createContainerView
{
    if (_containerView == NULL) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }

    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];

    // For the black background
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];

    // This is the dialog's container; we attach the custom content and the buttons to this one
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];

    // First, we style the dialog to match the iOS7 UIAlertView >>>
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
//    gradient.colors = [NSArray arrayWithObjects:
//                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
//                       (id)[[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0f] CGColor],
//                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
//                       nil];
    gradient.colors = @[(id)[[UIColor blackColor] CGColor], (id)[[UIColor blackColor] CGColor],(id)[[UIColor blackColor] CGColor]];

    CGFloat cornerRadius = kCustomIOSAlertViewCornerRadius;
    gradient.cornerRadius = cornerRadius;
    [dialogContainer.layer insertSublayer:gradient atIndex:0];

    dialogContainer.layer.cornerRadius = cornerRadius;
//    dialogContainer.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
//    dialogContainer.layer.borderWidth = 0.5;
    dialogContainer.layer.shadowRadius = cornerRadius + 5;
    dialogContainer.layer.shadowOpacity = 0.1f;
    dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius+5)/2, 0 - (cornerRadius+5)/2);
    dialogContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    dialogContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:dialogContainer.bounds cornerRadius:dialogContainer.layer.cornerRadius].CGPath;

    // There is a line above the button
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight, dialogContainer.bounds.size.width, buttonSpacerHeight)];
    lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    [dialogContainer addSubview:lineView];
    // ^^^

    // Add the custom container if there is any
    [dialogContainer addSubview:_containerView];

    // Add the buttons too
    [self addButtonsToView:dialogContainer];

    return dialogContainer;
}

// Helper function: add buttons to container
- (void)addButtonsToView: (UIView *)container
{
    if (_buttonTitles==NULL) { return; }

    CGFloat buttonWidth = container.bounds.size.width / [_buttonTitles count];
    NSInteger buttonCount = [_buttonTitles count];
    for (int i=0; i< buttonCount; i++) {

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat buttonOriginX = i * buttonWidth;
        CGFloat buttonOriginY = container.bounds.size.height - buttonHeight;
        [closeButton setFrame:CGRectMake(buttonOriginX, buttonOriginY, buttonWidth, buttonHeight)];

        [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i];

        [closeButton setTitle:[_buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        UIColor *normalColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.0f];
        if (i == (buttonCount - 1)) {
            normalColor = [UIColor redColor];
        }
        [closeButton setTitleColor:normalColor forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f] forState:UIControlStateHighlighted];
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        closeButton.titleLabel.numberOfLines = 0;
        closeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [closeButton.layer setCornerRadius:kCustomIOSAlertViewCornerRadius];

        [container addSubview:closeButton];
        
        if (i == 0) {
            continue;
        }
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(buttonOriginX, buttonOriginY, buttonSpacerHeight, buttonHeight)];
        lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
        [_containerView addSubview:lineView];
    }
}

//- (UIView *)buttonLineView {
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight, dialogContainer.bounds.size.width, buttonSpacerHeight)];
    
    
//}

// Helper function: count and return the dialog's size
- (CGSize)countDialogSize
{
    CGFloat dialogWidth = _containerView.frame.size.width;
    CGFloat dialogHeight = _containerView.frame.size.height + buttonHeight + buttonSpacerHeight;

    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize
{
    if (_buttonTitles!=NULL && [_buttonTitles count] > 0) {
        buttonHeight       = kCustomIOSAlertViewDefaultButtonHeight;
        buttonSpacerHeight = kCustomIOSAlertViewDefaultButtonSpacerHeight;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // On iOS7, screen width and height doesn't automatically follow orientation
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            CGFloat tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
        }
    }
    
    return CGSizeMake(screenWidth, screenHeight);
}

#if (defined(__IPHONE_7_0))
// Add motion effects
- (void)applyMotionEffects {

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return;
    }

    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);

    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    verticalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);

    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];

    [_dialogView addMotionEffect:motionEffectGroup];
}
#endif

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

// Rotation changed, on iOS7
- (void)changeOrientationForIOS7 {

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGAffineTransform rotation;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 270.0 / 180.0);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 90.0 / 180.0);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 180.0 / 180.0);
            break;
            
        default:
            rotation = CGAffineTransformMakeRotation(-startRotation + 0.0);
            break;
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _dialogView.transform = rotation;
                         
                     }
                     completion:nil
     ];
    
}

// Rotation changed, on iOS8
- (void)changeOrientationForIOS8: (NSNotification *)notification {

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGSize dialogSize = [self countDialogSize];
                         CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                         self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                         _dialogView.frame = CGRectMake((screenWidth - dialogSize.width) / 2, (screenHeight - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
    

}

// Handle device orientation changes
- (void)deviceOrientationDidChange: (NSNotification *)notification
{
    // If dialog is attached to the parent view, it probably wants to handle the orientation change itself
    if (_parentView != NULL) {
        return;
    }

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        [self changeOrientationForIOS7];
    } else {
        [self changeOrientationForIOS8:notification];
    }
}

// Handle keyboard show/hide changes
- (void)keyboardWillShow: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat tmp = keyboardSize.height;
        keyboardSize.height = keyboardSize.width;
        keyboardSize.width = tmp;
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
					 }
					 completion:nil
	 ];
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
					 }
					 completion:nil
	 ];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_closeOnTouchUpOutside) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[REMCustomAlertView class]]) {
        [self close];
    }
}

#pragma mark - customise container view
// create dialog ContainerView with title, content string
- (void)createDialogContainerViewWithTitle:(NSString *)title content:(NSString *)content
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat dialogContentViewWidth = screenWidth * 0.8;
    CGFloat dialogContentViewHeight = 200;
    UIView *dialogContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dialogContentViewWidth, dialogContentViewHeight)];
    CGFloat titleLabelHeight = 20;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, dialogContentViewWidth, titleLabelHeight)];
    titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [dialogContentView addSubview:titleLabel];
    
    CGFloat contentLabelLeft = 20;
    CGFloat contentLabelWidth = dialogContentViewWidth - contentLabelLeft * 2;
    CGFloat contentLabelHeight = 200 - titleLabelHeight - 20;
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelLeft, 40, contentLabelWidth, contentLabelHeight)];
    contentLabel.numberOfLines = 0;
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:content];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    //    paragraphStyle.firstLineHeadIndent = 30;
    paragraphStyle.lineSpacing = 3;
    [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributeString.length)];
    contentLabel.attributedText = attributeString;
    
    [dialogContentView addSubview:contentLabel];
    
    _containerView = dialogContentView;
}

@end
