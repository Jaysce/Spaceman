//
//  IconBuilder.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import AppKit
import Foundation

class IconCreator {

    private let layoutMode = LayoutMode.normal
    private let defaults = UserDefaults.standard
    private var displayCount = 1
    private var iconSize: NSSize
    private var gapWidth: CGFloat
    private var displayGapWidth: CGFloat

    public var sizes: GuiSize!
    public var widths: [CGFloat] = []

    init() {
        sizes = Constants.sizes[layoutMode]
        gapWidth = CGFloat(sizes.GAP_WIDTH_SPACES)
        displayGapWidth = CGFloat(sizes.GAP_WIDTH_DISPLAYS)
        iconSize = NSSize(
            width: sizes.ICON_WIDTH_SMALL,
            height: sizes.ICON_HEIGHT)
    }
    
    func getIcon(for spaces: [Space]) -> NSImage {
        iconSize.width = CGFloat(sizes.ICON_WIDTH_SMALL)
        let spacemanStyle = SpacemanStyle(rawValue: defaults.integer(forKey: "displayStyle"))
        var icons = [NSImage]()
        
        for s in spaces {
            let iconResourceName: String
            switch (s.isCurrentSpace, s.isFullScreen, spacemanStyle) {
            case (true, true, .names):
                iconResourceName = "NamedFullActive"
            case (false, true, .names):
                iconResourceName = "NamedFullInactive"
            case (true, true, .rects):
                iconResourceName = "SpaceManIconFullEn"
            case (false, true, .rects):
                iconResourceName = "SpaceManIconFullDis"
            case (true, false, _):
                iconResourceName = "SpaceManIcon"
            default:
                // (true, true, .numbersAndNames)
                // (false, true, .numbersAndNames)
                iconResourceName = "SpaceManIconBorder"
            }
            
            icons.append(NSImage(imageLiteralResourceName: iconResourceName))
        }
        
        switch spacemanStyle {
        case .numbers:
            icons = createNumberedIcons(spaces)
        case .numbersAndRects:
            icons = createRectWithNumbersIcons(icons, spaces)
        case .names, .numbersAndNames:
            icons = createNamedIcons(icons, spaces, withNumbers: spacemanStyle == .numbersAndNames)
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
            let spaceID = s.desktopID
            
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
    
    func createRectWithNumberIcon(icons: [NSImage], index: Int, space: Space, fraction: Float = 1.0) -> NSImage {
        let textRect = NSRect(origin: CGPoint.zero, size: iconSize)
        let spaceID = space.desktopID
        
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
            let spaceID = s.desktopID
            let spaceNumberPrefix = withNumbers ? "\(spaceID): " : ""
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
    
    func getIconsWithDisplayProps(icons: [NSImage], spaces: [Space]) -> [(NSImage, Bool)] {
        var iconsWithDisplayProperties = [(NSImage, Bool)]()
        var currentDisplayID = spaces[0].displayID
        displayCount = 1
        
        let shouldBypassInactiveSpaces = defaults.bool(forKey: "hideInactiveSpaces")
        for index in 0 ..< spaces.count {
            if shouldBypassInactiveSpaces && !spaces[index].isCurrentSpace {
                continue
            }
            
            var nextSpaceIsOnDifferentDisplay = false
            
            if !shouldBypassInactiveSpaces && index + 1 < spaces.count {
                let thisDisplayID = spaces[index + 1].displayID
                if thisDisplayID != currentDisplayID {
                    currentDisplayID = thisDisplayID
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
        let combinedIconWidth = CGFloat(iconsWithDisplayProperties.reduce(0) { (result, icon) in
            result + icon.image.size.width
        })
        let accomodatingGapWidth = CGFloat(numIcons - 1) * gapWidth
        let accomodatingDisplayGapWidth = CGFloat(displayCount - 1) * displayGapWidth
        let totalWidth = combinedIconWidth + accomodatingGapWidth + accomodatingDisplayGapWidth
        let image = NSImage(size: NSSize(width: totalWidth, height: iconSize.height))
        
        image.lockFocus()
        var x = CGFloat.zero
        widths = [x]
        for icon in iconsWithDisplayProperties {
            icon.image.draw(
                at: NSPoint(x: x, y: 0),
                from: NSRect.zero,
                operation: NSCompositingOperation.sourceOver,
                fraction: 1.0)
            if icon.nextSpaceOnDifferentDisplay {
                x += icon.image.size.width + displayGapWidth
            } else {
                x += icon.image.size.width + gapWidth
            }
            widths.append(x + 4) /* TODO FIXME left margin */
        }
        image.isTemplate = true
        image.unlockFocus()
        widths.removeLast()
        
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
