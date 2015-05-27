//
//  Branch.swift
//  TimberClone
//
//  Created by Scotty Shaw on 5/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class TreePiece : CCNode {
    var _branch : CCSprite!
    var _doesBranchExist : Bool = false
    var _isBranchLeft : Bool = false
    
    func didLoadFromCCB() {
        _branch.physicsBody.sensor = true
    }
}