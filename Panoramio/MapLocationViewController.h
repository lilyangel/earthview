//
//  MapLocationViewController.h
//  Panoramio
//
//  Created by lily on 2/25/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapLocationViewController : UIViewController<MKMapViewDelegate, UIGestureRecognizerDelegate, UITabBarControllerDelegate>
@property NSString *photoId;
@end
