//
//  IconBuilder.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Cocoa
import Foundation

class IconBuilder {
    private let ICON_SIZE = NSSize(width: 18, height: 12)
    private let GAP_WIDTH = CGFloat(5)
    private let DISPLAY_GAP_WIDTH = CGFloat(15)
    private let STRING_ATTRIBUTES: [NSAttributedString.Key : Any]
    
    init() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        STRING_ATTRIBUTES = [.foregroundColor: NSColor.black, .font: NSFont.systemFont(ofSize: 10, weight: .bold), .paragraphStyle: paragraphStyle]
    }
    
    func getIcon(spaces: [Space]) -> NSImage {
        var iconsTupleArray: [(Bool, NSImage, Bool)] = []
        var displayCount = 1
        var currentDisplayID = spaces[0].displayID
        
        for index in 0 ..< spaces.count {
            var nextSpaceIsOnDifferentDisplay = false
            let iconResourceName: String
            
            if (index + 1 < spaces.count) {
                if spaces[index + 1].displayID != currentDisplayID {
                    currentDisplayID = spaces[index + 1].displayID
                    displayCount += 1
                    nextSpaceIsOnDifferentDisplay = true
                }
            }
            
            switch (spaces[index].isCurrentSpace, spaces[index].isFullScreen) {
            case (true, true):
                iconResourceName = "SpaceManIconFullEn"
            case (true, false):
                iconResourceName = "SpaceManIcon"
            case (false, true):
                iconResourceName = "SpaceManIconFullDis"
            default:
                iconResourceName = "SpaceManIconBorder"
            }
            
            iconsTupleArray.append((nextSpaceIsOnDifferentDisplay, NSImage(imageLiteralResourceName: iconResourceName), spaces[index].isCurrentSpace))
        }
        
        if Preferences.shared.getDisplayType() == .numbers {
            iconsTupleArray = addNumbers(to: iconsTupleArray)
        }
        
        return mergeIcons(iconsTupleArray: iconsTupleArray, numberOfSpaces: spaces.count, numberOfDisplays: displayCount)
    }
    
    private func addNumbers(to icons: [(Bool, NSImage, Bool)]) -> [(Bool, NSImage, Bool)] {
        var copy = icons
        
        for index in 0 ..< icons.count {
            let textRect = NSRect(x: 0, y: 0, width: ICON_SIZE.width, height: ICON_SIZE.height)
            let spaceNumberString = NSString(string: String(index + 1))
            let iconImage = NSImage(size: NSSize(width: ICON_SIZE.width, height: ICON_SIZE.height))
            let numberImage = NSImage(size: NSSize(width: ICON_SIZE.width, height: ICON_SIZE.height))
            
            numberImage.lockFocus()
            spaceNumberString.drawVerticallyCentered(in: textRect, withAttributes: STRING_ATTRIBUTES)
            numberImage.unlockFocus()
            
            iconImage.lockFocus()
            icons[index].1.draw(in: textRect, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            numberImage.draw(in: textRect, from: NSZeroRect, operation: NSCompositingOperation.destinationOut, fraction: 1.0)
            iconImage.isTemplate = true
            iconImage.unlockFocus()
            
            copy[index].1 = iconImage
        }
        
        return copy
    }
    
    private func mergeIcons(iconsTupleArray: [(Bool, NSImage, Bool)], numberOfSpaces: Int, numberOfDisplays: Int) -> NSImage {
        let combinedIconWidth = CGFloat(iconsTupleArray.count) * ICON_SIZE.width
        let accomodatingGapWidth = CGFloat(iconsTupleArray.count - 1) * GAP_WIDTH
        let accomodatingDisplayGapWidth = CGFloat(numberOfDisplays - 1) * DISPLAY_GAP_WIDTH
        let totalWidth = combinedIconWidth + accomodatingGapWidth + accomodatingDisplayGapWidth
        let image = NSImage(size: NSSize(width: totalWidth, height: ICON_SIZE.height))
        
        image.lockFocus()
        var x = CGFloat.zero
        for iconTuple in iconsTupleArray {
            iconTuple.1.draw(at: NSPoint(x: x, y: CGFloat.zero), from: NSRect.zero, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            if iconTuple.0 { x += ICON_SIZE.width + DISPLAY_GAP_WIDTH }
            else { x += ICON_SIZE.width + GAP_WIDTH }
        }
        image.isTemplate = true
        image.unlockFocus()
        
        return image
    }
}
