//
//  PhotoViewController.h
//  Panoramio
//
//  Created by lily on 1/13/13.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface PhotoViewController : UIViewController<UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic,readwrite) NSString* photoId;
@property Boolean isFavorite;
@end
