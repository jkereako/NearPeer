//
//  Advertiser.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/10/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

final class AdvertiserManager: NSObject {
    weak var delegate: AdvertiserManagerDelegate?
    private let sessionManager: SessionManager
    private let advertiser: MCNearbyServiceAdvertiser

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        advertiser = MCNearbyServiceAdvertiser(
            peer: sessionManager.myPeerID,
            discoveryInfo: nil,
            serviceType: sessionManager.serviceName
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
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }

    func stop() {
        advertiser.delegate = nil
        advertiser.stopAdvertisingPeer()
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension AdvertiserManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        let accept = sessionManager.session.connectedPeers.contains(peerID)
        
        invitationHandler(accept, sessionManager.session)

        if accept {
            delegate?.didAcceptInvitation(fromPeer: peerID)
            stop()
        } else {
            delegate?.didRejectInvitation(fromPeer: peerID)
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didNotStartAdvertisingPeer error: Error) {
        delegate?.didFailToAdvertise(error: error)
    }
}
