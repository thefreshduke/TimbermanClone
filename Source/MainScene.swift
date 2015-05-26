import Foundation

class MainScene : CCNode {
    var _base : CCSprite!
    var _character : CCSprite!
    var _restartButton : CCButton!
    var _scoreLabel : CCLabelTTF!
    var _timerBar : CCSprite!
    var _view : CCGLView!
    
    var _doesBranchExist : Bool = false
    var _isBranchLeft : Bool = false
    var _isCharacterLeft : Bool = true
    var _score : NSInteger = 0
    var _timer : Float = 5.0
    var screenDimensions : CGRect = UIScreen.mainScreen().bounds
    var screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    var screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    
    var widthMidpoint : CGFloat = 0.5
    var timerBonus : Float = 0.25
    var timerStart : Float = 5.0
    var timerMax : Float = 10.0
    
    func didLoadFromCCB () {
        _base.position = CGPoint(x : widthMidpoint, y : 0.0)
        buildTree(_base.contentSize.height)
        resetEnvironment()
    }
    
    func buildTree (elevation : CGFloat) {
        if elevation < screenDimensions.size.height {
            let tree = CCBReader.load("TreePiece")
            _base.addChild(tree)
            tree.position = CGPoint(x: _base.contentSize.width / 2.0, y: elevation)
            buildTree(elevation + tree.contentSize.height)
        }
    }
    
    // prepare new game
    func resetEnvironment () {
        _character.position.x = 0.0
        _character.flipX = false
        _isCharacterLeft = true
        _restartButton.visible = false
        _score = 0
        _scoreLabel.position.x = widthMidpoint
        _timer = timerStart
        _timerBar.position.x = widthMidpoint
        _timerBar.scaleX = timerStart / timerMax
        self.userInteractionEnabled = true
        // add branches to the tree; no branch at lowest tree piece ???
    }
    
    // automatic
    override func update (delta: CCTime) {
        
        // the game has started
        if _score > 0 {
            _timer -= Float(delta)
            
            // time ran out
            if _timer <= 0.0 {
                endGame()
            }
        }
        
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
        updateTree ()
        
        // check for head shot (head on death or switch into head on death)
        checkLoseConditions()
    }
    
    // move and flip character
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
        _score += 1
        _timer = _timer + timerBonus > timerMax ? timerMax : _timer + timerBonus
    }
    
    // move branches down
    func updateTree () {
        // move branches down
    }
    
    // verify if the character and a branch collided
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
