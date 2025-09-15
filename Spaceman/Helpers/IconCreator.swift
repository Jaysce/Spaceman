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
    // Legacy flag kept for backward compatibility; use visibleSpacesMode instead
    @AppStorage("hideInactiveSpaces") private var hideInactiveSpaces = false
    @AppStorage("visibleSpacesMode") private var visibleSpacesModeRaw: Int = VisibleSpacesMode.all.rawValue
    private var visibleSpacesMode: VisibleSpacesMode {
        get { VisibleSpacesMode(rawValue: visibleSpacesModeRaw) ?? .all }
        set { visibleSpacesModeRaw = newValue.rawValue }
    }
    
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

        // Precompute switch indices for all spaces (global mapping)
        var switchIndexBySpaceID: [String: Int] = [:]
        var nonFullIndex = 1
        var fullIndex = 1
        for s in spaces {
            if s.isFullScreen {
                // Map first two fullscreen spaces to -1 and -2
                if fullIndex <= 2 {
                    switchIndexBySpaceID[s.spaceID] = -fullIndex
                }
                fullIndex += 1
            } else {
                if nonFullIndex <= 10 {
                    switchIndexBySpaceID[s.spaceID] = nonFullIndex
                }
                nonFullIndex += 1
            }
        }

        // Determine which spaces to include based on mode
        let filteredSpaces = filterSpaces(spaces)

        for s in filteredSpaces {
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
            icons = createNumberedIcons(filteredSpaces)
        case .numbersAndRects:
            icons = createRectWithNumbersIcons(icons, filteredSpaces)
        case .names, .numbersAndNames:
            icons = createNamedIcons(icons, filteredSpaces, withNumbers: displayStyle == .numbersAndNames)
        }
        
        let iconsWithDisplayProperties = getIconsWithDisplayProps(icons: icons, spaces: filteredSpaces)
        return mergeIcons(iconsWithDisplayProperties, indexMap: switchIndexBySpaceID)
    }

    private func filterSpaces(_ spaces: [Space]) -> [Space] {
        // Backwards compatibility: if legacy flag is true and visible mode wasn't set explicitly, treat as current only
        let mode: VisibleSpacesMode = {
            if UserDefaults.standard.object(forKey: "visibleSpacesMode") == nil && hideInactiveSpaces {
                return .currentOnly
            }
            return visibleSpacesMode
        }()
        switch mode {
        case .all:
            return spaces
        case .currentOnly:
            return spaces.filter { $0.isCurrentSpace }
        case .neighbors:
            var filtered: [Space] = []
            var group: [Space] = []
            var currentDisplayID = spaces.first?.displayID ?? ""
            func flushGroup() {
                guard group.count > 0 else { return }
                if let activeIndex = group.firstIndex(where: { $0.isCurrentSpace }) {
                    let start = max(0, activeIndex - 1)
                    let end = min(group.count - 1, activeIndex + 1)
                    filtered.append(contentsOf: group[start...end])
                }
                group.removeAll(keepingCapacity: true)
            }
            for s in spaces {
                if s.displayID != currentDisplayID {
                    flushGroup()
                    currentDisplayID = s.displayID
                }
                group.append(s)
            }
            flushGroup()
            return filtered
        }
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
            let rawName = s.spaceName.uppercased()
            // When showing all spaces, keep legacy 4-char display for names to save space
            let shownName = (visibleSpacesMode == .all) ? String(rawName.prefix(4)) : rawName
            let spaceText = NSString(string: "\(spaceNumberPrefix)\(shownName)")
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
    
    private func getIconsWithDisplayProps(icons: [NSImage], spaces: [Space]) -> [(NSImage, Bool, Bool, String)] {
        var iconsWithDisplayProperties = [(NSImage, Bool, Bool, String)]()
        guard spaces.count > 0 else { return iconsWithDisplayProperties }
        var currentDisplayID = spaces[0].displayID
        displayCount = 1

        for index in 0 ..< spaces.count {
            var nextSpaceIsOnDifferentDisplay = false
            if index + 1 < spaces.count {
                let nextDisplayID = spaces[index + 1].displayID
                if nextDisplayID != currentDisplayID {
                    currentDisplayID = nextDisplayID
                    displayCount += 1
                    nextSpaceIsOnDifferentDisplay = true
                }
            }
            iconsWithDisplayProperties.append((icons[index], nextSpaceIsOnDifferentDisplay, spaces[index].isFullScreen, spaces[index].spaceID))
        }

        return iconsWithDisplayProperties
    }
    
    private func mergeIcons(_ iconsWithDisplayProperties: [(image: NSImage, nextSpaceOnDifferentDisplay: Bool, isFullScreen: Bool, spaceID: String)], indexMap: [String: Int]) -> NSImage {
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
            // Use precomputed index mapping to preserve correct switching
            let targetIndex = indexMap[icon.spaceID] ?? -99 // invalid => onError
            iconWidths.append(IconWidth(left: left + leftMargin, right: right + leftMargin, index: targetIndex))
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
