//
//  SpaceObserver.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Cocoa
import Foundation

class SpaceObserver {
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
        let displays = CGSCopyManagedDisplaySpaces(conn)!.takeRetainedValue() as! [NSDictionary]
        var activeSpaceID = -1
        var spacesIndex = 0
        var allSpaces = [Space]()
        var updatedDict = [String: SpaceNameInfo]()
        
        for d in displays {
            guard let currentSpaces = d["Current Space"] as? [String: Any],
                  let spaces = d["Spaces"] as? [[String: Any]],
                  let displayID = d["Display Identifier"] as? String
            else {
                continue
            }
            
            activeSpaceID = currentSpaces["ManagedSpaceID"] as! Int
            
            if activeSpaceID == -1 {
                DispatchQueue.main.async {
                    print("Can't find current space")
                }
                return
            }

            var lastDesktopNumber = 0

            for s in spaces {
                let spaceID = String(s["ManagedSpaceID"] as! Int)
                let spaceNumber: Int = spacesIndex + 1
                let isCurrentSpace = activeSpaceID == s["ManagedSpaceID"] as! Int
                let isFullScreen = s["TileLayoutManager"] as? [String: Any] != nil
                var desktopNumber : Int?
                if !isFullScreen {
                    lastDesktopNumber += 1
                    desktopNumber = lastDesktopNumber
                }
                var space = Space(displayID: displayID,
                                  spaceID: spaceID,
                                  spaceName: "-",
                                  spaceNumber: spaceNumber,
                                  desktopNumber: desktopNumber,
                                  isCurrentSpace: isCurrentSpace,
                                  isFullScreen: isFullScreen)
                
                if let data = defaults.value(forKey:"spaceNames") as? Data,
                   let dict = try? PropertyListDecoder().decode(Dictionary<String, SpaceNameInfo>.self, from: data),
                   let saved = dict[spaceID] {
                    space.spaceName = saved.spaceName
                } else if isFullScreen {
                    if let pid = s["pid"] as? pid_t,
                       let app = NSRunningApplication(processIdentifier: pid),
                       let name = app.localizedName {
                        space.spaceName = name.prefix(4).uppercased()
                    } else {
                        space.spaceName = "FULL"
                    }
                }
                
                let nameInfo = SpaceNameInfo(spaceNum: spaceNumber, spaceName: space.spaceName)
                updatedDict[spaceID] = nameInfo
                allSpaces.append(space)
                spacesIndex += 1
            }
        }
        
        defaults.set(try? PropertyListEncoder().encode(updatedDict), forKey: "spaceNames")
        delegate?.didUpdateSpaces(spaces: allSpaces)
    }
}

protocol SpaceObserverDelegate: AnyObject {
    func didUpdateSpaces(spaces: [Space])
}
