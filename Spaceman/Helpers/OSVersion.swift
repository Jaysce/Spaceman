//
//  OSVersion.swift
//  Spaceman
//
//  Created by René Uittenbogaard on 05/09/2024.
//

import Foundation

class OSVersion {
    public let version = ProcessInfo.processInfo.operatingSystemVersion
    public let versionStr: String

    init() {
        versionStr = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    func exceeds(_ maj: Int, _ min: Int, _ patch: Int = 0) -> Bool {
        if (version.majorVersion > maj) {
            return true
        } else if (version.majorVersion < maj) {
            return false
        } else if (version.minorVersion > min) {
            return true
        } else if (version.minorVersion < min) {
            return false
        } else {
            return version.patchVersion >= patch
        }
    }
}
