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
    }
}

// MARK: - SessionDelegate
extension ViewController: SessionDelegate {
    func isConnecting(toPeer peer: MCPeerID) {
        print("Connecting")
    }

    func didConnect(toPeer peer: MCPeerID) {
        print("Connected")
    }

    func didDisconnect(fromPeer peer: MCPeerID) {
        print("Disconnected")
    }

    func didReceiveData(data: Data, fromPeer peer: MCPeerID) {
        print("Data received")
    }
}

