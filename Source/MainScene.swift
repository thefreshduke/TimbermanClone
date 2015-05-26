import Foundation

class MainScene : CCNode {
    var _character : CCSprite!
    var _restartButton : CCButton!
    var _scoreLabel : CCLabelTTF!
    var _timerBar : CCSprite!
    var _view : CCGLView!
    
    var _isBranchLeft : Bool = false
    var _isCharacterLeft : Bool = true
    var _score : NSInteger = 0
    var _timer : Double = 5.0
    
    func didLoadFromCCB() {
        prepareNewGame()
    }
    
    // automatic
    override func update (delta: CCTime) {
        if (_score > 0) {
            _timer -= delta
            if (_timer <= 0.0) {
                endGame()
            }
        }
        
        _timerBar.scaleX = Float(_timer / 10.0)
        _scoreLabel.string = String(_score)
    }
    
    // process user input
    override func touchBegan (touch : CCTouch!, withEvent event : CCTouchEvent!) {
        // each tap moves the player
        updatePlayer(touch)
        
        // check for body shot (switch into death)
        checkLoseConditions()
        
        //only occurs if the player avoided the switch into death
        updateStats()
        updateTree ()
        
        // check for head shot (head on death or switch into head on death)
        checkLoseConditions()
    }
    
    // move and flip character
    func updatePlayer (touch : CCTouch!) {
        let tapPoint = touch.locationInView(self._view)
        var screenDimensions : CGRect = UIScreen.mainScreen().bounds
        var screenWidth : CGFloat = screenDimensions.size.width
        
        // left tap
        if (tapPoint.x < screenWidth / 2.0) {
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
        _timer = _timer + 0.25 > 10.0 ? 10.0 : _timer + 0.25
    }
    
    // move branches down
    func updateTree () {
        // move branches down
    }
    
    func checkLoseConditions () {
        if (_isCharacterLeft && _isBranchLeft) {
            endGame()
        }
    }
    
    // freeze everything
    func endGame () {
        _timer = 0.0
        self.userInteractionEnabled = false
        _restartButton.visible = true
    }
    
    // reset everything
    func prepareNewGame () {
        _character.position.x = 0.0
        _character.flipX = false
        _isCharacterLeft = true
        _restartButton.visible = false
        _score = 0
        _scoreLabel.position.x = 0.5
        _timer = 5.0
        _timerBar.position.x = 0.5
        _timerBar.scaleX = 0.5
        self.userInteractionEnabled = true
        // new tree and branches
        // no branch at lowest tree piece
    }
}
