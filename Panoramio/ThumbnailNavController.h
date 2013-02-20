//
//  ThumbnailNavController.h
//  Panoramio
//
//  Created by lily on 2/6/13.
//
//

#import <UIKit/UIKit.h>

@interface ThumbnailNavController: UINavigationController <UINavigationControllerDelegate>
-(BOOL)shouldAutorotate;
-(NSUInteger)supportedInterfaceOrientations;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end
