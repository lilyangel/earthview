//
//  ThumbNailViewController.m
//  Panoramio Planet
//
//  Created by fili on 12/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbNailViewController.h"
@interface ThumbNailViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ThumbNailViewController
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
	// Do any additional setup after loading the view.
    float imageSizeHeight = (_scrollView.frame.size.width-4)/self.column-1;
    super.imageHight = imageSizeHeight;
    super.imageWidth = imageSizeHeight;
    
    self.subImageTap = [[UITapGestureRecognizer alloc]
                        initWithTarget:self action:@selector(handleTap:)];
    super.row = (_scrollView.frame.size.height-2)/(imageSizeHeight+1) + 1 ;
    
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    fetchPhoto.isFavorite = NO;
    NSFetchedResultsController *fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [super setFetchedResultsController: fetchedResultsController];
}

@end
