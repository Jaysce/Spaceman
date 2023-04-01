//
//  IconBuilder.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import AppKit
import Foundation

class IconCreator {
    private let defaults = UserDefaults.standard
    private var iconSize = NSSize(width: 18, height: 12)
    private let gapWidth = CGFloat(5)
    private let displayGapWidth = CGFloat(15)
    private var displayCount = 1
    
    func getIcon(for spaces: [Space]) -> NSImage {
        iconSize.width = 18
        let spacemanStyle = SpacemanStyle(rawValue: defaults.integer(forKey: "displayStyle"))
        var icons = [NSImage]()
        
        for s in spaces {
            let iconResourceName: String
            switch (s.isCurrentSpace, s.isFullScreen) {
            case (true, true):
                iconResourceName = spacemanStyle == .text ? "NamedFullActive" : "SpaceManIconFullEn"
            case (true, false):
                iconResourceName = "SpaceManIcon"
            case (false, true):
                iconResourceName = spacemanStyle == .text ? "NamedFullInactive" : "SpaceManIconFullDis"
            default:
                iconResourceName = "SpaceManIconBorder"
            }
            
            icons.append(NSImage(imageLiteralResourceName: iconResourceName))
        }
        
        switch spacemanStyle {
        case .numbers:
            icons = createNumberedIcons(spaces)
        case .numbersAndRects:
            icons = createRectWithNumbersIcons(icons, spaces, desktopsOnly: false)
        case .desktopNumbersAndRects:
            icons = createRectWithNumbersIcons(icons, spaces, desktopsOnly: true)
        case .text:
            iconSize.width = 49
            icons = createNamedIcons(icons, spaces)
        default:
            break
        }
        
        let iconsWithDisplayProperties = getIconsWithDisplayProps(icons: icons, spaces: spaces)
        return mergeIcons(iconsWithDisplayProperties)
    }
    
    private func createNumberedIcons(_ spaces: [Space]) -> [NSImage] {
        var newIcons = [NSImage]()
        
        for s in spaces {
            let textRect = NSRect(origin: CGPoint.zero, size: iconSize)
            let spaceNumber = NSString(string: String(s.spaceNumber))
            let image = NSImage(size: iconSize)
            
            image.lockFocus()
            spaceNumber.drawVerticallyCentered(
                in: textRect,
                withAttributes: getStringAttributes(
                    alpha: !s.isCurrentSpace ? 0.4 : 1,
                    fontSize: 12))
            image.unlockFocus()
            
            newIcons.append(image)
        }
        
        return newIcons
    }
    
    private func createRectWithNumbersIcons(_ icons: [NSImage], _ spaces: [Space], desktopsOnly: Bool) -> [NSImage] {
        var index = 0
        var newIcons = [NSImage]()
        
        for s in spaces {
            let textRect = NSRect(origin: CGPoint.zero, size: iconSize)
            let number = desktopsOnly ? s.desktopNumber : s.spaceNumber
            let iconImage = NSImage(size: iconSize)
            let numberImage = NSImage(size: iconSize)

            if (number != nil) {
                numberImage.lockFocus()
                let spaceNumber = NSString(string: String(number!))
                spaceNumber.drawVerticallyCentered(
                    in: textRect,
                    withAttributes: getStringAttributes(alpha: 1))
                numberImage.unlockFocus()
            }
            
            iconImage.lockFocus()
            icons[index].draw(
                in: textRect,
                from: NSRect.zero,
                operation: NSCompositingOperation.sourceOver,
                fraction: 1.0)
            numberImage.draw(
                in: textRect,
                from: NSRect.zero,
                operation: NSCompositingOperation.destinationOut,
                fraction: 1.0)
            iconImage.isTemplate = true
            iconImage.unlockFocus()
            
            newIcons.append(iconImage)
            index += 1
        }
        
        return newIcons
    }
    
    private func createNamedIcons(_ icons: [NSImage], _ spaces: [Space]) -> [NSImage] {
        var index = 0
        var newIcons = [NSImage]()
        
        for s in spaces {
            let textRect = NSRect(origin: CGPoint.zero, size: iconSize)
            let spaceText = NSString(string: "\(s.spaceNumber): \(s.spaceName.uppercased())")
            let iconImage = NSImage(size: iconSize)
            let textImage = NSImage(size: iconSize)
            
            textImage.lockFocus()
            spaceText.drawVerticallyCentered(
                in: textRect,
                withAttributes: getStringAttributes(alpha: 1))
            textImage.unlockFocus()
            
            iconImage.lockFocus()
            icons[index].draw(
                in: textRect,
                from: NSRect.zero,
                operation: NSCompositingOperation.sourceOver,
                fraction: 1.0)
            textImage.draw(
                in: textRect,
                from: NSRect.zero,
                operation: NSCompositingOperation.destinationOut,
                fraction: 1.0)
            iconImage.isTemplate = true
            iconImage.unlockFocus()
            
            newIcons.append(iconImage)
            index += 1
        }
        
        return newIcons
    }
    
    func getIconsWithDisplayProps(icons: [NSImage], spaces: [Space]) -> [(NSImage, Bool)] {
        var iconsWithDisplayProperties = [(NSImage, Bool)]()
        var currentDisplayID = spaces[0].displayID
        displayCount = 1
        
        for index in 0 ..< spaces.count {
            var nextSpaceIsOnDifferentDisplay = false
            
            if index + 1 < spaces.count {
                let thisDispID = spaces[index + 1].displayID
                if thisDispID != currentDisplayID {
                    currentDisplayID = thisDispID
                    displayCount += 1
                    nextSpaceIsOnDifferentDisplay = true
                }
            }
            
            iconsWithDisplayProperties.append((icons[index], nextSpaceIsOnDifferentDisplay))
        }
        
        return iconsWithDisplayProperties
    }
    
    func mergeIcons(_ iconsWithDisplayProperties: [(image: NSImage, nextSpaceOnDifferentDisplay: Bool)]) -> NSImage {
        let numIcons = iconsWithDisplayProperties.count
        let combinedIconWidth = CGFloat(numIcons) * iconSize.width
        let accomodatingGapWidth = CGFloat(numIcons - 1) * gapWidth
        let accomodatingDisplayGapWidth = CGFloat(displayCount - 1) * displayGapWidth
        let totalWidth = combinedIconWidth + accomodatingGapWidth + accomodatingDisplayGapWidth
        let image = NSImage(size: NSSize(width: totalWidth, height: iconSize.height))
        
        image.lockFocus()
        var x = CGFloat.zero
        for icon in iconsWithDisplayProperties {
            icon.image.draw(
                at: NSPoint(x: x, y: 0),
                from: NSRect.zero,
                operation: NSCompositingOperation.sourceOver,
                fraction: 1.0)
            if icon.nextSpaceOnDifferentDisplay { x += iconSize.width + displayGapWidth}
            else { x += iconSize.width + gapWidth }
        }
        image.isTemplate = true
        image.unlockFocus()

        return image
    }

    private func getStringAttributes(alpha: CGFloat, fontSize: CGFloat = 10) -> [NSAttributedString.Key : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [
            .foregroundColor: NSColor.black.withAlphaComponent(alpha),
            .font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .bold),
            .paragraphStyle: paragraphStyle]
    }
}
