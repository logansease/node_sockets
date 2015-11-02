# Node.js Websocket Messaging Server

A light weight socket messaging server. This will allow several clients to join together into rooms and will allow
the clients and host to message each other through sockets.

I am using this specifically to allow iOS apps to communicate with an Apple TV app without needing a bluetooth or wifi connection. Clients only need the hosts room id.

# Running Locally

``` bash
npm install
npm start
```

# Running on Heroku

``` bash
heroku create
git push heroku master
heroku open
```

# Connecting an iOS Client

Add to your Podfile
``` bash
pod 'SocketRocket', :git => 'https://github.com/hamchapman/SocketRocket.git', :branch => 'add-tvos-support'
```
Create a room with your host (Apple TV)
``` bash
GameSocket * socket = [[GameSocket alloc]init];
socket.roomId = @"room1";
[socket connect];
[socket createRoom];
```
Join a room from another iOS client
``` bash
GameSocket * socket = [[GameSocket alloc]init];
socket.roomId = @"room1";
[socket connect];
[socket joinRoom];
[socket sendHost:@"I'm Here!";
```

