//
//  ShowLocationViewController.m
//  Panoramio Planet
//
//  Created by fili on 1/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ShowLocationViewController.h"
#import "FetchPhotoResult.h"

@interface ShowLocationViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) NSCache *imageCache;
@end

@implementation ShowLocationViewController
@synthesize scrollView = _scrollView;
@synthesize currentPhotoIndex;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize imageCache;

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
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    _fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    self.scrollView.delegate=self;
    currentPhotoIndex = 0;
    for(currentPhotoIndex = 0; currentPhotoIndex < 10; currentPhotoIndex++){
        [self addPhoto:_scrollView index:currentPhotoIndex];
    }
    UIPanGestureRecognizer* photoPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
  //  [photoPan setDelegate:self];
  //  [self.scrollView addGestureRecognizer:photoPan];
}
-(void) handlePan:(UIGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"test");
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
    currentPhotoIndex++;
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width*(currentPhotoIndex+1), _scrollView.bounds.size.height);
    _scrollView.contentOffset = CGPointMake(_scrollView.bounds.size.width*currentPhotoIndex, 0); 
    [self addPhoto:self.scrollView index:currentPhotoIndex];
    }
}
- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
}

- (void) addPhoto:(UIScrollView *)scrollView index:(int)photoIndex{
    if (self.imageCache == nil) {
        self.imageCache = [[NSCache alloc] init];
    } 
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
    PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width*currentPhotoIndex, 0, scrollView.frame.size.width*(currentPhotoIndex+1), scrollView.frame.size.height)];
    [self.scrollView addSubview:imageView];
    NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg",photoInfo.photoId];
    NSURL *imageURL = [NSURL URLWithString: urlString];
    
//    NSData *imageData = [self.imageCache objectForKey:[NSNumber numberWithInt:photoIndex]];
/*    if(imageData != nil){
        UIImage *image = [UIImage imageWithData:imageData]; 
        imageView.image = image;
    }else{*/
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    //    [self.imageCache setObject:imageData forKey:[NSNumber numberWithInt:photoIndex]]; 
        UIImage *image = [UIImage imageWithData:imageData]; 
        imageView.image = image; 
//    }
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width*(currentPhotoIndex+1), _scrollView.bounds.size.height);
    _scrollView.contentOffset = CGPointMake(_scrollView.bounds.size.width*currentPhotoIndex, 0); 
}

@end
