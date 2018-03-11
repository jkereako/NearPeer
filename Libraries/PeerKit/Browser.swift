//
//  Browser.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/10/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

final class Browser: NSObject {
    private let mcSession: MCSession
    private let nearbyServiceBrowser: MCNearbyServiceBrowser
    private let peerInvitationTimeout: Double = 30

    init(session: Session) {
        self.mcSession = session.mcSession
        nearbyServiceBrowser = MCNearbyServiceBrowser(
            peer: session.myPeerID, serviceType: session.serviceName
        )

        super.init()

        nearbyServiceBrowser.delegate = self
    }

    func start() {
        nearbyServiceBrowser.startBrowsingForPeers()
    }

    func stop() {
        nearbyServiceBrowser.delegate = nil
        nearbyServiceBrowser.stopBrowsingForPeers()
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension Browser: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: peerInvitationTimeout)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // unused
    }
}

