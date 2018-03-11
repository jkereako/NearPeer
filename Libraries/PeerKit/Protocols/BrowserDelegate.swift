//
//  BrowserDelegate.swift
//  PeerKit
//
//  Created by Jeff Kereakoglow on 3/11/18.
//  Copyright © 2018 Alexis Digital. All rights reserved.
//

import MultipeerConnectivity

protocol BrowserDelegate: class {
    func didFailToBrowse(error: Error)
}

