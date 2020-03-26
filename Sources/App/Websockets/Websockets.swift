//
//  Websockets.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Vapor

let sessionManager = TrackingSessionManager()

public func sockets(_ websockets: NIOWebSocketServer) {
  
    // Status
    websockets.get("echo-test") { ws, req in
      print("ws connnected")
      ws.onText { ws, text in
          // recieved typf of text
        print("ws received: \(text)")
          // send echo to client
        ws.send("echo - \(text)")
      }
    }
    
    // Listener
    websockets.get("listen", TrackingSession.parameter) { ws, req in
      let session = try req.parameters.next(TrackingSession.self)
      guard sessionManager.sessions[session] != nil else {
        ws.close()
        return
      }
      sessionManager.add(listener: ws, to: session)
    }
}
