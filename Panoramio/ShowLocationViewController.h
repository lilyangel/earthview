//
//  ShowLocationViewController.h
//  Panoramio Planet
//
//  Created by fili on 1/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowLocationViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property int currentPhotoIndex;
@property (nonatomic, strong) NSString* photoId;
@end
