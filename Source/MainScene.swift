import Foundation

class MainScene : CCNode, CCPhysicsCollisionDelegate {
    
    // game agents
    var _base : CCSprite!
    var _character : CCSprite!
    var _physicsNode : CCPhysicsNode!
    
    // UI/UX
    var _restartButton : CCButton!
    var _scoreLabel : CCLabelTTF!
    var _timerBar : CCSprite!
    var _view : CCGLView!
    
    // initial state variables
    var _isBranchAllowed : Bool = false
    var _isCharacterLeft : Bool = true
    var isGameOver : Bool = false
    var _score : NSInteger = 0
    var _timer : Float = 5.0
    
    // magic numbers
    var scoreStart : Int = 0
    var timerBonus : Float = 0.25
    var timerStart : Float = 5.0
    var timerMax : Float = 10.0
    
    // measurements
    var screenDimensions : CGRect = UIScreen.mainScreen().bounds
    var screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    var screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    var widthMidpoint : CGFloat = 0.5
    
    // storage variables
    var branchesLocationArray = [Character]()
    
    func didLoadFromCCB () {
        _physicsNode.collisionDelegate = self
        prepareNewGame()
    }
    
    // set starting conditions
    func prepareNewGame () {
        
        // clean old tree
        branchesLocationArray = []
        _physicsNode.removeAllChildren()
        
        // set initial values
        _isBranchAllowed = false
        _isCharacterLeft = true
        isGameOver = false
        _character.position.x = 0.0
        _character.flipX = false
        _restartButton.visible = false
        _score = scoreStart
        _scoreLabel.position.x = widthMidpoint
        _timer = timerStart
        _timerBar.position.x = widthMidpoint
        _timerBar.scaleX = timerStart / timerMax
        self.userInteractionEnabled = true
        
        // add new character first
        _physicsNode.addChild(_character)
        
        // build new tree
        buildTree(_base.contentSize.height)
    }
    
    func buildTree (var elevation : CGFloat, _ count : Int = 1) {
        
        // build tree recursively
        if (elevation < screenDimensions.size.height) {
            
            // add tree piece
            var branchFileName : String = selectTreePieceToAdd(randInt : Int(arc4random_uniform(100)))
            elevation += addTreePieceAndIncreaseElevation(branchFileName, elevation)
            
            // call for recursion
            buildTree(elevation, count + 1)
        }
    }
    
    // prepare tree piece
    func selectTreePieceToAdd(randInt i : Int) -> String {
        
        // select branch to add to tree piece
        if ((_isBranchAllowed) && (i < 90)) {
            _isBranchAllowed = false
            
            // left branch selected
            if (i < 45) {
                return "LeftBranch"
            }
                
            // right branch selected
            else {
                return "RightBranch"
            }
        }
            
        // no branch to add to tree piece
        else {
            _isBranchAllowed = true
            return "TreePiece"
        }
    }
    
    // create tree piece
    func addTreePieceAndIncreaseElevation(s : String, _ elevation : CGFloat) -> CGFloat {
        let treePiece = CCBReader.load(s)
        branchesLocationArray.append(Array(s)[0])
        treePiece.position = CGPoint(x: screenWidth / 2.0, y: elevation)
        _physicsNode.addChild(treePiece)
        return treePiece.contentSize.height
    }
    
    // automatic
    override func update (delta: CCTime) {
        
        // the game has started
        if (_score > 0) {
            _timer -= Float(delta)
            
            // time has run out
            if (_timer <= 0.0) {
                endGame()
            }
        }
        
        // synchronize display with environment
        _timerBar.scaleX = Float(_timer / timerMax)
        _scoreLabel.string = String(_score)
    }
    
    // process user input
    override func touchBegan (touch : CCTouch!, withEvent event : CCTouchEvent!) {
        let tapX : CGFloat = touch.locationInView(self._view).x / screenWidth
        updatePlayer(tapX)
        
        // only occurs if the move was successful
        if (!isGameOver) {
            updateTree()
            updateStats()
        }
    }
    
    // move character and flip image
    func updatePlayer (tapX : CGFloat) {
        
        // left tap
        if (tapX < widthMidpoint) {
            _character.position.x = 0.0
            _character.flipX = false
            _isCharacterLeft = true
        }
            
            // right tap
        else {
            _character.position.x = (screenWidth - _character.contentSize.width) / screenWidth
            _character.flipX = true
            _isCharacterLeft = false
        }
    }
    
    // check for an unsuccessful move
    func checkSwitchIntoDeath () -> Bool {
        if ((_isCharacterLeft && branchesLocationArray[0] == "L") || (!_isCharacterLeft && branchesLocationArray[0] == "R")) {
            endGame()
            return false
        }
        return true
    }
    
    // move agents
    func updateTree () {
        var count : Int = -1
        var treeHeight : CGFloat = 0
        
        let continueGame : Bool = checkSwitchIntoDeath()
        
        // occurs only if character did not die from switching into a branch
        if (continueGame) {
            
            // move branches down
            for child in _physicsNode.children {
                
                // ignore character
                if (count >= 0) {
                    var treePiece : CCNode = child as! CCNode
                    
                    treeHeight = treePiece.position.y
                    treePiece.position.y -= treePiece.contentSize.height
                    
                    // remove bottom tree piece
                    if (treePiece.position.y <= 0.0) {
                        _physicsNode.removeChild(treePiece)
                    }
                }
                count++
            }
            
            updateBranchesLocationArray()
            
            // add new tree piece at the top
            var branchFileName : String = selectTreePieceToAdd(randInt : Int(arc4random_uniform(100)))
            addTreePieceAndIncreaseElevation(branchFileName, treeHeight)
        }
    }
    
    // update information on branch locations
    func updateBranchesLocationArray () {
        for index in 0...(branchesLocationArray.count) {
            if ((index + 1) < branchesLocationArray.count) {
                branchesLocationArray[index] = branchesLocationArray[index + 1]
            }
        }
        branchesLocationArray.removeAtIndex(branchesLocationArray.count - 1)
    }
    
    // increase score and timer
    func updateStats () {
        _score++
        _timer = _timer + timerBonus > timerMax ? timerMax : _timer + timerBonus
    }
    
    // detect collisions between the character and a branch
    func ccPhysicsCollisionBegin (pair: CCPhysicsCollisionPair!, character: CCNode!, branch: CCNode!) -> ObjCBool {
        _score--
        endGame()
        return true
    }
    
    // freeze environment
    func endGame () {
        isGameOver = true
        _timer = 0.0
        self.userInteractionEnabled = false
        _restartButton.visible = true
    }
}