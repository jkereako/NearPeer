//
//  SessionManager.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/10/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

final class SessionManager: NSObject {
    weak var delegate: SessionManagerDelegate?
    var myPeerID: MCPeerID { return session.myPeerID }
    var connectedPeers: [MCPeerID] { return session.connectedPeers }
    let session: MCSession
    let serviceName: String
    
    init(displayName: String, serviceName: String) {
        self.serviceName = serviceName

        let myPeerID = MCPeerID(displayName: displayName)
        session = MCSession(
            peer: myPeerID, securityIdentity: nil, encryptionPreference: .required
        )
        
        super.init()
        
        session.delegate = self
    }

    deinit {
        #if DEBUG
            let url = URL(fileURLWithPath: #file)
            print("Deinit \(url.lastPathComponent)")
        #endif
    }
    
    func disconnect() {
        self.delegate = nil
        session.delegate = nil
        session.disconnect()        
    }
}

// MARK: - MCSessionDelegate
extension SessionManager: MCSessionDelegate {
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
        //   
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
