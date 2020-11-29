//
//  IconBuilder.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import AppKit
import Foundation

class IconBuilder {
    private var ICON_SIZE: NSSize!
    private let GAP_WIDTH = CGFloat(5)
    private let DISPLAY_GAP_WIDTH = CGFloat(15)
    private var DISPLAY_COUNT = 1
    private let prefs = Preferences.shared
    
    func getIcon(for spaces: [Space]) -> NSImage {
        ICON_SIZE = NSSize(width: 18, height: 12)
        
        switch Preferences.shared.getDisplayType() {
        case .numbers:
            return createNumberedSpaces(for: spaces)
        case .text:
            ICON_SIZE = NSSize(width: 45, height: 12)
            fallthrough
        default:
            return createSimpleSpaces(for: spaces)
        }
    }
    
    private func createSimpleSpaces(for spaces: [Space]) -> NSImage {
        var icons = [NSImage]()
        
        for s in spaces {
            let iconResourceName: String
            
            switch (s.isCurrentSpace, s.isFullScreen) {
            case (true, true):
                iconResourceName = prefs.getDisplayType() == .text ? "SpaceManIcon" : "SpaceManIconFullEn"
            case (true, false):
                iconResourceName = "SpaceManIcon"
            case (false, true):
                iconResourceName = prefs.getDisplayType() == .text ? "SpaceManIconBorder" : "SpaceManIconFullDis"
            default:
                iconResourceName = "SpaceManIconBorder"
            }
            
            icons.append(NSImage(imageLiteralResourceName: iconResourceName))
        }
        
        if Preferences.shared.getDisplayType() == .both {
            return addNumbers(to: icons, for: spaces)
        }
        else if Preferences.shared.getDisplayType() == .text {
            return addText(to: icons, for: spaces)
        }
        
        return merge(displayHelper(iconImages: icons, spaces: spaces))
    }
    
    private func createNumberedSpaces(for spaces: [Space]) -> NSImage {
        var icons = [NSImage]()
        
        for s in spaces {
            let textRect = NSRect(origin: CGPoint.zero, size: ICON_SIZE)
            let spaceNumber = NSString(string: String(s.spaceNumber))
            let image = NSImage(size: ICON_SIZE)
            
            image.lockFocus()
            spaceNumber.drawVerticallyCentered(
                in: textRect,
                withAttributes: getStringAttributes(alpha: !s.isCurrentSpace ? 0.4 : 1, fontSize: 12)
            )
            image.unlockFocus()
            
            icons.append(image)
        }
        
        return merge(displayHelper(iconImages: icons, spaces: spaces))
    }
    
    private func addNumbers(to icons: [NSImage], for spaces: [Space]) -> NSImage {
        var index = 0
        var newIcons = [NSImage]()
        
        for s in spaces {
            let textRect = NSRect(origin: CGPoint.zero, size: ICON_SIZE)
            let spaceNumber = NSString(string: String(s.spaceNumber))
            let iconImage = NSImage(size: ICON_SIZE)
            let numberImage = NSImage(size: ICON_SIZE)
            
            numberImage.lockFocus()
            spaceNumber.drawVerticallyCentered(in: textRect, withAttributes: getStringAttributes(alpha: 1))
            numberImage.unlockFocus()
            
            iconImage.lockFocus()
            icons[index].draw(in: textRect,
                              from: NSRect.zero,
                              operation: NSCompositingOperation.sourceOver,
                              fraction: 1.0
            )
            numberImage.draw(in: textRect,
                             from: NSRect.zero,
                             operation: NSCompositingOperation.destinationOut,
                             fraction: 1.0
            )
            iconImage.isTemplate = true
            iconImage.unlockFocus()
            
            newIcons.append(iconImage)
            index += 1
        }
        
        return merge(displayHelper(iconImages: newIcons, spaces: spaces))
    }
    
    private func addText(to icons: [NSImage], for spaces: [Space]) -> NSImage {
        var index = 0
        var newIcons = [NSImage]()
        
        for s in spaces {
            let textRect = NSRect(origin: CGPoint.zero, size: ICON_SIZE)
            let spaceText = NSString(string: "\(s.spaceNumber): \(s.isFullScreen ? "FUL" : s.spaceName.uppercased())")
            let iconImage = NSImage(size: ICON_SIZE)
            let textImage = NSImage(size: ICON_SIZE)
            
            textImage.lockFocus()
            spaceText.drawVerticallyCentered(in: textRect, withAttributes: getStringAttributes(alpha: 1))
            textImage.unlockFocus()
            
            iconImage.lockFocus()
            icons[index].draw(in: textRect,
                              from: NSRect.zero,
                              operation: NSCompositingOperation.sourceOver,
                              fraction: 1.0
            )
            textImage.draw(in: textRect,
                             from: NSRect.zero,
                             operation: NSCompositingOperation.destinationOut,
                             fraction: 1.0
            )
            iconImage.isTemplate = true
            iconImage.unlockFocus()
            
            newIcons.append(iconImage)
            index += 1
        }
        
        return merge(displayHelper(iconImages: newIcons, spaces: spaces))
    }
    
    private func merge(_ icons: [(NSImage, Bool)]) -> NSImage {
        let combinedIconWidth = CGFloat(icons.count) * ICON_SIZE.width
        let accomodatingGapWidth = CGFloat(icons.count - 1) * GAP_WIDTH
        let accomodatingDisplayGapWidth = CGFloat(DISPLAY_COUNT - 1) * DISPLAY_GAP_WIDTH
        let totalWidth = combinedIconWidth + accomodatingGapWidth + accomodatingDisplayGapWidth
        let image = NSImage(size: NSSize(width: totalWidth, height: ICON_SIZE.height))
        
        image.lockFocus()
        var x = CGFloat.zero
        for icon in icons {
            icon.0.draw(at: NSPoint(x: x, y: 0),
                      from: NSRect.zero,
                      operation: NSCompositingOperation.sourceOver,
                      fraction: 1.0
            )
            if icon.1 { x += ICON_SIZE.width + DISPLAY_GAP_WIDTH}
            else { x += ICON_SIZE.width + GAP_WIDTH }
        }
        image.isTemplate = true
        image.unlockFocus()
        
        return image
    }
    
    private func displayHelper(iconImages: [NSImage], spaces: [Space]) -> [(NSImage, Bool)] {
        var tupleArray = [(NSImage, Bool)]()
        var currentDisplayID = spaces[0].displayID
        DISPLAY_COUNT = 1
        
        for index in 0 ..< spaces.count {
            var nextSpaceIsOnDifferentDisplay = false
            
            if index + 1 < spaces.count {
                let thisDispID = spaces[index + 1].displayID
                if thisDispID != currentDisplayID {
                    currentDisplayID = thisDispID
                    DISPLAY_COUNT += 1
                    nextSpaceIsOnDifferentDisplay = true
                }
            }
            
            tupleArray.append((iconImages[index], nextSpaceIsOnDifferentDisplay))
        }
        
        return tupleArray
    }
    
    private func getStringAttributes(alpha: CGFloat, fontSize: CGFloat = 10) -> [NSAttributedString.Key : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return [
            .foregroundColor: NSColor.black.withAlphaComponent(alpha),
            .font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .bold),
            .paragraphStyle: paragraphStyle
        ]
    }
}
