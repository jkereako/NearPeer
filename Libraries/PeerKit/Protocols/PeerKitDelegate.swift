//
//  PeerKitDelegate.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/11/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

public protocol PeerKitDelegate: class {
    func peerKit(_ peerKit: PeerKit, didReceiveEvent event: String, withObject object: AnyObject)
    func peerKit(_ peerKit: PeerKit, isConnectingToPeer peer: MCPeerID)
    func peerKit(_ peerKit: PeerKit, didConnectToPeer peer: MCPeerID)
    func peerKit(_ peerKit: PeerKit, didDisconnectFromPeer peer: MCPeerID)
    func didFailToAdvertise(error: Error)
    func didFailToBrowse(error: Error)
}
