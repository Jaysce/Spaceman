//
//  IconBuilder.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import AppKit
import Foundation

class IconBuilder {
    private let ICON_SIZE = NSSize(width: 18, height: 12)
    private let GAP_WIDTH = CGFloat(5)
    private let DISPLAY_GAP_WIDTH = CGFloat(15)
    
    func getIcon(for spaces: [Space]) -> NSImage {
        switch Preferences.shared.getDisplayType() {
        case .numbers:
            return createNumberedSpaces(for: spaces)
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
                iconResourceName = "SpaceManIconFullEn"
            case (true, false):
                iconResourceName = "SpaceManIcon"
            case (false, true):
                iconResourceName = "SpaceManIconFullDis"
            default:
                iconResourceName = "SpaceManIconBorder"
            }
            
            icons.append(NSImage(imageLiteralResourceName: iconResourceName))
        }
        
        if Preferences.shared.getDisplayType() == .both {
            return addNumbers(to: icons, for: spaces)
        }
        
        return merge(icons)
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
                withAttributes: getStringAttributes(alpha: !s.isCurrentSpace ? 0.4 : 1)
            )
            image.unlockFocus()
            
            icons.append(image)
        }
        
        return merge(icons)
    }
    
    private func addNumbers(to icons: [NSImage], for spaces: [Space]) -> NSImage {
        var index = 0
        var newIcons = [NSImage]()
        
        for s in spaces {
            let textRect = NSRect(origin: CGPoint.zero, size: ICON_SIZE)
            let spaceNumber = NSString(string: String(s.spaceNumber))
            let iconImage = NSImage(size: NSSize(width: ICON_SIZE.width, height: ICON_SIZE.height))
            let numberImage = NSImage(size: NSSize(width: ICON_SIZE.width, height: ICON_SIZE.height))
            
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
        
        return merge(newIcons)
    }
    
    private func merge(_ icons: [NSImage]) -> NSImage {
        let combinedIconWidth = CGFloat(icons.count) * ICON_SIZE.width
        let accomodatingGapWidth = CGFloat(icons.count - 1) * GAP_WIDTH
//        let accomodatingDisplayGapWidth = CGFloat(numberOfDisplays - 1) * DISPLAY_GAP_WIDTH
        let totalWidth = combinedIconWidth + accomodatingGapWidth
        let image = NSImage(size: NSSize(width: totalWidth, height: ICON_SIZE.height))
        
        image.lockFocus()
        var x = CGFloat.zero
        for icon in icons {
            icon.draw(at: NSPoint(x: x, y: 0),
                      from: NSRect.zero,
                      operation: NSCompositingOperation.sourceOver,
                      fraction: 1.0
            )
            x += ICON_SIZE.width + GAP_WIDTH
        }
        image.isTemplate = true
        image.unlockFocus()
        
        return image
    }
    
    private func getStringAttributes(alpha: CGFloat) -> [NSAttributedString.Key : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return [
            .foregroundColor: NSColor.black.withAlphaComponent(alpha),
            .font: NSFont.monospacedSystemFont(ofSize: 10, weight: .bold),
            .paragraphStyle: paragraphStyle
        ]
    }
}
