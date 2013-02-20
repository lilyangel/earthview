//
//  LocalImageManager.h
//  Panoramio
//
//  Created by lily on 2/15/13.
//
//

#import <Foundation/Foundation.h>

@interface LocalImageManager : NSObject
+(NSData*)getLocalImageByPhotoId:(NSString*)photoId;

+(void)saveLocalImageByPhotoId:(NSString*)photoId withImage:(UIImage *)image;

@end
