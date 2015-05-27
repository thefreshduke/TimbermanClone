//
//  TreePiece.swift
//  TimberClone
//
//  Created by Scotty Shaw on 5/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class LeftBranch : CCNode
{
    var _branch : CCNode!
    var _name : String = "left"
    
    func didLoadFromCCB() {
        _branch.physicsBody.sensor = true
    }
}