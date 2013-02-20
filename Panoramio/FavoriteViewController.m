//
//  FavoriteViewController.m
//  Panoramio
//
//  Created by lily on 1/23/13.
//
//

#import "FavoriteViewController.h"
@interface FavoriteViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation FavoriteViewController
@synthesize scrollView = _scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    float imageSizeHeight = (_scrollView.frame.size.width-4)/self.column-1;
    super.imageHight = imageSizeHeight;
    super.imageWidth = imageSizeHeight;
    
    super.row = (_scrollView.frame.size.height-2)/(imageSizeHeight+1) + 1 ;
    
    self.subImageTap = [[UITapGestureRecognizer alloc]
                        initWithTarget:self action:@selector(handleTap:)];
    
    [self fetchPhotoData];
    //add UITabBarControllerDelegate
    PlanetViewAppDelegate* myDelegate = (((PlanetViewAppDelegate*) [UIApplication sharedApplication].delegate));
    UITabBarController *tabController = (UITabBarController *)myDelegate.window.rootViewController;
    tabController.delegate = self;
    self.scrollView.delegate=self;
    [self.scrollView setContentSize:self.scrollView.frame.size];
    [_scrollView addGestureRecognizer:self.subImageTap];
    NSArray *imageSubviews = _scrollView.subviews;
    for (UIView *subImageView in imageSubviews) {
        [subImageView removeFromSuperview];
    }
    [super setScrollView: _scrollView];
    [super printPhotoWithPageIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchPhotoData
{
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    fetchPhoto.isFavorite = YES;
    NSFetchedResultsController *fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    //int test = [[fetchedResultsController fetchedObjects] count];
    [super setFetchedResultsController: fetchedResultsController];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 3) {
        self.isEnd = NO;
        NSArray *imageSubviews = _scrollView.subviews;
        for (UIView *subImageView in imageSubviews) {
//            if (subImageView.frame.size.height == [super imageHight]) {
                [subImageView removeFromSuperview];
//            }
        }
        [self fetchPhotoData];
        [super printPhotoWithPageIndex:0];
    }
}

@end
