//
//  SystemVersion.swift
//  BECollectionView
//
//  Created by Chung Tran on 30/03/2021.
//

import Foundation

import Foundation

struct SystemVersion {
    static func isIOS13() -> Bool {
        let os = ProcessInfo().operatingSystemVersion
        switch (os.majorVersion, os.minorVersion, os.patchVersion) {
        case (let x, _, _) where x == 13:
            return true
        default:
            return false
        }
    }
}
