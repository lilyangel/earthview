//
//  PhotoInfo.h
//  Panoramio
//
//  Created by lily on 2/10/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhotoOwner;

@interface PhotoInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) PhotoOwner *whomtook;

@end
