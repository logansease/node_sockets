var WebSocketServer = require("ws").Server
var http = require("http")
var express = require("express")
var app = express()
var port = process.env.PORT || 5000
var sockets = []

app.use(express.static(__dirname + "/"))

var server = http.createServer(app)
server.listen(port)

console.log("http server listening on %d", port)

var gameLobbies = []

var socketServer = new WebSocketServer({server: server})
console.log("websocket server created")

var sendMessage = function(gameLobby, message, sender)
{

  if(gameLobby.host == null || gameLobby.host.readyState != gameLobby.host.OPEN)
  {
    return false
  }

  if(gameLobby.host != null && sender != gameLobby.host && gameLobby.host.readyState == gameLobby.host.OPEN)
  {
    gameLobby.host.send(message)
  }

  //TODO make this loop work.
  var keys = Object.keys(gameLobby.clients);
  for(i=0 ; i < keys.length ; i++){

     var key = keys[i]
     var entry = gameLobby.clients[key]
     if(entry != null && entry != sender && entry.readyState == entry.OPEN)   
     {
        console.log("messaging client " + entry)
        entry.send(message)
     }
  }

  return true

}

//ON SOCKET CONNECT
socketServer.on("connection", function(socket) {

  var mySocket = socket
  sockets.push(mySocket)

  console.log("websocket connection open " + socket)

  //ON MESSAGE RECEIVE
  socket.on('message', function (data) { 

    console.log("got " + data);

    var json = JSON.parse(data);

    if(socket == null)
    {
      console.log("ERROR socket is null")
    }

    /***** ON LOBBY CREATE *****/
    if(json.request == "CREATE")
    {
        var code = json.room

        //create a new room
        lobby = gameLobbies[code];
        if(lobby == null)
        {
          console.log("CREATING " + code)

          //create a new game lobby and add the socket as the host.
          var lobby = new Object
          lobby.host = mySocket
          lobby.clients = []
          mySocket.send("SUCCESS")

          gameLobbies[code] = lobby
        }

        //reconnect a host socket
        else if(lobby.host != null && lobby.host.readyState != lobby.host.OPEN)
        {
          lobby.host = mySocket
          mySocket.send("SUCCESS")
        }
        else
        {
          mySocket.send("FAILURE")
        }

    }

    /*** ON CLIENT JOIN ****/
    else if(json.request == "JOIN")
    {
        var code = json.room;
        var socketId = json.id;

        lobby = gameLobbies[code];

        //join the lobby only if you are not the host
        if(lobby != null && lobby.host != mySocket)
        {
          //ensure we aren't already in the lobby
            for(i=0 ; i < lobby.clients.length ; i++){

               var entry = lobby.clients[i]
               if(mySocket == entry)
               {
                  mySocket.send("FAILURE" )
                  return
               }
             }

          lobby.clients[socketId] = mySocket

          sendMessage(lobby,"CLIENT_ADDED", mySocket)
          mySocket.send("SUCCESS" )
          console.log("ADDED:" + lobby.clients)
        }
        else
        {
          mySocket.send("FAILURE" )
        }
    }


    /***** ON CLIENT EXIT ********/
    else if(json.request == "LEAVE")
    {
        var code = json.room;
        lobby = gameLobbies[code];
        if(lobby != null)
        {
          //if the host wants to leave we need to exit the game
          if(lobby.host == socket)
          {

          }
          else
          {
            var index = lobby.clients.indexOf(mySocket);
            if (index > -1) {
              lobby.clients = lobby.clients.splice(index, 1);

              mySocket.send("LEFT " + code)
              lobby.host.send("CLIENT " + index + " REMOVED")
            }
          }
        }
    }


    /***** ON SEND MESSAGE  ******/
    else if(json.request == "MESSAGE")
    {
        var code = json.room
        lobby = gameLobbies[code]
        message = json.message

        if(lobby != null && message != null && sendMessage(lobby,message,mySocket))
        {
          mySocket.send("SUCCESS")
        }
        else
        {
          mySocket.send("FAILURE")
        }
    }
   
       /***** ON SEND MESSAGE  ******/
    else if(json.request == "MESSAGE_HOST")
    {
        var code = json.room
        lobby = gameLobbies[code]
        message = json.message

        if(lobby != null && message != null && lobby.host != mySocket && lobby.host.readyState == lobby.host.OPEN)
        {
          lobby.host.send(message)
          mySocket.send("SUCCESS")
        }
        else
        {
          mySocket.send("FAILURE")
        }
    }


   })

  /**** ON DISCONNET  *****/
  socket.on("close", function(socket) {
    console.log("websocket connection close")
    //sockets.remove(socket)
  })


   // var id = setInterval(function() {
   //   socket.send(JSON.stringify(new Date()), function() {  })
   // }, 1000)

})