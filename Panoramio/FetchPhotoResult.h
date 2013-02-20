//
//  FetchPhotoResult.h
//  Panoramio Planet
//
//  Created by fili on 1/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlanetViewAppDelegate.h"
#import "PhotoInfo.h"

@interface  FetchPhotoResult :NSObject{
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    float southWestLat, southWestLng, northEastLat, northEastLng;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property float southWestLat, southWestLng, northEastLat, northEastLng;
@property Boolean isFavorite;
@property NSString *photoId;
//- (NSFetchedResultsController *)fetchedResultsController;
@end
