//
//  PeerKit.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/10/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

#if os(iOS)
    import UIKit
#endif

final public class PeerKit {
    public weak var delegate: PeerKitDelegate?
    public let serviceName: String
    public var isAdvertising: Bool
    public var isBrowsing: Bool

    let displayName: String
    let sessionManager: SessionManager
    let advertiserManager: AdvertiserManager
    let browserManager: BrowserManager
    
    public init(serviceName: String) {
        // The service name must meet the restrictions of RFC 6335:
        //  * Must be 1–15 characters long
        //  * Can contain only ASCII lowercase letters, numbers, and hyphens
        //  * Must contain at least one ASCII letter
        //  * Must not begin or end with a hyphen
        //  * Must not contain hyphens adjacent to other hyphens.
        assert(
            serviceName.count > 1 && serviceName.count < 15,
            "Service Name must be 1 to 15 characters long"
        )
        
        // I don't know why `serviceName.endIndex` doesn't actually return the end index.
        let endIndex = serviceName.index(before: serviceName.endIndex)
        
        assert(
            serviceName[serviceName.startIndex] != "-" && serviceName[endIndex] != "-",
            "Service Name must not begin or end with a hyphen"
        )
        assert(
            serviceName.range(of: "--") == nil,
            "Service Name must not contain adjacent hyphens"
        )
        
        let legalCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-")
        
        assert(
            serviceName.rangeOfCharacter(from: legalCharacters.inverted) == nil,
            "Service Name must contain only lowercase letters, decimal digits and hyphens."
        )
        
        #if os(iOS)
            displayName = UIDevice.current.name
        #else
            displayName = Host.current().localizedName ?? ""
        #endif
        self.serviceName = serviceName
        sessionManager = SessionManager(displayName: displayName, serviceName: serviceName)
        advertiserManager = AdvertiserManager(sessionManager: sessionManager)
        browserManager = BrowserManager(sessionManager: sessionManager)

        isAdvertising = false
        isBrowsing = false
        sessionManager.delegate = self
        advertiserManager.delegate = self
        browserManager.delegate = self
    }
    
    deinit {
        let url = URL(fileURLWithPath: #file)
        print("Deinit \(url.lastPathComponent)")
    }
    
    public func startAdvertising() {
        isAdvertising = true
        sessionManager.start()
        advertiserManager.start()
    }
    
    public func startBrowsing() {
        isBrowsing = true
        sessionManager.start()
        browserManager.start()
    }

    public func stopBrowsing() {
        isBrowsing = false
        browserManager.stop()
    }

    public func stopAdvertising() {
        isAdvertising = false
        advertiserManager.stop()
    }

    public func stopSession() {
        sessionManager.stop()
    }

    public func sendMessage(_ message: String) {
        let peers = sessionManager.session.connectedPeers
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: message)

        do {
            try self.sessionManager.session.send(archivedData, toPeers: peers, with: .reliable)
        } catch {
            DispatchQueue.main.async { [unowned self] in
                self.delegate?.peerKit(self, didFailToSendMessage: message, toPeers: peers)
            }
        }
    }
}

// MARK: - SessionDelegate
extension PeerKit: SessionManagerDelegate {
    public func isConnecting(toPeer peer: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.peerKit(self, isConnectingToPeer: peer)
        }
    }
    
    public func didConnect(toPeer peer: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.peerKit(self, didConnectToPeer: peer)
        }
    }
    
    public func didDisconnect(fromPeer peer: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.peerKit(self, didDisconnectFromPeer: peer)
        }
    }
    
    public func didReceiveData(data: Data, fromPeer peer: MCPeerID) {
        guard let message = NSKeyedUnarchiver.unarchiveObject(with: data) as? String else {
            assertionFailure("Expected a String")
            return
        }

        DispatchQueue.main.async { [unowned self] in
            self.delegate?.peerKit(self, didReceiveMessage: message)
        }
    }
}

// MARK: - AdvertiserDelegate
extension PeerKit: AdvertiserManagerDelegate {
    func shouldAcceptInvitation(fromPeer peer: MCPeerID) -> Bool {
        return self.delegate?.peerKit(self, shouldAcceptInvitationFromPeer: peer) ?? false
    }

    func didAcceptInvitation(fromPeer peer: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.peerKit(self, didAcceptInvitationFromPeer: peer)
        }
    }

    func didRejectInvitation(fromPeer peer: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.peerKit(self, didRejectInvitationFromPeer: peer)
        }
    }

    func didFailToAdvertise(error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.peerKit(self, didFailToAdvertise: error)
        }
    }
}

// MARK: - BrowserDelegate
extension PeerKit: BrowserManagerDelegate {
    func didFailToBrowse(error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.peerKit(self, didFailToBrowse: error)
        }
    }
}
