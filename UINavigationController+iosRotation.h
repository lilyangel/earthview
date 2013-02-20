//
//  UINavigationController+iosRotation.h
//  Panoramio
//
//  Created by lily on 2/6/13.
//
//

#import <UIKit/UIKit.h>

@interface UINavigationController (iosRotation)
-(BOOL)shouldAutorotate;
-(NSUInteger)supportedInterfaceOrientations;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;
@end
