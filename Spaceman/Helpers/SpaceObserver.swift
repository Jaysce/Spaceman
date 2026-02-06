//
//  SpaceObserver.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Cocoa
import Foundation

class SpaceObserver {
    private struct DisplayInfo {
        let activeSpaceID: Int
        let spaces: [[String: Any]]
        let displayID: String
    }

    private struct SpaceBuildResult {
        let spaces: [Space]
        let updatedNames: [String: SpaceNameInfo]
        let nextIndex: Int
    }

    private let workspace = NSWorkspace.shared
    private let conn = _CGSDefaultConnection()
    private let defaults = UserDefaults.standard
    weak var delegate: SpaceObserverDelegate?

    init() {
        workspace.notificationCenter.addObserver(
            self,
            selector: #selector(updateSpaceInformation),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: workspace)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSpaceInformation),
            name: NSNotification.Name("ButtonPressed"),
            object: nil)
    }

    @objc public func updateSpaceInformation() {
        guard let displays = CGSCopyManagedDisplaySpaces(conn) as? [[String: Any]] else {
            return
        }

        let savedSpaceNames = loadSavedSpaceNames()
        var spacesIndex = 0
        var allSpaces = [Space]()
        var updatedDict = [String: SpaceNameInfo]()

        for display in displays {
            guard let parsedDisplay = parseDisplay(display) else {
                continue
            }

            if parsedDisplay.activeSpaceID == -1 {
                DispatchQueue.main.async {
                    print("Can't find current space")
                }
                return
            }

            let builtSpaces = appendSpaces(
                for: parsedDisplay,
                savedSpaceNames: savedSpaceNames,
                startIndex: spacesIndex)
            allSpaces.append(contentsOf: builtSpaces.spaces)
            updatedDict.merge(builtSpaces.updatedNames) { _, new in new }
            spacesIndex = builtSpaces.nextIndex
        }

        defaults.set(try? PropertyListEncoder().encode(updatedDict), forKey: "spaceNames")
        delegate?.didUpdateSpaces(spaces: allSpaces)
    }

    private func parseDisplay(_ display: [String: Any]) -> DisplayInfo? {
        guard let currentSpaceInfo = display["Current Space"] as? [String: Any],
              let spaces = display["Spaces"] as? [[String: Any]],
              let displayID = display["Display Identifier"] as? String,
              let activeSpaceID = currentSpaceInfo["ManagedSpaceID"] as? Int
        else {
            return nil
        }

        return DisplayInfo(activeSpaceID: activeSpaceID, spaces: spaces, displayID: displayID)
    }

    private func appendSpaces(
        for display: DisplayInfo,
        savedSpaceNames: [String: SpaceNameInfo],
        startIndex: Int
    ) -> SpaceBuildResult {
        var spacesIndex = startIndex
        var lastDesktopNumber = 0
        var spaces = [Space]()
        var updatedNames = [String: SpaceNameInfo]()

        for spaceInfo in display.spaces {
            guard let managedSpaceID = spaceInfo["ManagedSpaceID"] as? Int else {
                continue
            }

            let spaceID = String(managedSpaceID)
            let spaceNumber: Int = spacesIndex + 1
            let isCurrentSpace = display.activeSpaceID == managedSpaceID
            let isFullScreen = spaceInfo["TileLayoutManager"] is [String: Any]
            let desktopNumber: Int?

            if isFullScreen {
                desktopNumber = nil
            } else {
                lastDesktopNumber += 1
                desktopNumber = lastDesktopNumber
            }

            let space = Space(
                displayID: display.displayID,
                spaceID: spaceID,
                spaceName: savedSpaceNames[spaceID]?.spaceName
                    ?? defaultSpaceName(for: spaceInfo, isFullScreen: isFullScreen),
                spaceNumber: spaceNumber,
                desktopNumber: desktopNumber,
                isCurrentSpace: isCurrentSpace,
                isFullScreen: isFullScreen)

            updatedNames[spaceID] = SpaceNameInfo(spaceNum: spaceNumber, spaceName: space.spaceName)
            spaces.append(space)
            spacesIndex += 1
        }

        return SpaceBuildResult(spaces: spaces, updatedNames: updatedNames, nextIndex: spacesIndex)
    }

    private func defaultSpaceName(for spaceInfo: [String: Any], isFullScreen: Bool) -> String {
        guard isFullScreen else {
            return "N/A"
        }

        if let pid = spaceInfo["pid"] as? pid_t,
           let app = NSRunningApplication(processIdentifier: pid),
           let name = app.localizedName {
            return name.prefix(3).uppercased()
        }

        return "FUL"
    }

    private func loadSavedSpaceNames() -> [String: SpaceNameInfo] {
        guard let data = defaults.value(forKey: "spaceNames") as? Data else {
            return [:]
        }

        return (try? PropertyListDecoder().decode([String: SpaceNameInfo].self, from: data)) ?? [:]
    }
}

protocol SpaceObserverDelegate: AnyObject {
    func didUpdateSpaces(spaces: [Space])
}
