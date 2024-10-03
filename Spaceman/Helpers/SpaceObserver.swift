//
//  SpaceObserver.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Cocoa
import Foundation
import SwiftUI

class SpaceObserver {
    @AppStorage("restartNumberingByDesktop") private var restartNumberingByDesktop = false
    
    private let workspace = NSWorkspace.shared
    private let conn = _CGSDefaultConnection()
    private let defaults = UserDefaults.standard
    private let spaceNameCache = SpaceNameCache()

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
    
    func display1IsLeft(display1: NSDictionary, display2: NSDictionary) -> Bool {
        let d1Center = getDisplayCenter(display: display1)
        let d2Center = getDisplayCenter(display: display2)
        return d1Center.x < d2Center.x
    }
    
    func getDisplayCenter(display: NSDictionary) -> CGPoint {
        guard let uuidString = display["Display Identifier"] as? String
        else {
            return CGPoint(x: 0, y: 0)
        }
        let uuid = CFUUIDCreateFromString(kCFAllocatorDefault, uuidString as CFString)
        let dId = CGDisplayGetDisplayIDFromUUID(uuid)
        let bounds = CGDisplayBounds(dId);
        return CGPoint(x: bounds.origin.x + bounds.size.width/2, y: bounds.origin.y + bounds.size.height/2)
    }
    
    @objc public func updateSpaceInformation() {
        var displays = CGSCopyManagedDisplaySpaces(conn)!.takeRetainedValue() as! [NSDictionary]

        // create dict with correct sorting before changing it
        var spaceNumberDict: [String: Int] = [:]
        var spacesIndex = 1
        for d in displays {
            guard let spaces = d["Spaces"] as? [[String: Any]]
            else {
                continue
            }
            
            for s in spaces {
                let managedSpaceID = String(s["ManagedSpaceID"] as! Int)
                spaceNumberDict[managedSpaceID] = spacesIndex
                spacesIndex += 1
            }
        }
        
        // sort displays based on location
        displays.sort(by: {
            display1IsLeft(display1: $0, display2: $1)
        })
        
        var activeSpaceID = -1
        var allSpaces = [Space]()
        var updatedDict = [String: SpaceNameInfo]()
        var lastSpaceByDesktopNumber = 0
        
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

            var lastFullScreenSpaceNumber = 0
            if (restartNumberingByDesktop) {
                lastSpaceByDesktopNumber = 0
            }

            for s in spaces {
                let managedSpaceID = String(s["ManagedSpaceID"] as! Int)
                let spaceNumber = spaceNumberDict[managedSpaceID]!
                let isCurrentSpace = activeSpaceID == s["ManagedSpaceID"] as! Int
                let isFullScreen = s["TileLayoutManager"] as? [String: Any] != nil
                let spaceByDesktopID: String
                if !isFullScreen {
                    lastSpaceByDesktopNumber += 1
                    spaceByDesktopID = String(lastSpaceByDesktopNumber)
                } else {
                    lastFullScreenSpaceNumber += 1
                    spaceByDesktopID = "F\(lastFullScreenSpaceNumber)"
                }
                
                while spaceNumber >= spaceNameCache.cache.count {
                    // Make sure that the name cache is large enough
                    spaceNameCache.extend()
                }
                let spaceName = spaceNameCache.cache[spaceNumber]
                var space = Space(displayID: displayID,
                                  spaceID: managedSpaceID,
                                  spaceName: spaceName,
                                  spaceNumber: spaceNumber,
                                  spaceByDesktopID: spaceByDesktopID,
                                  isCurrentSpace: isCurrentSpace,
                                  isFullScreen: isFullScreen)
                
                if let data = defaults.value(forKey:"spaceNames") as? Data,
                   let dict = try? PropertyListDecoder().decode(Dictionary<String, SpaceNameInfo>.self, from: data),
                   let saved = dict[managedSpaceID]
                {
                    space.spaceName = saved.spaceName
                } else if isFullScreen {
                    if let pid = s["pid"] as? pid_t,
                       let app = NSRunningApplication(processIdentifier: pid),
                       let name = app.localizedName
                    {
                        space.spaceName = name.prefix(4).uppercased()
                    } else {
                        space.spaceName = "FULL"
                    }
                }
                spaceNameCache.cache[spaceNumber] = space.spaceName
                
                let nameInfo = SpaceNameInfo(spaceNum: spaceNumber, spaceName: space.spaceName, spaceByDesktopID: spaceByDesktopID)
                updatedDict[managedSpaceID] = nameInfo
                allSpaces.append(space)
            }
        }
        
        defaults.set(try? PropertyListEncoder().encode(updatedDict), forKey: "spaceNames")
        delegate?.didUpdateSpaces(spaces: allSpaces)
    }
}

protocol SpaceObserverDelegate: AnyObject {
    func didUpdateSpaces(spaces: [Space])
}
