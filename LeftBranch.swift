//
//  LeftBranch.swift
//  TimberClone
//
//  Created by Scotty Shaw on 5/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class LeftBranch : TreePiece {
    
    override func didLoadFromCCB() {
        _doesBranchExist = true
        _isBranchLeft = true
    }
}