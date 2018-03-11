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
    weak var delegate: SessionDelegate?

    let displayName: String
    let session: Session
    let advertiser: Advertiser
    let browser: Browser

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

        session = Session(displayName: displayName, serviceName: serviceName)
        advertiser = Advertiser(session: session)
        browser = Browser(session: session)

        session.delegate = delegate
    }

    public func advertise() {
        advertiser.start()
    }

    public func browse() {
        browser.start()
    }
    
    public func stop() {
        session.delegate = nil
        advertiser.stop()
        browser.stop()
        session.disconnect()
    }
}
