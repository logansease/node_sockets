//
//  GameSocket.m
//  phrasepartyTV
//
//  Created by Logan Sease on 10/14/15.
//  Copyright © 2015 Logan Sease. All rights reserved.
//

#import "GameSocket.h"
#import "NSDictionary+JSON.h"

@interface GameSocket()
@property(nonatomic,strong)SRWebSocket * socket;
@property(nonatomic,strong)NSLock * lock;
@property BOOL created;
@end

@implementation GameSocket

static GameSocket *sharedSocket = nil;

#pragma mark Singleton Methods
+ (id)sharedSocket {
    @synchronized(self) {
        if (sharedSocket == nil){
            sharedSocket = [[self alloc] init];
        }
        
    }
    return sharedSocket;
}


#pragma mark INITIALIZERS

-(id)init
{
    if(self = [super init])
    {
        self.lock = [[NSLock alloc]init];
        self.messages = [NSMutableString string];
        self.socketId = [self generateSocketId];
        [self connect];
    }
    return self;
}


#pragma mark socket delegates

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"%@: Got %@",self.socketId,message);
    [self.messages appendFormat:@"%@\n",message];
    
    if(self.delegate)
    {
        [self.delegate gotMessage:message];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Opened");
    THREAD_MAIN(
        [self.lock unlock];
    )
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    THREAD_MAIN(
    [self.lock unlock];
    NSLog(@"Error");
    )
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    //this connected from the server. Handle the error
    if(code == 1001)
    {
        //TODO reconnect if error disconnection
    }
    
    [self.delegate disconnectedSocket];
    NSLog(@"disconnected with code %li",(long)code);
}

#pragma mark socket connection actions

/** CREATE A SOCKET CONNECTION **/
-(void)connect
{
    [self.lock lock];
    NSURLRequest  * req = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",kSocketUrl]]];
    self.socket = [[SRWebSocket alloc]initWithURLRequest:req];
    self.socket.delegate = self;
    [self.socket open];
    
}

/** DESTROY A SOCKET CONNECTION **/
-(void)disconnect
{
    [self leaveRoom];
    [self.socket close];
}

/** RECONNECT SOCKET CONNECTION **/
-(void)reconnect
{
    if(self.socket.readyState != SR_OPEN)
    {
        [self connect];
    }
}

#pragma mark join / create actions

/** LEAVE A ROOM **/
-(void)leaveRoom
{
    if(self.roomName == nil)
    {
        return;
    }
    
    if([self.lock tryLock])
    {
        NSDictionary * dictionary = @{@"request": @"LEAVE", @"room" : self.roomName};
        NSString * json = [dictionary toJsonString];
        [self.socket send:json];
        [self.lock unlock];
    }
}

/** CREATE A NEW ROOM **/
-(NSString*)createRoom
{
    if(self.roomName == nil)
    {
        self.roomName = [self generateRoomName];
    }
    
    if([self.lock tryLock])
    {
        NSDictionary * dictionary = @{@"request": @"CREATE", @"room" : self.roomName};
        NSString * json = [dictionary toJsonString];
        [self.socket send:json];
        [self.lock unlock];
    }
    
    self.created = YES;
    
    return self.roomName;
}

/** JOIN AN EXISTING ROOM **/
-(NSString*)joinRoom
{
    if(self.roomName == nil)
    {
        self.roomName = [self generateRoomName];
    }
    
    if(self.socketId == nil)
    {
        self.socketId = [self generateSocketId];
    }
    
    if([self.lock tryLock])
    {
        NSDictionary * dictionary = @{@"request": @"JOIN", @"room" : self.roomName, @"id":self.socketId};
        NSString * json = [dictionary toJsonString];
        
        [self.socket send:json];
        [self.lock unlock];
    }
    
    return self.roomName;
}

#pragma mark messages

-(void)sendHost:(NSString*)message
{
    if(!self.roomName)
    {
        return;
    }
    
    if([self.lock tryLock])
    {
        NSDictionary * dictionary = @{@"request": @"MESSAGE_HOST", @"room" : self.roomName, @"message" : message};
        NSString * json = [dictionary toJsonString];
        
        [self.socket send:json];
        [self.lock unlock];
    }
}

-(void)send:(NSString*)message
{
    if(!self.roomName)
    {
        return;
    }
    
    if([self.lock tryLock])
    {
        NSDictionary * dictionary = @{@"request": @"MESSAGE_HOST", @"room" : self.roomName, @"message" : message};
        NSString * json = [dictionary toJsonString];
        
        [self.socket send:json];
        [self.lock unlock];
    }
}

#pragma mark helpers

-(NSString*)generateRoomName
{
    //return @"abc123";
    return [self randomStringOfLength:5];
}

-(NSString*)generateSocketId
{
    return [self randomStringOfLength:5];
}

-(NSString*)randomStringOfLength:(int)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    
    return randomString;
}


@end
