//
//  Spaceman-Bridging-Header.h
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

#ifndef Spaceman_Bridging_Header_h
#define Spaceman_Bridging_Header_h

#import <Foundation/Foundation.h>

int _CGSDefaultConnection();
CFArrayRef CGSCopyManagedDisplaySpaces(int conn);
id CGSCopyActiveMenuBarDisplayIdentifier(int conn);

#endif /* Spaceman_Bridging_Header_h */
