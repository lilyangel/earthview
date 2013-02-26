//
//  ThumbNailSuperViewController.m
//  Panoramio
//
//  Created by lily on 2/9/13.
//
//

#import "ThumbNailSuperViewController.h"
#import "PlanetViewAppDelegate.h"
#import "PhotoInfo.h"
#import "ShowLocationViewController.h"
#import "LocalImageManager.h"
#import <malloc/malloc.h>
#import "GlobalConfiguration.h"
#import "FullSizePhotoViewController.h"

@interface ThumbNailSuperViewController ()
@property PlanetViewAppDelegate *pvDelegate;
@property dispatch_queue_t fetchQ;
@property NSInteger didCount;
@property NSTimer *storeDBTimer;
@property dispatch_queue_t storeDBQ;
@property (nonatomic,strong) NSCache *imageCache;
@property NSInteger currentListPage;
@property NSInteger currentPhotoIndex;
@property NSString *photoId;
@property float scrollBeginOffset;

//global varible to pre-store all photoes.
@property (nonatomic) NSMutableDictionary *imageSet;
@property (nonatomic) NSMutableData *receivedData;
@property (nonatomic) NSURLConnection *connection;
@property NSInteger pagePhotoCount;

@end

@implementation ThumbNailSuperViewController
@synthesize scrollView = _scrollView;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize row;
@synthesize column;
@synthesize imageWidth = _imageWidth;
@synthesize imageHight = _imageHeight;
@synthesize imageCache;
@synthesize currentListPage;
@synthesize photoId;
@synthesize scrollBeginOffset = _scrollBeginOffset;
@synthesize isEnd;
@synthesize pvDelegate;
@synthesize fetchQ = _fetchQ;
@synthesize imageSet = _imageSet;
@synthesize receivedData = _receivedData;
@synthesize connection = _connection;
@synthesize didCount;
@synthesize storeDBTimer = _storeDBTimer;
@synthesize storeDBQ;
@synthesize pagePhotoCount;

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
    self.row = 6;
    self.column = 4;
    self.isEnd = NO;
    self.pvDelegate = (((PlanetViewAppDelegate*) [UIApplication sharedApplication].delegate));
    _imageSet = [[NSMutableDictionary alloc] init];
    
    self.didCount = 0;
    self.currentListPage = 0;
//    _fetchQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
}

- (void)fetchPhotoData
{
    NSError *error;
    FetchPhotoResult *fetchPhoto = [FetchPhotoResult init];
    fetchPhoto.isFavorite = NO;
    _fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    fetchPhoto = nil;
}

-(void) handleTap:(UIGestureRecognizer*) gesture
{
    CGPoint touchPoint=[gesture locationInView:_scrollView];
    
    int photoIndex = self.column * ((int)(touchPoint.y/(_imageHeight+1)))+((int)touchPoint.x/(_imageWidth+1));
    //NSLog(@"%d, %f", photoIndex, touchPoint.y);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
    [self fetchPhotoData];
    if (photoIndex < [[_fetchedResultsController fetchedObjects] count]) {
        PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
        self.photoId = photoInfo.photoId;
        //[self performSegueWithIdentifier:@"showPhotoDetail" sender:self];
        self.currentPhotoIndex = photoIndex;
        [self performSegueWithIdentifier:@"showFullPhoto" sender:self];
        
    }
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 //   if ([segue.identifier isEqualToString:@"showPhotoDetail"]) {
    if ([segue.identifier isEqualToString:@"showFullPhoto"]) {
//
//        ShowLocationViewController *photoVC = segue.destinationViewController;
//        photoVC.currentPhotoIndex = self.currentPhotoIndex;
//        photoVC.photoId = self.photoId;
        FullSizePhotoViewController *fsPhotoVC = segue.destinationViewController;
        fsPhotoVC.fetchedResultsController = _fetchedResultsController;
        fsPhotoVC.photoIndex = self.currentPhotoIndex;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //[self downloadMoreImages:40];
    //[self printPhotoWithPageIndex:0];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    for (UIImageView *tmpview in _scrollView.subviews){
        [tmpview removeFromSuperview];
    }
    [_imageSet removeAllObjects];
    _imageSet = nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

//-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _scrollBeginOffset = _scrollView.contentOffset.x;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((_scrollBeginOffset < _scrollView.contentOffset.y)&&(_scrollView.contentOffset.y != 0.0) && (_scrollView.contentOffset.y != -0.0)){
        
        [self fetchPhotoData];
        currentListPage++;
        [self printPhotoWithPageIndex:currentListPage];
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, (self.row*_imageHeight)*(currentListPage+1))];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}



- (void)printPhotoWithPageIndex:(int)pageIndex
{
    
    if (self.isEnd) {
        return;
    }
    
    int photoCount = [[_fetchedResultsController fetchedObjects]count];
    
    for (int rowIndex = 0; rowIndex<self.row; rowIndex++) {
        for(int columnIndex = 0; columnIndex< self.column; columnIndex++){
            int photoIndex = rowIndex*self.column + columnIndex+pageIndex*self.row*self.column;
            if (photoIndex >= photoCount) {
                self.isEnd = true;
                break;
            }
            
            UIImageView* imageView = [[UIImageView alloc ] initWithFrame:CGRectMake(2.5+columnIndex*(_imageWidth+1), 1+rowIndex*(_imageHeight+1)+pageIndex*(_imageHeight+1)*self.row, _imageWidth, _imageHeight)];
            imageView.image = [UIImage imageNamed:@"arrow_down.png"];
            [self.scrollView addSubview:imageView];
            
            
            if(_imageSet != nil){
                if([_imageSet count] > photoIndex){
                    //NSLog(@"image debug");
                    //imageView.image = [UIImage imageWithData:[_imageSet objectAtIndex:photoIndex]];
                }
            }else{
                NSLog(@"image set not exist");
            }
            imageView =nil;
        }
        if (self.isEnd) {
            break;
        }
    }
    int downloadCount = MIN(self.row*self.column, [[_fetchedResultsController fetchedObjects]count] - self.row*self.column*currentListPage);
    [self downloadOneFramePhoto:downloadCount];
}

-(void)downloadOneFramePhoto:(int)frameSize
{
    //call NSURLConnection to start the download
    int printCount = MIN(self.row*self.column, [[_fetchedResultsController fetchedObjects]count]-self.row*self.column*self.currentListPage);
    //    int printCount = frameSize*(self.currentListPage+1);
    if (printCount == self.row*self.column) {
        printCount = self.row*self.column*(self.currentListPage+1);
    }else{
        printCount = [[_fetchedResultsController fetchedObjects]count];
    }
    for (int index = self.row*self.column*self.currentListPage; index < printCount; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
        NSString* urlString = [NSString stringWithFormat:@"%@%@.jpg", webServerPrefix, photoInfo.photoId];
        //        if (photoInfo.imageData != nil) {
        //            UIImageView *tmpsubView = [[_scrollView subviews] objectAtIndex:(index)];
        //            tmpsubView.image = [UIImage imageWithData:photoInfo.imageData];
        //        }else{
        //        NSURL* imageURL = [NSURL URLWithString: urlString];
        //        NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
        //        _connection = [[NSURLConnection alloc ] initWithRequest:theRequest delegate:self];
        //
        //        _receivedData = [[NSMutableData alloc ] init];
        //        //[_imageSet setObject:_receivedData forKey:urlString];
        //        NSMutableDictionary* dataAndPhotoIndex = [[NSMutableDictionary alloc] init];
        //        [dataAndPhotoIndex setObject:_receivedData forKey:[NSString stringWithFormat:@"%d", index]];
        //        NSMutableDictionary* imageAndURL = [[NSMutableDictionary alloc] init];
        //        [imageAndURL setObject:dataAndPhotoIndex forKey:urlString];
        //        [_imageSet setObject:imageAndURL forKey:_connection.description];
        [self sendGetPhotoDataRequest:urlString withPhotoIndex:index];
        //       }
    }
}

- (void)sendGetPhotoDataRequest:(NSString*)urlString withPhotoIndex:(int)index
{
    NSURL* imageURL = [NSURL URLWithString: urlString];
    NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    _connection = [[NSURLConnection alloc ] initWithRequest:theRequest delegate:self];
    
    _receivedData = [[NSMutableData alloc ] init];
    //[_imageSet setObject:_receivedData forKey:urlString];
    NSMutableDictionary* dataAndPhotoIndex = [[NSMutableDictionary alloc] init];
    [dataAndPhotoIndex setObject:_receivedData forKey:[NSString stringWithFormat:@"%d", index]];
    NSMutableDictionary* imageAndURL = [[NSMutableDictionary alloc] init];
    [imageAndURL setObject:dataAndPhotoIndex forKey:urlString];
    [_imageSet setObject:imageAndURL forKey:_connection.description];
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
        NSString* newUrlString = [NSString stringWithFormat:@"%@%@", [GlobalConfiguration settingNewWebServerPrefix], [photoIdStr objectAtIndex:1]];
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

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *imageAndURL = [_imageSet objectForKey:connection.description];
    if (imageAndURL == nil) {
        return;
    }
    
    NSMutableData *theReceived = [[[[imageAndURL allValues] objectAtIndex:0] allValues]objectAtIndex:0];
    
    UIImage* localimage = [self resizeImage:[UIImage imageWithData:theReceived] newSize:CGSizeMake(self.imageWidth, self.imageHight)];
    
    if (theReceived == nil) {
        NSLog(@"No image data");
    }
    
    int photoIndex = [[[[[imageAndURL allValues] objectAtIndex:0] allKeys]objectAtIndex:0] intValue];
    
    UIImageView *tmpsubView = [[_scrollView subviews] objectAtIndex:(photoIndex)];
    if (tmpsubView != nil){
        tmpsubView.image = localimage;
    }else{
        NSLog(@"No image View");
    }
    [_imageSet removeObjectForKey:connection.description];
    [self setConnection: nil];
    
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
