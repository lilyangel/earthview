//
//  ThumbNailSuperViewController.h
//  Panoramio
//
//  Created by lily on 2/9/13.
//
//

#import <UIKit/UIKit.h>
#import "FetchPhotoResult.h"

@interface ThumbNailSuperViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate, UITabBarControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property float imageWidth;
@property float imageHight;
@property NSInteger const row;
@property NSInteger const column;
@property (nonatomic, strong) UITapGestureRecognizer *subImageTap;
@property Boolean isEnd;

- (void)fetchPhotoData;
- (void) handleTap:(UIGestureRecognizer*) gesture;
- (void)printPhotoWithPageIndex:(int)pageIndex;
- (void)downloadOneFramePhoto:(int)frameSize;
@end
