//
//  NSDictionary+JSON.m
//  phrasepartyTV
//
//  Created by Logan Sease on 11/2/15.
//  Copyright © 2015 Logan Sease. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)
-(NSString*)toJsonString
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"json error: %@", error.localizedDescription);
        return @"";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+(NSDictionary*)fromJsonString:(NSString*)json
{
    NSError *jsonError;
    NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
}

@end
