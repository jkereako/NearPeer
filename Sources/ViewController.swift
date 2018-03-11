//
//  ViewController.swift
//  MultipeerConnectivity
//
//  Created by Jeff Kereakoglow on 3/10/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import UIKit
import PeerKit

final class ViewController: UIViewController {
    init() {
        super.init(nibName: "View", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let peerKit = PeerKit(serviceName: "dummy-service")
        peerKit.delegate = self
        peerKit.advertise()
        peerKit.browse()
    }
}

// MARK: - SessionDelegate
extension ViewController: PeerKitDelegate {
    func didFailToAdvertise(error: Error) {
        print("\(error)")
    }

    func didFailToBrowse(error: Error) {
        print("\(error)")
    }

    func peerKit(_ peerKit: PeerKit, didReceiveEvent event: String, withObject object: AnyObject) {
        print("Received \(event)")
    }

    func peerKit(_ peerKit: PeerKit, isConnectingToPeer peer: MCPeerID) {
        print("Connecting to \(peer.displayName)")
    }

    func peerKit(_ peerKit: PeerKit, didConnectToPeer peer: MCPeerID) {
        print("Connected to \(peer.displayName)")
    }

    func peerKit(_ peerKit: PeerKit, didDisconnectFromPeer peer: MCPeerID) {
        print("Disconnected from \(peer.displayName)")
    }
}

