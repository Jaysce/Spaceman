//
//  Constants.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 7/11/21.
//

import Foundation

enum Constants {

    enum AppInfo {
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        static let repo: URL = {
            guard let url = URL(string: "https://github.com/Jaysce/Spaceman") else {
                fatalError("Invalid repository URL")
            }
            return url
        }()
        static let website: URL = {
            guard let url = URL(string: "https://jaysce.dev/projects/spaceman") else {
                fatalError("Invalid website URL")
            }
            return url
        }()
    }

}
