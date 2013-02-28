//
//  ShowLocationViewController.m
//  Panoramio Planet
//
//  Created by fili on 1/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ShowLocationViewController.h"
#import "FetchPhotoResult.h"
#import "pointAnnotation.h"
#import "LocalImageManager.h"
#import "GlobalConfiguration.h"
#import "FullSizePhotoViewController.h"

@interface ShowLocationViewController (){
    UIImageView* _zoomView;
    CGSize _imageSize;
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
}
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) NSCache *imageCache;
@property (nonatomic) UIPageControl * pageControl;
@property float offsetX;
@property int mapViewSpan;
@property int autoZoom;
@property double lat;
@property double lng;
@property (nonatomic) NSArray *annotations;
@property NSInteger pageIndex;
@property NSInteger currentDisplayPhoto;
@property float scrollBeginOffset;
@property (nonatomic) UITapGestureRecognizer *imageTap;
@property (nonatomic) pointAnnotation *pointAnnt;
@property Boolean currentPhotoIsFavorite;
@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSMutableDictionary *imageSet;
@property (nonatomic) NSMutableData *receivedData;
@property (nonatomic) float scrollViewHight;
@end

@implementation ShowLocationViewController
@synthesize scrollView = _scrollView;
@synthesize currentPhotoIndex;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize imageCache;
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize pageIndex = _pageIndex;
@synthesize currentDisplayPhoto = _currentDisplayPhoto;
@synthesize scrollBeginOffset = _scrollBeginOffset;
@synthesize photoId = _photoId;
@synthesize imageTap;
@synthesize pointAnnt = _pointAnnt;
@synthesize currentPhotoIsFavorite;
@synthesize connection = _connection;
@synthesize imageSet = _imageSet;
@synthesize receivedData = _receivedData;
@synthesize scrollViewHight = _scrollViewHight;

- (void) updateMapView{
    @synchronized(self.mapView.annotations){
        if (self.mapView.annotations)
            [self.mapView removeAnnotations: self.mapView.annotations];
        if (self.annotations)
            [self.mapView addAnnotations:self.annotations];
    }
}

- (void) setMapView:(MKMapView *)mapView{
    _mapView = mapView;
    [self updateMapView];
}

- (void) setAnnotations:(NSArray *)annotations{
    _annotations = annotations;
    [self updateMapView];
}

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
    _scrollViewHight = self.scrollView.bounds.size.height - self.tabBarController.tabBar.bounds.size.height;
    self.mapView.delegate = self;
    self.mapViewSpan = 50;
    _imageSet = [[NSMutableDictionary alloc] init];
    
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    if (self.photoId) {
        fetchPhoto.photoId = self.photoId;
    }
    _fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.scrollView.delegate=self;
    
    _currentDisplayPhoto = currentPhotoIndex;
    
    _pageIndex = 0;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bouncesZoom = YES;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.pagingEnabled = YES;
    _zoomView = [[UIImageView alloc] init];
    [self imageAtIndex:currentPhotoIndex];
    currentPhotoIndex++;
    if (currentPhotoIndex < [[self.fetchedResultsController fetchedObjects]count]) {
        _pageIndex++;
        [self imageAtIndex:currentPhotoIndex];
    }
    [_scrollView addSubview:_zoomView];
    [_scrollView setContentSize:CGSizeMake(320*(_pageIndex+1), _scrollView.frame.size.height)];
    [_scrollView setContentSize:CGSizeMake(320*2000, _scrollView.frame.size.height)];
    self.offsetX = 0.0;
    [self updateMapInfo];
    
    self.imageTap = [[UITapGestureRecognizer alloc]
                     initWithTarget:self action:@selector(handlePhotoTap:)];
    [self.scrollView addGestureRecognizer:imageTap];
}

-(void)handlePhotoTap: (UIGestureRecognizer*) gesture
{
    [self performSegueWithIdentifier:@"showFullPhoto" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showFullPhoto"]) {
        FullSizePhotoViewController *fsPhotoVC = segue.destinationViewController;
        fsPhotoVC.photoIndex = _currentDisplayPhoto;
        fsPhotoVC.fetchedResultsController = _fetchedResultsController;
    }
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
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
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    float boundsWidth = self.scrollView.bounds.size.width;
    float boundHeight = _scrollViewHight;
    CGFloat widthScale = image.size.width/boundsWidth;
    CGFloat heightScale = image.size.height/boundHeight;
    NSInteger newImageHeight, newImageWidth;
    if (widthScale>=heightScale) {
        newImageHeight = boundsWidth*(image.size.height/image.size.width);
        newImageWidth = boundsWidth;
    }else{
        newImageHeight = boundHeight;
        newImageWidth = boundHeight*(image.size.width/image.size.height);
    }
    
    image = [self resizeImage:image newSize:CGSizeMake(newImageWidth, newImageHeight)];
    if (widthScale>=heightScale) {
        imageView.frame = CGRectMake(boundsWidth*pageIndex,(boundHeight- newImageHeight)/2, newImageWidth, newImageHeight);
    }else{
        imageView.frame = CGRectMake(boundsWidth*pageIndex+(boundsWidth - newImageWidth)/2, 0, newImageWidth, newImageHeight);
    }
    [_zoomView addSubview: imageView];
    imageView = nil;
    image = nil;
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

- (void) updateRegionWithCoordinate:(CLLocationCoordinate2D) coordinate{
    MKCoordinateSpan span = {.latitudeDelta =  self.mapViewSpan, .longitudeDelta =  self.mapViewSpan};
    MKCoordinateRegion region = {coordinate, span};
    [self.mapView setRegion:region animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _scrollBeginOffset = scrollView.contentOffset.x;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((_scrollBeginOffset < _scrollView.contentOffset.x)&&(_scrollView.contentOffset.x != 0.0) && (_scrollView.contentOffset.x != -0.0)) {
        currentPhotoIndex++;
        _pageIndex++;
        [_scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width*(_pageIndex+1), _scrollView.frame.size.height)];
        self.offsetX = _scrollView.contentOffset.x;
        [self imageAtIndex:currentPhotoIndex];
        _currentDisplayPhoto++;
    }else if(_scrollBeginOffset > _scrollView.contentOffset.x){
        if(_currentDisplayPhoto>0){
            _currentDisplayPhoto--;
        }
    }else{
        return;
    }
    [self updateMapInfo];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pav.image = [UIImage imageNamed:@"location.png"];    //as suggested by Squatch
    return pav;
}

- (NSArray*) mapAnnotationwithCoordinate:(CLLocationCoordinate2D) coordinate
{
    NSMutableArray *annotations = [NSMutableArray array];
    pointAnnotation *pointAnnt = [[pointAnnotation alloc]init];
    pointAnnt.coordinate = coordinate;
    [annotations addObject:pointAnnt];
    return annotations;
}

- (void) updateMapInfo
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentDisplayPhoto inSection:0];
    PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSArray *components = [photoInfo.position componentsSeparatedByString:@","];
    self.lat = [[components objectAtIndex:0] doubleValue];
    self.lng = [[components objectAtIndex:1] doubleValue];
    _photoId = photoInfo.photoId;
    self.currentPhotoIsFavorite = photoInfo.isFavorite;
    CLLocationCoordinate2D coordinate = {.latitude= self.lat, .longitude= self.lng};
    self.annotations = [self mapAnnotationwithCoordinate:coordinate];
    [self updateRegionWithCoordinate:coordinate];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
