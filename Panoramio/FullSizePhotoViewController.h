//
//  FullSizePhotoViewController.h
//  Panoramio
//
//  Created by lily on 2/21/13.
//
//

#import <UIKit/UIKit.h>
#import "FetchPhotoResult.h"

@interface FullSizePhotoViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic) NSInteger photoIndex;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end
