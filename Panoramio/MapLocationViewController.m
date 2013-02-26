//
//  MapLocationViewController.m
//  Panoramio
//
//  Created by lily on 2/25/13.
//
//

#import "MapLocationViewController.h"
#import "FetchPhotoResult.h"
#import "pointAnnotation.h"
#import "PhotoViewController.h"
#import "LocalImageManager.h"
#import "GlobalConfiguration.h"
#import <CoreLocation/CoreLocation.h>
#import "FullSizePhotoViewController.h"

@interface MapLocationViewController ()
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *annotations;
@end

@implementation MapLocationViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize annotations = _annotations;
@synthesize mapView = _mapView;

- (void) updateMapView{
    //    @synchronized(self.mapView.annotations){
    if (self.mapView.annotations)
        [self.mapView removeAnnotations: self.mapView.annotations];
    if (self.annotations)
        [self.mapView addAnnotations:self.annotations];
    //    }
}

-(void) setMapView:(MKMapView *)mapView{
    _mapView = mapView;
    [self updateMapView];
}

- (void) setAnnotations:(NSArray *)annotations{
    @synchronized(self.annotations){
        _annotations = annotations;
    }
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
	// Do any additional setup after loading the view.
    
    self.mapView.delegate = self;
    
    MKCoordinateSpan span = {.latitudeDelta =  50, .longitudeDelta =  50};
    CLLocationCoordinate2D coordinate = {.latitude= 20, .longitude= -100};
    
    //update coordinate by photoId
    if (self.photoId != nil) {
        NSError *error;
        FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
        
        fetchPhoto.photoId = self.photoId;
        NSFetchedResultsController *fetchedResultsController = [fetchPhoto fetchedResultsController];
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        PhotoInfo *photoInfo = [fetchedResultsController objectAtIndexPath:indexPath];
        coordinate.latitude = [photoInfo.latitude doubleValue];
        coordinate.longitude = [photoInfo.longtitude doubleValue];
        //        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc]
        //                                            initWithTarget:self action:@selector(handleMapTap:)];
        //        [self.mapView addGestureRecognizer:imageTap];
    }else{
        UIPinchGestureRecognizer* mapPinch = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleMapChange:)];
        [mapPinch setDelegate:self];
        [self.mapView addGestureRecognizer:mapPinch];
        UIPanGestureRecognizer* mapPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleMapChange:)];
        [mapPan setDelegate:self];
        [self.mapView addGestureRecognizer:mapPan];
    }
    
    MKCoordinateRegion region = {coordinate, span};
    [self.mapView setRegion:region animated:YES];
    
    [self updateMap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (void)updateMap
{
    //dispatch_queue_t fetchQ = dispatch_queue_create("data fetcher", NULL);
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    fetchPhoto.photoId = _photoId;
    _fetchedResultsController = [fetchPhoto fetchedResultsController];
    
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSMutableArray *mutableAnnotations = [NSMutableArray array];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
    pointAnnotation *pointAnnt = [[pointAnnotation alloc]init];
    CLLocationCoordinate2D coordinate = {.latitude= [photoInfo.latitude doubleValue], .longitude= [photoInfo.longtitude doubleValue]};
    pointAnnt.photoId = photoInfo.photoId;
    pointAnnt.photoIndex = 0;
    pointAnnt.coordinate = coordinate;
    [mutableAnnotations addObject:pointAnnt];
    
    self.annotations = mutableAnnotations;
    mutableAnnotations = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (UIImage *)addBorderToImage:(UIImage *)image {
	CGImageRef bgimage = [image CGImage];
	float width = CGImageGetWidth(bgimage);
	float height = CGImageGetHeight(bgimage);
	
    // Create a temporary texture data buffer
	void *data = malloc(width * height * 4);
	
	// Draw image to buffer
	CGContextRef ctx = CGBitmapContextCreate(data,
                                             width,
                                             height,
                                             8,
                                             width * 4,
                                             CGImageGetColorSpace(image.CGImage),
                                             kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(ctx, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height), bgimage);
	
	//Set the stroke (pen) color
	CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
	//Set the width of the pen mark
	CGFloat borderWidth = (float)width*0.05;
	CGContextSetLineWidth(ctx, borderWidth);
    
	//Start at 0,0 and draw a square
	CGContextMoveToPoint(ctx, 0.0, 0.0);
	CGContextAddLineToPoint(ctx, 0.0, height);
	CGContextAddLineToPoint(ctx, width, height);
	CGContextAddLineToPoint(ctx, width, 0.0);
	CGContextAddLineToPoint(ctx, 0.0, 0.0);
	
	//Draw it
	CGContextStrokePath(ctx);
    
    // write it to a new image
	CGImageRef cgimage = CGBitmapContextCreateImage(ctx);
	UIImage *newImage = [UIImage imageWithCGImage:cgimage];
	CFRelease(cgimage);
	CGContextRelease(ctx);
	
    // auto-released
	return newImage;
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    NSString *photoId = ((pointAnnotation*)annotation).photoId;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:((pointAnnotation*)annotation).photoIndex inSection:0];
    PhotoInfo *annotationPhoto = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    //        NSData* imageData = [LocalImageManager getLocalImageByPhotoId: photoId];
    NSData* imageData = annotationPhoto.imageData;
    if (annotationPhoto.imageData != nil) {
        UIImage *image = [UIImage imageWithData:imageData];
        image = [self addBorderToImage:image];
        pav.image = [self resizeImage:image newSize:CGSizeMake(25, 20)];
    }else {
        NSString *urlString = [NSString stringWithFormat:@"%@%@.jpg", webServerPrefix,((pointAnnotation*)annotation).photoId];
        NSURL *imageURL = [NSURL URLWithString: urlString];
        
        dispatch_queue_t localQ = dispatch_queue_create("data fetcher", NULL);
        
        dispatch_async(localQ, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            pav.image = [self resizeImage:image newSize:CGSizeMake(25, 20)];
            [LocalImageManager saveLocalImageByPhotoId:photoId withImage:image];
        });
    }
    return pav;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end


