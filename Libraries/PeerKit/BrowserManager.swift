//
//  Browser.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/10/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

final class BrowserManager: NSObject {
    weak var delegate: BrowserManagerDelegate?
    private let sessionManager: SessionManager
    private let nearbyServiceBrowser: MCNearbyServiceBrowser
    private let peerInvitationTimeout: Double = 30

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        nearbyServiceBrowser = MCNearbyServiceBrowser(
            peer: sessionManager.myPeerID, serviceType: sessionManager.serviceName
        )

        super.init()
    }

    deinit {
        #if DEBUG
            let url = URL(fileURLWithPath: #file)
            print("Deinit \(url.lastPathComponent)")
        #endif
    }

    func start() {
        nearbyServiceBrowser.delegate = self
        nearbyServiceBrowser.startBrowsingForPeers()
    }

    func stop() {
        nearbyServiceBrowser.delegate = nil
        nearbyServiceBrowser.stopBrowsingForPeers()
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension BrowserManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        #if DEBUG
            print("Found peer: \(peerID.displayName)")
        #endif

        browser.invitePeer(
            peerID, to: sessionManager.session, withContext: nil, timeout: peerInvitationTimeout
        )
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // unused
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.didFailToBrowse(error: error)
    }
}

