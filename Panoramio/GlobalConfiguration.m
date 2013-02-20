//
//  GlobalConfiguration.m
//  Panoramio
//
//  Created by lily on 2/18/13.
//
//

#import "GlobalConfiguration.h"

NSString *webServerPrefix = @"http://mw2.google.com/mw-panoramio/photos/medium/";
NSString *setWebServerURL = @"http://getphotoserverurl.cloudfoundry.com";

@implementation GlobalConfiguration
+ (NSString*)settingNewWebServerPrefix
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:setWebServerURL]];
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    NSString *newServerURL = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
 //   return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];

    return newServerURL;
}
@end
