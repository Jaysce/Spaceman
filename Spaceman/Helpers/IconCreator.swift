//
//  IconCreator.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import AppKit
import Foundation
import SwiftUI

class IconCreator {
    @AppStorage("layoutMode") private var layoutMode = LayoutMode.medium
    @AppStorage("displayStyle") private var displayStyle = DisplayStyle.numbersAndRects
    @AppStorage("hideInactiveSpaces") private var hideInactiveSpaces = false
    
    private let leftMargin = CGFloat(7)  /* FIXME determine actual left margin */
    private var displayCount = 1
    private var iconSize = NSSize(width: 0, height: 0)
    private var gapWidth = CGFloat.zero
    private var displayGapWidth = CGFloat.zero

    public var sizes: GuiSize!
    public var iconWidths: [IconWidth] = []

    public func getIcon(for spaces: [Space]) -> NSImage {
        sizes = Constants.sizes[layoutMode]
        gapWidth = CGFloat(sizes.GAP_WIDTH_SPACES)
        displayGapWidth = CGFloat(sizes.GAP_WIDTH_DISPLAYS)
        iconSize = NSSize(
            width: sizes.ICON_WIDTH_SMALL,
            height: sizes.ICON_HEIGHT)
        
        var icons = [NSImage]()
        
        for s in spaces {
            let iconResourceName: String
            switch (s.isCurrentSpace, s.isFullScreen, displayStyle) {
            case (true, true, .names):
                iconResourceName = "SpaceIconNamedFullActive"
            case (false, true, .names):
                iconResourceName = "SpaceIconNamedFullInactive"
            case (true, true, .rects):
                iconResourceName = "SpaceIconNumFullActive"
            case (false, true, .rects):
                iconResourceName = "SpaceIconNumFullInactive"
            case (true, false, _):
                iconResourceName = "SpaceIconNumNormalActive"
            default:
                // (true, true, .numbersAndNames)
                // (false, true, .numbersAndNames)
                iconResourceName = "SpaceIconNumNormalInactive"
            }
            
            icons.append(NSImage(imageLiteralResourceName: iconResourceName))
        }
        
        switch displayStyle {
        case .rects:
            //icons = resizeIcons(spaces, icons, layoutMode)
            break
        case .numbers:
            icons = createNumberedIcons(spaces)
        case .numbersAndRects:
            icons = createRectWithNumbersIcons(icons, spaces)
        case .names, .numbersAndNames:
            icons = createNamedIcons(icons, spaces, withNumbers: displayStyle == .numbersAndNames)
        }
        
        let iconsWithDisplayProperties = getIconsWithDisplayProps(icons: icons, spaces: spaces)
        return mergeIcons(iconsWithDisplayProperties)
    }

    private func createNumberedIcons(_ spaces: [Space]) -> [NSImage] {
        var newIcons = [NSImage]()
        
        for s in spaces {
            let textRect = NSRect(origin: CGPoint.zero, size: iconSize)
            let spaceID = s.spaceByDesktopID
            
            let image = NSImage(size: iconSize)
            
            image.lockFocus()
            spaceID.drawVerticallyCentered(
                in: textRect,
                withAttributes: getStringAttributes(alpha: !s.isCurrentSpace ? 0.4 : 1))
            image.unlockFocus()
            
            newIcons.append(image)
        }
        return newIcons
    }
    
    public func createRectWithNumberIcon(icons: [NSImage], index: Int, space: Space, fraction: Float = 1.0) -> NSImage {
        iconSize.width = CGFloat(sizes.ICON_WIDTH_SMALL)
        
        let textRect = NSRect(origin: CGPoint.zero, size: iconSize)
        let spaceID = space.spaceByDesktopID
        
        let iconImage = NSImage(size: iconSize)
        let numberImage = NSImage(size: iconSize)
        
        numberImage.lockFocus()
        spaceID.drawVerticallyCentered(
            in: textRect,
            withAttributes: getStringAttributes(alpha: 1))
        numberImage.unlockFocus()
        
        iconImage.lockFocus()
        icons[index].draw(
            in: textRect,
            from: NSRect.zero,
            operation: NSCompositingOperation.sourceOver,
            fraction: CGFloat(fraction))
        numberImage.draw(
            in: textRect,
            from: NSRect.zero,
            operation: NSCompositingOperation.destinationOut,
            fraction: 1.0)
        iconImage.isTemplate = true
        iconImage.unlockFocus()
        return iconImage
    }

    private func createRectWithNumbersIcons(_ icons: [NSImage], _ spaces: [Space]) -> [NSImage] {
        var index = 0
        var newIcons = [NSImage]()
        for s in spaces {
            let iconImage = createRectWithNumberIcon(icons: icons, index: index, space: s)
            newIcons.append(iconImage)
            index += 1
        }
        return newIcons
    }
    
    private func createNamedIcons(_ icons: [NSImage], _ spaces: [Space], withNumbers: Bool) -> [NSImage] {
        var index = 0
        var newIcons = [NSImage]()

        iconSize.width = CGFloat(withNumbers ? sizes.ICON_WIDTH_XLARGE : sizes.ICON_WIDTH_LARGE)
        
        for s in spaces {
            let spaceID = s.spaceByDesktopID
            let spaceNumberPrefix = withNumbers ? "\(spaceID):" : ""
            let spaceText = NSString(string: "\(spaceNumberPrefix)\(s.spaceName.uppercased())")
            let textSize = spaceText.size(withAttributes: getStringAttributes(alpha: 1))
            let textWithMarginSize = NSMakeSize(textSize.width + 4, CGFloat(sizes.ICON_HEIGHT))
            
            // Check if the text width exceeds the icon's width
            let textImageSize = textSize.width > iconSize.width ? textWithMarginSize : iconSize
            let iconImage = NSImage(size: textImageSize)
            let textImage = NSImage(size: textImageSize)
            let textRect = NSRect(origin: CGPoint.zero, size: textImageSize)
            
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
    
    private func getIconsWithDisplayProps(icons: [NSImage], spaces: [Space]) -> [(NSImage, Bool, Bool)] {
        var iconsWithDisplayProperties = [(NSImage, Bool, Bool)]()
        var currentDisplayID = spaces[0].displayID
        displayCount = 1
        
        for index in 0 ..< spaces.count {
            if hideInactiveSpaces && !spaces[index].isCurrentSpace {
                continue
            }
            
            var nextSpaceIsOnDifferentDisplay = false
            
            if !hideInactiveSpaces && index + 1 < spaces.count {
                let thisDisplayID = spaces[index + 1].displayID
                if thisDisplayID != currentDisplayID {
                    currentDisplayID = thisDisplayID
                    displayCount += 1
                    nextSpaceIsOnDifferentDisplay = true
                }
            }
            
            iconsWithDisplayProperties.append((icons[index], nextSpaceIsOnDifferentDisplay, spaces[index].isFullScreen))
        }
        
        return iconsWithDisplayProperties
    }
    
    private func mergeIcons(_ iconsWithDisplayProperties: [(image: NSImage, nextSpaceOnDifferentDisplay: Bool, isFullScreen: Bool)]) -> NSImage {
        let numIcons = iconsWithDisplayProperties.count
        let combinedIconWidth = CGFloat(iconsWithDisplayProperties.reduce(0) { (result, icon) in
            result + icon.image.size.width
        })
        let accomodatingGapWidth = CGFloat(numIcons - 1) * gapWidth
        let accomodatingDisplayGapWidth = CGFloat(displayCount - 1) * displayGapWidth
        let totalWidth = combinedIconWidth + accomodatingGapWidth + accomodatingDisplayGapWidth
        let image = NSImage(size: NSSize(width: totalWidth, height: iconSize.height))
        
        image.lockFocus()
        var left = CGFloat.zero
        var right: CGFloat
        iconWidths = []
        for icon in iconsWithDisplayProperties {
            icon.image.draw(
                at: NSPoint(x: left, y: 0),
                from: NSRect.zero,
                operation: NSCompositingOperation.sourceOver,
                fraction: 1.0)
            if icon.nextSpaceOnDifferentDisplay {
                right = left + icon.image.size.width + displayGapWidth
            } else {
                right = left + icon.image.size.width + gapWidth
            }
            if !icon.isFullScreen {
                iconWidths.append(IconWidth(left: left + leftMargin, right: right + leftMargin))
            }
            left = right
        }
        image.isTemplate = true
        image.unlockFocus()
        
        return image
    }

    private func getStringAttributes(alpha: CGFloat, fontSize: CGFloat = .zero) -> [NSAttributedString.Key : Any] {
        let actualFontSize = fontSize == .zero ? CGFloat(sizes.FONT_SIZE) : fontSize
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [
            .foregroundColor: NSColor.black.withAlphaComponent(alpha),
            .font: NSFont.monospacedSystemFont(ofSize: actualFontSize, weight: .bold),
            .paragraphStyle: paragraphStyle]
    }
}
