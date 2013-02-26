//
//  FullSizePhotoViewController.m
//  Panoramio
//
//  Created by lily on 2/21/13.
//
//

#import "FullSizePhotoViewController.h"
#import "LocalImageManager.h"
#import "GlobalConfiguration.h"
#import "PhotoInfo.h"
#import "social/Social.h"
#import "accounts/Accounts.h"
#import "MapViewController.h"
#import <QuartzCore/CALayer.h>

@interface FullSizePhotoViewController ()
@property (strong, nonatomic) IBOutlet UITextField *photoTextInfo;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSMutableDictionary *imageSet;
@property (nonatomic) NSMutableData *receivedData;
@property (nonatomic) NSInteger photoCount;
@property float scrollBeginOffset;
@property (nonatomic) NSInteger beginPhotoIndex;
@property (nonatomic) NSInteger endPhotoIndex;
@property (nonatomic) float imageViewHeight;
@property (nonatomic) UIImage* favoriteImage;
@property PhotoInfo *photoInfo;
@property UIImage *image;
@end

@implementation FullSizePhotoViewController
@synthesize scrollView = _scrollView;
@synthesize photoIndex = _photoIndex;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize connection = _connection;
@synthesize imageSet = _imageSet;
@synthesize receivedData = _receivedData;
@synthesize photoCount = _photoCount;
@synthesize scrollBeginOffset = _scrollBeginOffset;
@synthesize beginPhotoIndex = _beginPhotoIndex;
@synthesize endPhotoIndex = _endPhotoIndex;
@synthesize imageViewHeight = _imageViewHeight;
@synthesize favoriteImage = _favoriteImage;
@synthesize photoInfo = _photoInfo;
@synthesize photoTextInfo;
@synthesize image = _image;

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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    NSLog(@"%f %f", _scrollView.bounds.size.height, self.tabBarController.tabBar.bounds.size.height);
    _imageViewHeight = _scrollView.bounds.size.height;// - self.tabBarController.tabBar.bounds.size.height;
    self.scrollView.delegate=self;
    _photoCount = [[_fetchedResultsController fetchedObjects]count];
    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width * (_photoCount), _scrollView.bounds.size.height)];
    _imageSet = [[NSMutableDictionary alloc] init];
    _beginPhotoIndex = _photoIndex;
    _endPhotoIndex = _photoIndex;
    [self imageAtIndex:_photoIndex];
    if (_photoIndex-1 >= 0) {
        [self imageAtIndex:_photoIndex-1];
        _beginPhotoIndex--;
        
    }
    if (_photoIndex+1 < _photoCount){
        [self imageAtIndex:_photoIndex+1];
        _endPhotoIndex++;
    }
    [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width*_photoIndex, 0)];
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc]
                     initWithTarget:self action:@selector(handlePhotoTap:)];
    [_scrollView addGestureRecognizer:imageTap];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_photoIndex inSection:0];
    _photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
    photoTextInfo.text = _photoInfo.location;
    if([_photoInfo.isFavorite intValue] == 1)
        _favoriteImage = [UIImage imageNamed:@"redheartSmall.png"];
    else
        _favoriteImage = [UIImage imageNamed:@"greyheart.png"];
    CGRect frameimg = CGRectMake(0, 12, _favoriteImage.size.width-6, _favoriteImage.size.height-8);
    UIButton *addFavButton = [[UIButton alloc] initWithFrame:frameimg];
    [addFavButton setBackgroundImage:_favoriteImage forState:UIControlStateNormal];
    [addFavButton addTarget:self action:@selector(addFavorite)
           forControlEvents:UIControlEventTouchUpInside];
    [addFavButton setShowsTouchWhenHighlighted:YES];
    
    UIImage *sharedImage = [UIImage imageNamed:@"ActionButton.png"];
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, sharedImage.size.width-4, sharedImage.size.height-6)];
    shareButton.titleLabel.text = @"share";
    [shareButton setBackgroundImage:sharedImage forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(tapSharedButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *locationImg = [UIImage imageNamed:@"mapdropround.png"];
    UIButton *showLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, locationImg.size.width, locationImg.size.height)];
    [showLocationButton setBackgroundImage:locationImg forState:UIControlStateNormal];
    [showLocationButton addTarget:self action:@selector(showLocation) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *favButton =[[UIBarButtonItem alloc] initWithCustomView:addFavButton];
    UIBarButtonItem *shareItem =[[UIBarButtonItem alloc] initWithCustomView:shareButton];
    UIBarButtonItem *showLocation = [[UIBarButtonItem alloc] initWithCustomView:showLocationButton];
    
    
    //add space between fav button and location button
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = 15;
    
    
    NSArray *barButtonItems = [NSArray arrayWithObjects:shareItem,spaceItem,showLocation,spaceItem,favButton, nil];
    
    self.navigationItem.rightBarButtonItems = barButtonItems;
    
    self.photoTextInfo.text = _photoInfo.location;
    
}

- (void)viewWillAppear:(BOOL)animated
{
 //   [self.tabBarController.tabBar setHidden:YES];
}

- (void)updateFavoriteImageView
{
    UIImage *favoriteImage;
    UIButton *favButton = [[self.navigationItem.rightBarButtonItems objectAtIndex:4] customView];
    if ([_photoInfo.isFavorite intValue] == 1) {
        favoriteImage = [UIImage imageNamed:@"redheartSmall.png"];
    }else{
        favoriteImage = [UIImage imageNamed:@"greyheart.png"];
    }
    [favButton setBackgroundImage:favoriteImage forState:UIControlStateNormal];
}

- (void)showLocation
{
    [self performSegueWithIdentifier:@"showLocation" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLocation"]) {
        MapViewController *mapVC = segue.destinationViewController;
        mapVC.photoId = _photoInfo.photoId;
    }
}

- (void)addFavorite
{
    PlanetViewAppDelegate *pvDelegate = (((PlanetViewAppDelegate*) [UIApplication sharedApplication].delegate));
    NSError *error;
    UIImage *favoriteImage;
    UIButton *favButton = [[self.navigationItem.rightBarButtonItems objectAtIndex:4] customView];
    if ([_photoInfo.isFavorite intValue] == 1) {
        _photoInfo.isFavorite = [NSNumber numberWithInt:0];
//        favoriteImage = [UIImage imageNamed:@"greyheartSmall.png"];
    }else{
        _photoInfo.isFavorite = [NSNumber numberWithInt:1];
//        favoriteImage = [UIImage imageNamed:@"redheartSmall.png"];
    }
//    [favButton setBackgroundImage:favoriteImage forState:UIControlStateNormal];
    if (![pvDelegate.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self updateFavoriteImageView];
}

-(void) tapSharedButton
{
    // open a dialog with just an OK button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Facebook", @"Twitter", @"Weibo", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *serviceType;
    
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        return;
    } else if (buttonIndex == 0) {
        NSLog(@"facebook");
        serviceType = SLServiceTypeFacebook;
    } else if (buttonIndex == 1) {
        NSLog(@"Twitter");
        serviceType = SLServiceTypeTwitter;
    } else if (buttonIndex == 2) {
        NSLog(@"weibo");
        serviceType = SLServiceTypeSinaWeibo;
    }
    
    if([SLComposeViewController isAvailableForServiceType:serviceType]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                
            } else
                
            {
                NSLog(@"Done");
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler =myBlock;
        
        //Adding the Text to the facebook post value from iOS
        [controller setInitialText:@"Hi, i would like to share with you about this nice photo"];
        
        //Adding the URL to the facebook post value from iOS
        [controller addURL:[NSURL URLWithString:@"http://www.panoramio.com"]];
        
        [controller addImage:self.image];
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        NSLog(@"UnAvailable");
    }
}

//set enable user interaction in storyboard;
-(void)handlePhotoTap: (UIGestureRecognizer*) gesture
{
    if (self.navigationController.navigationBarHidden == YES) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
//        photoTextInfo.text = _photoInfo.location;
        
    }else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
//        photoTextInfo.text = nil;
    }
    
}



- (void) imageAtIndex:(NSUInteger) photoIndex
{
    if(photoIndex>=[[self.fetchedResultsController fetchedObjects]count])
        return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
    PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSData *getLocalData = [LocalImageManager getLocalImageByPhotoId:photoInfo.photoId];
    if (getLocalData != nil) {
        [self displayImage:[UIImage imageWithData:getLocalData] withPageIndex: photoIndex];
    }else{
        NSString *urlString = [NSString stringWithFormat:@"%@%@.jpg", webServerPrefix, photoInfo.photoId];
        [self sendGetPhotoDataRequest:urlString withPhotoIndex:photoIndex];
    }
    return;
}


- (void)sendGetPhotoDataRequest:(NSString*)urlString withPhotoIndex:(int)photoIndex
{
    NSURL *imageURL = [NSURL URLWithString: urlString];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    _connection = [[NSURLConnection alloc ] initWithRequest:theRequest delegate:self];
    
    _receivedData = [[NSMutableData alloc ] init];
    
    NSMutableDictionary *dataAndPhotoIndex = [[NSMutableDictionary alloc] init];
    [dataAndPhotoIndex setObject:_receivedData forKey:[NSString stringWithFormat:@"%d", photoIndex]];
    NSMutableDictionary *imageAndURL = [[NSMutableDictionary alloc] init];
    [imageAndURL setObject:dataAndPhotoIndex forKey:urlString];
    [_imageSet setObject:imageAndURL forKey:_connection.description];
    dataAndPhotoIndex = nil;
    imageAndURL = nil;
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if (httpResponse.statusCode != 200) {
        NSString *urlString = [[[_imageSet objectForKey:connection.description]allKeys] objectAtIndex:0];
        NSArray *photoIdStr = [urlString componentsSeparatedByString:webServerPrefix];
        NSMutableDictionary *imageAndURL = [_imageSet objectForKey:connection.description];
        NSString *newUrlString = [NSString stringWithFormat:@"%@%@", [GlobalConfiguration settingNewWebServerPrefix], [photoIdStr objectAtIndex:1]];
        if ([urlString isEqualToString: newUrlString]) {
            return;
        }
        int index = [[[[[imageAndURL allValues] objectAtIndex:0] allKeys]objectAtIndex:0] intValue];
        [self sendGetPhotoDataRequest:newUrlString withPhotoIndex:index];
        [_imageSet removeObjectForKey:connection.description];
        [self setConnection: nil];
        return;
    }
    NSMutableDictionary *imageAndRUL = [_imageSet objectForKey:connection.description];
    NSMutableData *theReceived = [[[imageAndRUL objectForKey:response.URL] allValues]objectAtIndex:0];
    [theReceived setLength:0];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableDictionary *imageAndRUL = [_imageSet objectForKey:connection.description];
    NSMutableData *theReceived = [[[[imageAndRUL allValues] objectAtIndex:0] allValues]objectAtIndex:0];
    [theReceived appendData:data];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSMutableData *theReceived = [_imageSet objectForKey:[connection description]];
    theReceived = nil;
    connection = nil;
    NSLog(@"connection failed,ERROR %@", [error localizedDescription]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *imageAndURL = [_imageSet objectForKey:connection.description];
    if (imageAndURL == nil) {
        return;
    }
    
    NSMutableData *theReceived = [[[[imageAndURL allValues] objectAtIndex:0] allValues]objectAtIndex:0];
    
    UIImage* localimage = [UIImage imageWithData:theReceived];
    
    if (theReceived == nil) {
        NSLog(@"No image data");
    }
    
    int photoIndex = [[[[[imageAndURL allValues] objectAtIndex:0] allKeys]objectAtIndex:0] intValue];
    [self displayImage:[UIImage imageWithData:theReceived] withPageIndex:photoIndex];
    
    //store to local
    NSString *urlString = [[imageAndURL allKeys] objectAtIndex:0];
    NSArray *components = [urlString componentsSeparatedByString:[NSString stringWithFormat:@"%@",webServerPrefix]];
    NSString *photoIdStr = [components objectAtIndex:1];
    NSString *photoId = [[photoIdStr componentsSeparatedByString:@".jpg"]objectAtIndex:0];
    [LocalImageManager saveLocalImageByPhotoId:photoId withImage:localimage];
    
    [_imageSet removeObjectForKey:connection.description];
    [self setConnection: nil];
    
}

- (void) displayImage:(UIImage *)image withPageIndex:(NSInteger)pageIndex
{
    if (image == nil) {
        return;
    }
    self.image = image;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(_scrollView.bounds.size.width*pageIndex, 0, _scrollView.bounds.size.width, _imageViewHeight);
    [imageView.layer setBorderWidth:5.0];
    [imageView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [_scrollView addSubview:imageView];
    imageView = nil;
    image = nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _scrollBeginOffset = scrollView.contentOffset.x;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((_scrollBeginOffset < _scrollView.contentOffset.x)&&(_scrollView.contentOffset.x != 0.0) && (_scrollView.contentOffset.x != -0.0)&&(_photoIndex<_photoCount-1)) {
        _photoIndex++;
        [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width*_photoIndex, 0)];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_photoIndex inSection:0];
        _photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
        self.photoTextInfo.text = _photoInfo.location;
        [self updateFavoriteImageView];
        if ((_endPhotoIndex +1 < _photoCount) &&(_endPhotoIndex == _photoIndex)) {
            _endPhotoIndex++;
            [self imageAtIndex:_endPhotoIndex];
            for (UIImageView *imageView in [_scrollView subviews]) {
                float distance = imageView.frame.origin.x-5 - _scrollView.bounds.size.width * _beginPhotoIndex;
                if ((distance<(float)10.0) && (distance > (float)(-10.0))) {
                    [imageView removeFromSuperview];
                    imageView.image = nil;
                    _beginPhotoIndex++;
                    break;
                }
            }
        }

    }else if((_scrollBeginOffset > _scrollView.contentOffset.x)&&(_photoIndex>0)){
        _photoIndex--;
        [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width*_photoIndex, 0)];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_photoIndex inSection:0];
        _photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
        self.photoTextInfo.text = _photoInfo.location;
        [self updateFavoriteImageView];
        if ((_beginPhotoIndex - 1 >= 0)&&(_beginPhotoIndex == _photoIndex)) {
            _beginPhotoIndex--;
            [self imageAtIndex:_beginPhotoIndex];
            for (UIImageView *imageView in [_scrollView subviews]) {
                float distance = imageView.frame.origin.x-5 - _scrollView.bounds.size.width * _endPhotoIndex;
                if ((distance<(float)10.0) && (distance > (float)(-10.0))) {
                    [imageView removeFromSuperview];
                    imageView.image = nil;
                    _endPhotoIndex--;
                    break;
                }
            }
        }
    }else{
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
