//
//  GlobalConfiguration.h
//  Panoramio
//
//  Created by lily on 2/18/13.
//
//

#import <Foundation/Foundation.h>

extern NSString *webServerPrefix;
extern NSString *setWebServerURL;
@interface GlobalConfiguration : NSObject
+ (NSString*)settingNewWebServerPrefix;
@end
