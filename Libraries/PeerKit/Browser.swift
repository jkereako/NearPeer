//
//  Browser.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/10/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

final class Browser: NSObject {
    weak var delegate: BrowserDelegate?
    private let session: Session
    private let nearbyServiceBrowser: MCNearbyServiceBrowser
    private let peerInvitationTimeout: Double = 30

    init(session: Session) {
        self.session = session
        nearbyServiceBrowser = MCNearbyServiceBrowser(
            peer: session.myPeerID, serviceType: session.serviceName
        )

        super.init()

        nearbyServiceBrowser.delegate = self
    }

    deinit {
        #if DEBUG
            let url = URL(fileURLWithPath: #file)
            print("Deinit \(url.lastPathComponent)")
        #endif
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
        #if DEBUG
            print("Found peer: \(peerID.displayName)")
        #endif

        browser.invitePeer(
            peerID, to: session.underlyingSession, withContext: nil, timeout: peerInvitationTimeout
        )
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // unused
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.didFailToBrowse(error: error)
    }
}

