//
//  Advertiser.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/10/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

final class Advertiser: NSObject {
    private let session: Session
    private let advertiser: MCNearbyServiceAdvertiser

    init(session: Session) {
        self.session = session
        advertiser = MCNearbyServiceAdvertiser(
            peer: session.mcSession.myPeerID, discoveryInfo: nil, serviceType: session.serviceName
        )

        super.init()
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

        invitationHandler(accept, session.mcSession)

        if accept {
            stop()
        }
    }
}
