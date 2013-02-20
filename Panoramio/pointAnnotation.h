//
//  pointAnnotation.h
//  Panoramio
//
//  Created by lily on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface pointAnnotation : NSObject<MKAnnotation>
- (pointAnnotation*) annotationForPhotowithCoordinate: (CLLocationCoordinate2D)coordinate;
@property CLLocationCoordinate2D coordinate;
@property NSString *photoId;
@property NSInteger *photoIndex;
@end
