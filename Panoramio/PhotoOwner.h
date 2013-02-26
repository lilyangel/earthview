//
//  PhotoOwner.h
//  Panoramio
//
//  Created by lily on 2/23/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PhotoOwner : NSManagedObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;

@end
