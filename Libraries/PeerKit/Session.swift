//
//  Session.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/10/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

final class Session: NSObject {
    weak var delegate: SessionDelegate?
    let myPeerID: MCPeerID
    let mcSession: MCSession
    let serviceName: String
    
    init(displayName: String, serviceName: String) {
        self.serviceName = serviceName
        myPeerID = MCPeerID(displayName: displayName)
        mcSession = MCSession(peer: myPeerID)
        
        super.init()
        
        mcSession.delegate = self
    }
    
    func disconnect() {
        self.delegate = nil
        mcSession.delegate = nil
        mcSession.disconnect()
    }
}

// MARK: - MCSessionDelegate
extension Session: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        switch state {
        case .connecting:
            delegate?.isConnecting(toPeer: peerID)
        case .connected:
            delegate?.didConnect(toPeer: peerID)
        case .notConnected:
            delegate?.didDisconnect(fromPeer: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate?.didReceiveData(data: data, fromPeer: peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream,
                 withName streamName: String, fromPeer peerID: MCPeerID) {
        // unused
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName
        resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // unused
    }
    
    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // unused
    }
}
