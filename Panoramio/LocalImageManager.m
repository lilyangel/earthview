//
//  LocalImageManager.m
//  Panoramio
//
//  Created by lily on 2/15/13.
//
//

#import "LocalImageManager.h"

@implementation LocalImageManager

+(NSData*)getLocalImageByPhotoId:(NSString*)photoId
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [NSString stringWithFormat:@"%@/%@.jpg", documentsDirectory, photoId];
    return [[NSFileManager defaultManager] contentsAtPath:getImagePath];
}

+(void)saveLocalImageByPhotoId:(NSString*)photoId withImage:(UIImage *)image
{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *jpegPath = [NSString stringWithFormat:@"%@/%@.jpg",dir, photoId];// this path if you want save reference path in sqlite
    NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
//    NSData *data = imageData;//1.0f = 100% quality
    [data writeToFile:jpegPath atomically:YES];
}

@end
