//
//  GameSocket.h
//  phrasepartyTV
//
//  Created by Logan Sease on 10/14/15.
//  Copyright © 2015 Logan Sease. All rights reserved.
//  

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

#define kSocketUrl      @"http://localhost:5000"

@protocol GameSocketDelegate <NSObject>

-(void)gotMessage:(NSString*)message;
-(void)disconnectedSocket;
-(void)reconnectedSocket;

@end


@interface GameSocket : NSObject<SRWebSocketDelegate>

+ (id)sharedSocket;
-(NSString*)joinRoom;
-(NSString*)createRoom;
-(void)leaveRoom;
-(void)disconnect;
-(void)reconnect;
-(void)send:(NSString*)message;
-(void)sendHost:(NSString*)message;

@property(nonatomic,strong)NSMutableString* messages;
@property(nonatomic,strong)NSString* socketId;
@property(nonatomic,strong)NSString * roomName;
@property(nonatomic,weak)id<GameSocketDelegate>delegate;

@end
