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
    @IBOutlet weak private var serviceName: UILabel!
    @IBOutlet weak private var status: UILabel!
    @IBOutlet weak private var message: UITextField!

    // Hold on to a reference to keep it alive
    private let peerKit: PeerKit

    init() {
        let serviceName = "dummy-service"
        peerKit = PeerKit(serviceName: serviceName)

        super.init(nibName: "View", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.serviceName.text = peerKit.serviceName

        peerKit.delegate = self
        status.text = "Waiting for input..."
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        // Dismiss the keyboard if the user taps anywhere on the screen
        view.endEditing(true)
    }
}

// MARK: - SessionDelegate
extension ViewController: PeerKitDelegate {
    func peerKit(_ peerKit: PeerKit, shouldAcceptInvitationFromPeer peer: MCPeerID) -> Bool {
        return true
    }

    func peerKit(_ peerKit: PeerKit, didAcceptInvitationFromPeer peer: MCPeerID) {
        status.text = "Accepted invitation from \(peer.displayName)"
    }

    func peerKit(_ peerKit: PeerKit, didRejectInvitationFromPeer peer: MCPeerID) {
        status.text = "Rejected invitation from \(peer.displayName)"
    }

    func peerKit(_ peerKit: PeerKit, isConnectingToPeer peer: MCPeerID) {
        status.text = "Connecting to \(peer.displayName)"
    }

    func peerKit(_ peerKit: PeerKit, didConnectToPeer peer: MCPeerID) {
        status.text = "Connected to \(peer.displayName)"
    }

    func peerKit(_ peerKit: PeerKit, didDisconnectFromPeer peer: MCPeerID) {
        status.text = "Disconnected from \(peer.displayName)"
    }

    func peerKit(_ peerKit: PeerKit, didReceiveMessage message: String) {
        status.text = "Received message: \"\(message)\""
    }

    func peerKit(_ peerKit: PeerKit, didFailToBrowse error: Error) {
        status.text = "Failed to browse"
    }

    func peerKit(_ peerKit: PeerKit, didFailToAdvertise error: Error) {
        status.text = "Failed to advertise"
    }

    func peerKit(_ peerKit: PeerKit, didFailToSendMessage message: String, toPeers peers: [MCPeerID]) {
        status.text = "Failed to send message \"\(message)\""
    }
}

// MARK: - Target-actions
private extension ViewController {
    @IBAction func disconnectAction(_ sender: UIButton) {
        status.text = "Disconnected"
        peerKit.stopSession()
    }

    @IBAction func advertiseAction(_ sender: UIButton) {
        guard !peerKit.isAdvertising else {
            peerKit.stopAdvertising()
            sender.setTitle("ADVERTISE", for: .normal)

            status.text = "Waiting for input..."

            if peerKit.isBrowsing {
                status.text = "Browsing..."
            }

            return
        }

        sender.setTitle("STOP ADVERTISING", for: .normal)
        peerKit.startAdvertising()
        status.text = "Advertising"

        if peerKit.isBrowsing {
            status.text = "Advertising and Browsing..."
        }
    }

    @IBAction func browseAction(_ sender: UIButton) {
        guard !peerKit.isBrowsing else {
            peerKit.stopBrowsing()
            sender.setTitle("BROWSE", for: .normal)

            status.text = "Waiting for input..."

            if peerKit.isAdvertising {
                status.text = "Advertising..."
            }

            return
        }

        sender.setTitle("STOP BROWSING", for: .normal)
        peerKit.startBrowsing()
        status.text = "Browsing"

        if peerKit.isAdvertising {
            status.text = "Advertising and Browsing..."
        }
    }

    @IBAction func sendMessageAction(_ sender: UIButton) {
        peerKit.sendMessage(message.text ?? "")
    }
}
