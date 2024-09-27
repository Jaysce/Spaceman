//
//  Constants.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 7/11/21.
//

import Foundation

enum LayoutMode {
    case compact
    case normal
    case spacious
}

struct Size {
    var GAP_WIDTH_SPACES: Int!
    var GAP_WIDTH_DISPLAYS: Int!
    var ICON_WIDTH_SMALL: Int!
    var ICON_WIDTH_LARGE: Int!
    var ICON_WIDTH_XLARGE: Int!
    var ICON_HEIGHT: Int!
    var FONT_SIZE: Int!
}

struct Constants {
    enum AppInfo {
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        static let repo = URL(string: "https://github.com/ruittenb/Spaceman")!
        static let website = URL(string: "https://jaysce.dev/projects/spaceman")!
    }

    //  23   = 277 px ; button distance
    //  18   = 219 px ; button width
    //  10   = 120 px ; left margin
    //   5   =  60 px ; gap
    //   2.5 =  30 px ; semi gap
    //   7.5 =  90 px ; void left

    static let sizes: [LayoutMode: Size] = [
        .compact: Size(
            GAP_WIDTH_SPACES: 3,
            GAP_WIDTH_DISPLAYS: 10,
            ICON_WIDTH_SMALL: 16,
            ICON_WIDTH_LARGE: 26,
            ICON_WIDTH_XLARGE: 40,
            ICON_HEIGHT: 12,
            FONT_SIZE: 10
        ),
        .normal: Size(
            GAP_WIDTH_SPACES: 5,
            GAP_WIDTH_DISPLAYS: 15,
            ICON_WIDTH_SMALL: 18,
            ICON_WIDTH_LARGE: 34,
            ICON_WIDTH_XLARGE: 49,
            ICON_HEIGHT: 12,
            FONT_SIZE: 10
        ),
        .spacious: Size(
            GAP_WIDTH_SPACES: 5,
            GAP_WIDTH_DISPLAYS: 15,
            ICON_WIDTH_SMALL: 20,
            ICON_WIDTH_LARGE: 34,
            ICON_WIDTH_XLARGE: 49,
            ICON_HEIGHT: 14,
            FONT_SIZE: 12
        )
    ]
}
