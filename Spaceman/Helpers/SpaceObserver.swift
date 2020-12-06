//
//  SpaceObserver.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Cocoa
import Foundation

class SpaceObserver {
    private var workspace = NSWorkspace.shared
    private let conn = _CGSDefaultConnection()
    private let defaults = UserDefaults.standard
    weak var delegate: SpaceObserverDelegate?
    
    init() {
        workspace.notificationCenter.addObserver(
            self,
            selector: #selector(updateSpaceInformation),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: workspace
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSpaceInformation),
            name: NSNotification.Name("ButtonPressed"),
            object: nil
        )
    }
    
    @objc public func updateSpaceInformation() {
        let displays = CGSCopyManagedDisplaySpaces(conn) as! [NSDictionary]
        var activeSpaceID = -1
        var spacesIndex = 0
        var allSpaces: [Space] = []
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
            
            for s in spaces {
                let spaceID = String(s["ManagedSpaceID"] as! Int)
                let spaceNumber: Int = spacesIndex + 1
                let isCurrentSpace = activeSpaceID == s["ManagedSpaceID"] as! Int
                let isFullScreen = s["TileLayoutManager"] as? [String: Any] != nil
                var space = Space(displayID: displayID,
                                  spaceID: spaceID,
                                  spaceName: "N/A",
                                  spaceNumber: spaceNumber,
                                  isCurrentSpace: isCurrentSpace,
                                  isFullScreen: isFullScreen)
                
                // Try to get data for spaceNames key
                if let data = defaults.value(forKey:"spaceNames") as? Data {
                    // Decode the data into dictionary (will not fail as data is not nil)
                    let dict = try! PropertyListDecoder().decode(Dictionary<String, SpaceNameInfo>.self, from: data)
                    space.spaceName = dict[spaceID] != nil ? dict[spaceID]!.spaceName : "N/A"
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

protocol SpaceObserverDelegate: class {
    func didUpdateSpaces(spaces: [Space])
}
