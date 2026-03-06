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

        for space in spaces {
            let iconResourceName: String
            switch (space.isCurrentSpace, space.isFullScreen) {
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
            icons = createNamedIcons(icons, spaces)
        default:
            break
        }

        let iconsWithDisplayProperties = getIconsWithDisplayProps(icons: icons, spaces: spaces)
        return mergeIcons(iconsWithDisplayProperties)
    }

    private func createNumberedIcons(_ spaces: [Space]) -> [NSImage] {
        var newIcons = [NSImage]()

        for space in spaces {
            let textRect = NSRect(origin: CGPoint.zero, size: iconSize)
            let spaceNumber = NSString(string: String(space.spaceNumber))
            let image = NSImage(size: iconSize)

            image.lockFocus()
            spaceNumber.drawVerticallyCentered(
                in: textRect,
                withAttributes: getStringAttributes(
                    alpha: !space.isCurrentSpace ? 0.4 : 1,
                    fontSize: 12))
            image.unlockFocus()

            newIcons.append(image)
        }

        return newIcons
    }

    private func createRectWithNumbersIcons(_ icons: [NSImage], _ spaces: [Space], desktopsOnly: Bool) -> [NSImage] {
        var index = 0
        var newIcons = [NSImage]()

        for space in spaces {
            let textRect = NSRect(origin: CGPoint.zero, size: iconSize)
            let number = desktopsOnly ? space.desktopNumber : space.spaceNumber
            let iconImage = NSImage(size: iconSize)
            let numberImage = NSImage(size: iconSize)

            if let number {
                numberImage.lockFocus()
                let spaceNumber = NSString(string: String(number))
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
        var newIcons = [NSImage]()
        let padding = CGFloat(12)
        let cornerRadius = CGFloat(3)

        for space in spaces {
            let spaceText = NSString(string: "\(space.spaceNumber): \(space.spaceName.uppercased())")
            let isActive = space.isCurrentSpace

            let textAttrs = getStringAttributes(alpha: 1, fontSize: 10)
            let textSize = spaceText.size(withAttributes: textAttrs)
            let dynamicWidth = max(textSize.width + padding, 49)
            let dynamicSize = NSSize(width: dynamicWidth, height: iconSize.height)
            let iconImage = NSImage(size: dynamicSize)

            iconImage.lockFocus()

            let bgRect = NSRect(origin: CGPoint.zero, size: dynamicSize)
            let bgPath = NSBezierPath(roundedRect: bgRect.insetBy(dx: 1, dy: 0.5), xRadius: cornerRadius, yRadius: cornerRadius)

            if isActive {
                // Active: filled background, text cut out via destinationOut
                NSColor.black.setFill()
                bgPath.fill()

                let textImage = NSImage(size: dynamicSize)
                textImage.lockFocus()
                spaceText.drawVerticallyCentered(
                    in: bgRect,
                    withAttributes: textAttrs)
                textImage.unlockFocus()

                textImage.draw(
                    in: bgRect,
                    from: NSRect.zero,
                    operation: NSCompositingOperation.destinationOut,
                    fraction: 1.0)
            } else {
                // Inactive: border + direct text, all in black (template handles color)
                NSColor.black.withAlphaComponent(0.6).setStroke()
                bgPath.lineWidth = 1.0
                bgPath.stroke()

                let inactiveAttrs = getStringAttributes(alpha: 0.6, fontSize: 10)
                spaceText.drawVerticallyCentered(
                    in: bgRect,
                    withAttributes: inactiveAttrs)
            }

            iconImage.isTemplate = true
            iconImage.unlockFocus()

            newIcons.append(iconImage)
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
        let combinedIconWidth = iconsWithDisplayProperties.reduce(CGFloat.zero) { $0 + $1.image.size.width }
        let numIcons = iconsWithDisplayProperties.count
        let accomodatingGapWidth = CGFloat(numIcons - 1) * gapWidth
        let accomodatingDisplayGapWidth = CGFloat(displayCount - 1) * displayGapWidth
        let totalWidth = combinedIconWidth + accomodatingGapWidth + accomodatingDisplayGapWidth
        let image = NSImage(size: NSSize(width: totalWidth, height: iconSize.height))

        image.lockFocus()
        var xOffset = CGFloat.zero
        for icon in iconsWithDisplayProperties {
            icon.image.draw(
                at: NSPoint(x: xOffset, y: 0),
                from: NSRect.zero,
                operation: NSCompositingOperation.sourceOver,
                fraction: 1.0)
            if icon.nextSpaceOnDifferentDisplay {
                xOffset += icon.image.size.width + displayGapWidth
            } else {
                xOffset += icon.image.size.width + gapWidth
            }
        }
        image.isTemplate = true
        image.unlockFocus()

        return image
    }

    private func getStringAttributes(alpha: CGFloat, fontSize: CGFloat = 10) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [
            .foregroundColor: NSColor.black.withAlphaComponent(alpha),
            .font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .bold),
            .paragraphStyle: paragraphStyle]
    }
}
