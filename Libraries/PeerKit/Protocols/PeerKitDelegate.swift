//
//  PeerKitDelegate.swift
//  NearPeer
//
//  Created by Jeff Kereakoglow on 3/11/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

public protocol PeerKitDelegate: class {
    func peerKit(_ peerKit: PeerKit, didReceiveMessage message: String)
    func peerKit(_ peerKit: PeerKit, isConnectingToPeer peer: MCPeerID)
    func peerKit(_ peerKit: PeerKit, didConnectToPeer peer: MCPeerID)
    func peerKit(_ peerKit: PeerKit, didDisconnectFromPeer peer: MCPeerID)
    func peerKit(_ peerKit: PeerKit, shouldAcceptInvitationFromPeer peer: MCPeerID) -> Bool
    func peerKit(_ peerKit: PeerKit, didAcceptInvitationFromPeer peer: MCPeerID)
    func peerKit(_ peerKit: PeerKit, didRejectInvitationFromPeer peer: MCPeerID)
    func peerKit(_ peerKit: PeerKit, didFailToAdvertise error: Error)
    func peerKit(_ peerKit: PeerKit, didFailToBrowse error: Error)
    func peerKit(_ peerKit: PeerKit, didFailToSendMessage message: String, toPeers peers: [MCPeerID])
}
