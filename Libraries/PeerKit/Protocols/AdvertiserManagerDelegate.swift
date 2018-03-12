//
//  AdvertiserManagerDelegate.swift
//  NearPeer
//
//  Created by Jeff Kereakoglow on 3/11/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

protocol AdvertiserManagerDelegate: class {
    func didFailToAdvertise(error: Error)
    func didAcceptInvitation(fromPeer peer: MCPeerID)
    func didRejectInvitation(fromPeer peer: MCPeerID)
}
