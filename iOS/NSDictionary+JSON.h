//
//  NSDictionary+JSON.h
//  phrasepartyTV
//
//  Created by Logan Sease on 11/2/15.
//  Copyright © 2015 Logan Sease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

-(NSString*)toJsonString;
+(NSDictionary*)fromJsonString:(NSString*)json;

@end
