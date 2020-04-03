//
//  SessionManager.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Vapor
import WebSocket

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyond a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
final class TrackingSessionManager {
    
    // MARK: Member Variables
    private(set) var sessions: LockedDictionary<TrackingSession, [WebSocket]> = [:]
    
    // MARK: Observer Interactions
    func add(listener: WebSocket, to session: TrackingSession) {
      guard var listeners = sessions[session] else { return }
      listeners.append(listener)
      sessions[session] = listeners
      listener.onClose.always { [weak self, weak listener] in
        guard let listener = listener else { return }
        self?.remove(listener: listener, from: session)
      }
    }
    
    private func remove(listener: WebSocket, from session: TrackingSession) {
      guard var listeners = sessions[session] else { return }
      listeners = listeners.filter { $0 !== listener }
      sessions[session] = listeners
    }
    
    // MARK: Poster Interactions
    func createTrackingSession(for request: Request) -> Future<TrackingSession> {
      return wordKey(with: request)
        .flatMap(to: TrackingSession.self) { [unowned self] key -> Future<TrackingSession> in
          let session = TrackingSession(id: key)
          guard self.sessions[session] == nil else {
            return self.createTrackingSession(for: request)
          }
          self.sessions[session] = []
          return Future.map(on: request) { session }
      }
    }
    
    // Update
    func update(_ currency: [CurrencyBuilder], for session: TrackingSession) {
        guard let listeners = sessions[session] else { return }
        listeners.forEach { ws in
            ws.send(currency)
        }
    }
    
    // Close
    func close(_ session: TrackingSession) {
      guard let listeners = sessions[session] else { return }
      listeners.forEach { ws in
        ws.close()
      }
      sessions[session] = nil
    }
}
