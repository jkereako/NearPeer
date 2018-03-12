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
        
        sessionManager.delegate = self
        advertiserManager.delegate = self
        browserManager.delegate = self
    }
    
    deinit {
        let url = URL(fileURLWithPath: #file)
        print("Deinit \(url.lastPathComponent)")
    }
    
    public func advertise() {
        advertiserManager.start()
    }
    
    public func browse() {
        browserManager.start()
    }
    
    public func stop() {
        sessionManager.delegate = nil
        advertiserManager.stop()
        browserManager.stop()
        sessionManager.disconnect()
    }

    public func sendEvent(_ event: String, withObject object: AnyObject? = nil) {
        let peers = sessionManager.session.connectedPeers
        var rootObject: [String: AnyObject] = ["event": event as AnyObject]
        
        if let object: AnyObject = object {
            rootObject["object"] = object
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: rootObject)
        
        do {
            try sessionManager.session.send(data, toPeers: peers, with: .reliable)
        } catch {
            DispatchQueue.main.async { [unowned self] in
                self.delegate?.peerKit(self, didFailToSendEvent: event, toPeers: peers)
            }

            print("\(error)")
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
        guard let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: AnyObject],
            let event = dict["event"] as? String else {
                assertionFailure("Expected an event")
                return
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.peerKit(self, didReceiveEvent: event, withObject: dict["object"] )
        }
    }
}

// MARK: - AdvertiserDelegate
extension PeerKit: AdvertiserManagerDelegate {
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
