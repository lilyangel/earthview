//
//  FetchPhotoResult.m
//  Panoramio Planet
//
//  Created by fili on 1/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FetchPhotoResult.h"

//@interface FetchPhotoResult()
//@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
//@end

@implementation FetchPhotoResult
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize southWestLat;
@synthesize southWestLng;
@synthesize northEastLat;
@synthesize northEastLng;
@synthesize isFavorite;
@synthesize photoId;

- (id) init {
    self = [super init];
    if (self != nil) {
        // initializations go here.
        //   self.fetchedResultsController = [self fetchedResultsController];
    }
    return self;
}

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController
{
    PlanetViewAppDelegate *delegate = (((PlanetViewAppDelegate*) [UIApplication sharedApplication].delegate));
    self.managedObjectContext = delegate.managedObjectContext;
    
    // Create and configure a fetch request with the Book entity.
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoInfo" inManagedObjectContext:self.managedObjectContext];
    if ((southWestLat != northEastLat)&&(southWestLng != northEastLng)) {
 //       fetchRequest.predicat
        if ((northEastLng - southWestLng) < 180.00) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"latitude < %f and latitude > %f and longtitude < %f and longtitude > %f", northEastLat , southWestLat, northEastLng, southWestLng];
            fetchRequest.predicate = predicate;
        }else{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(longtitude > %f or longtitude < %f) and latitude < %f and latitude > %f", northEastLng, southWestLng, northEastLat, southWestLat];
            fetchRequest.predicate = predicate;
        }
    }
    if (isFavorite) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite = 1"];
        fetchRequest.predicate = predicate;
    }
    if (photoId != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(photoId = %@)",photoId];
        fetchRequest.predicate = predicate;
    }
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    //_fetchedResultsController.delegate = self;
   
    // Memory management.
    return _fetchedResultsController;
}    


@end
