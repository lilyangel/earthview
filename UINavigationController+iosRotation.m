//
//  UINavigationController+iosRotation.m
//  Panoramio
//
//  Created by lily on 2/6/13.
//
//

#import "UINavigationController+iosRotation.h"

@implementation UINavigationController (iosRotation)
-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
@end
