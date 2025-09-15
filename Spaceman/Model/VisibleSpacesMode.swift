//
//  VisibleSpacesMode.swift
//  Spaceman
//
//  Controls which spaces are shown in the status bar.
//

import Foundation

enum VisibleSpacesMode: Int, CaseIterable {
    case all = 0
    case currentOnly = 1
    case neighbors = 2
}

