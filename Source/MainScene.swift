import Foundation

class MainScene : CCNode {
    var _base : CCSprite!
    var _character : CCSprite!
    var _restartButton : CCButton!
    var _scoreLabel : CCLabelTTF!
    var _timerBar : CCSprite!
    var _view : CCGLView!
    
    // initial states
    var _isBranchAllowed : Bool = false
    var _isBranchLeft : Bool = false
    var _isCharacterLeft : Bool = true
    var _score : NSInteger = 0
    var _timer : Float = 5.0
    
    // magic numbers
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
        _isBranchAllowed = false
        _isBranchLeft = false
        _isCharacterLeft = true
        _character.position.x = 0.0
        _character.flipX = false
        _restartButton.visible = false
        _score = 0
        _scoreLabel.position.x = widthMidpoint
        _timer = timerStart
        _timerBar.position.x = widthMidpoint
        _timerBar.scaleX = timerStart / timerMax
        self.userInteractionEnabled = true
        buildTree(_base.contentSize.height)
        println("----")
    }
    
    func buildTree (elevation : CGFloat, _ count : Int = 1) {
        
        // build tree recursively
        if elevation < screenDimensions.size.height {
            let tree = CCBReader.load("TreePiece")
            _base.addChild(tree)
            tree.position = CGPoint(x: _base.contentSize.width / 2.0, y: elevation)
            
            // possibly add a branch to the tree
            if _isBranchAllowed {
                let randInt : Int = Int(arc4random_uniform(100))
                
                // left branch
                if randInt < 45 {
                    println(String(count) + ": BBB")
                    _isBranchAllowed = false
                }
                    
                // right branch
                else if randInt < 90 {
                    println(String(count) + ":     BBB")
                    _isBranchAllowed = false
                }
                    
                // no branch
                else {
                    println(String(count))
                    _isBranchAllowed = true
                }
            }
                
            // allow the next tree piece to possibly add a branch
            else {
                println(String(count))
                _isBranchAllowed = true
            }
            buildTree(elevation + tree.contentSize.height, count + 1)
        }
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
