import Foundation

class MainScene : CCNode {
    var _base : CCSprite!
    var _character : CCSprite!
    var _restartButton : CCButton!
    var _scoreLabel : CCLabelTTF!
    var _timerBar : CCSprite!
    var _view : CCGLView!
    
    // initial state variables
    var _isBranchLeft : Bool = false
    var _isCharacterLeft : Bool = true
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
    
    func didLoadFromCCB () {
        _base.position = CGPoint(x : widthMidpoint, y : 0.0)
        prepareNewGame()
    }
    
    // set starting conditions
    func prepareNewGame () {
        
        // clean old tree
        _base.removeAllChildren()
        
        // set initial values
        _isBranchLeft = false
        _isCharacterLeft = true
        _character.position.x = 0.0
        _character.flipX = false
        _restartButton.visible = true
        _score = scoreStart
        _scoreLabel.position.x = widthMidpoint
        _timer = timerStart
        _timerBar.position.x = widthMidpoint
        _timerBar.scaleX = timerStart / timerMax
        self.userInteractionEnabled = true
        
        // build new tree
        buildTree(_base.contentSize.height)
    }
    
    func buildTree (var elevation : CGFloat, var _ isBranchAllowed : Bool = false, _ count : Int = 1) {
        
        // build tree recursively
        if elevation < screenDimensions.size.height {
            var branchFileName : String = ""
            var randInt : Int = Int(arc4random_uniform(100))
            
//            branchFileName = selectTreePieceToAdd(isBranchAllowed, randInt : Int(arc4random_uniform(100)))
//            isBranchAllowed = selectTreePieceToAdd(isBranchAllowed, branchFileName: branchFileName, randInt : Int(arc4random_uniform(100)))
            
            // prepare branch to add to tree piece
            if isBranchAllowed && randInt < 90 {
                isBranchAllowed = false
                
                // left branch selected
                if randInt < 45 {
                    branchFileName = "LeftBranch"
                }
                    
                // right branch selected
                else {
                    branchFileName = "RightBranch"
                }
            }
                
            // no branch to add to tree piece
            else {
                isBranchAllowed = true
                branchFileName = "NoBranch"
            }
            
            elevation += addTreePieceAndIncreaseElevation(branchFileName, elevation)
            
            // call for recursion
            buildTree(elevation, isBranchAllowed, count + 1)
        }
    }
    
    func selectTreePieceToAdd(isBranchAllowed : Bool, var branchFileName : String, randInt i : Int) -> Bool {
        // prepare branch to add to tree piece
        if isBranchAllowed && i < 90 {
//            isBranchAllowed = false
            
            // left branch selected
            if i < 45 {
                branchFileName = "LeftBranch"
            }
                
                // right branch selected
            else {
                branchFileName = "RightBranch"
            }
            return false
        }
            
            // no branch to add to tree piece
        else {
//            isBranchAllowed = true
            branchFileName = "NoBranch"
            return true
        }
    }
    
    func addTreePieceAndIncreaseElevation(s : String, _ elevation : CGFloat) -> CGFloat {
        let tree = CCBReader.load(s)
        tree.position = CGPoint(x: _base.contentSize.width / 2.0, y: elevation)
        _base.addChild(tree)
        return tree.contentSize.height
    }
    
    // automatic
    override func update (delta: CCTime) {
        
        // the game has started
        if _score > 0 {
            _timer -= Float(delta)
            
            // time has run out
            if _timer <= 0.0 {
                endGame()
            }
        }
        
        // synchronize visual components with stats
        _timerBar.scaleX = Float(_timer / timerMax)
        _scoreLabel.string = String(_score)
    }
    
    // process user input
    override func touchBegan (touch : CCTouch!, withEvent event : CCTouchEvent!) {
        
        // each tap moves the player
        updatePlayer(touch)
        
        // check for body shot (switch into death)
        checkLoseConditions()
        
        //only occurs if the player avoided a body shot
        updateStats()
        updateTree()
        println("----")
        // check for head shot (head on death or switch into head on death)
        checkLoseConditions()
    }
    
    // move character and flip image
    func updatePlayer (touch : CCTouch!) {
        let tapPoint : CGFloat = touch.locationInView(self._view).x / screenWidth
        
        // left tap
        if tapPoint < widthMidpoint {
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
    
    // increase score and timer
    func updateStats () {
        _score++
        _timer = _timer + timerBonus > timerMax ? timerMax : _timer + timerBonus
    }
    
    // move branches down
    func updateTree () {
        var count : Int = 0
        for child in _base.children {
            if count == 0 {
                _base.removeChild(child as! CCNode)
            }
            else {
                var treePiece : CCNode = child as! CCNode
                treePiece.position.y -= treePiece.contentSize.height
            }
            count++
        }
//        addTreePieceAndIncreaseElevation(s: String, <#elevation: CGFloat#>)
        println(count)
    }
    
    // verify if the character and a branch has collided
    func checkLoseConditions () {
        if _isCharacterLeft && _isBranchLeft {
            endGame()
        }
    }
    
    // freeze environment
    func endGame () {
        _timer = 0.0
        self.userInteractionEnabled = false
        _restartButton.visible = true
    }
}
