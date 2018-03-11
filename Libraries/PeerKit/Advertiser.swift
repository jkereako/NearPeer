//
//  Advertiser.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/10/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

final class Advertiser: NSObject {
    weak var delegate: AdvertiserDelegate?
    private let session: Session
    private let advertiser: MCNearbyServiceAdvertiser

    init(session: Session) {
        self.session = session
        advertiser = MCNearbyServiceAdvertiser(
            // REVIEW: Could I replace this with `session.myPeerID`?
            peer: session.underlyingSession.myPeerID,
            discoveryInfo: nil,
            serviceType: session.serviceName
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
extension Advertiser: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        let accept = session.myPeerID.hashValue > peerID.hashValue

        invitationHandler(accept, session.underlyingSession)

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
