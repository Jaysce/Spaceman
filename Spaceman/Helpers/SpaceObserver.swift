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
    private var prefs = Preferences.shared
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
        var updatedDict = [String: DictVal]()
        
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
                let dict = prefs.getDict()
                let spaceID = String(s["ManagedSpaceID"] as! Int)
                let spaceNumber: Int = spacesIndex + 1
                let isCurrentSpace = activeSpaceID == s["ManagedSpaceID"] as! Int
                let isFullScreen = s["TileLayoutManager"] as? [String: Any] != nil
                
                let space: Space
                
                // if key exists
                if dict[spaceID] != nil {
                    space = Space(displayID: displayID, spaceID: spaceID, spaceName: dict[spaceID]!.spaceName, spaceNumber: spaceNumber, isCurrentSpace: isCurrentSpace, isFullScreen: isFullScreen)
                }
                else {
                    space = Space(displayID: displayID, spaceID: spaceID, spaceNumber: spaceNumber, isCurrentSpace: isCurrentSpace, isFullScreen: isFullScreen)
                }
                
                let dv = DictVal(spaceNum: spaceNumber, spaceName: space.spaceName)
                updatedDict[spaceID] = dv
                allSpaces.append(space)
                spacesIndex += 1
            }
        }
        
        prefs.updateDictionary(with: updatedDict)
        delegate?.didUpdateSpaces(spaces: allSpaces)
    }
}

protocol SpaceObserverDelegate: class {
    func didUpdateSpaces(spaces: [Space])
}
