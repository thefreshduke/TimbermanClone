import Foundation

class MainScene : CCNode {
    var _character : CCSprite!
    var _restartButton : CCButton!
    var _scoreLabel : CCLabelTTF!
    var _timerBar : CCSprite!
    var _view : CCGLView!
    
    var _score : NSInteger = 0
    var _timer : Double = 5.0
    
    func didLoadFromCCB() {
        prepareNewGame()
    }
    
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
    
    override func touchBegan (touch : CCTouch!, withEvent event : CCTouchEvent!) {
        updatePlayer(touch)
        // body shot end game check
        updateStats()
//        updateTree () {
            // move branches down
//        }
        // head shot end game check
    }
    
    func updatePlayer (touch : CCTouch!) {
        let tapPoint = touch.locationInView(self._view)
        var screenDimensions : CGRect = UIScreen.mainScreen().bounds
        var screenWidth : CGFloat = screenDimensions.size.width
        
        if (tapPoint.x < screenWidth / 2.0) {
            _character.position.x = 0.0
            _character.flipX = false
        }
        else {
            _character.position.x = (screenWidth - _character.contentSize.width) / screenWidth
            _character.flipX = true
        }
    }
    
    func updateStats () {
        _score += 1
        _timer = _timer + 0.25 > 10.0 ? 10.0 : _timer + 0.25
    }
    
    func endGame () {
        _timer = 0.0
        self.userInteractionEnabled = false
        _restartButton.visible = true
    }
    
    func prepareNewGame () {
        _character.position.x = 0.0
        _character.flipX = false
        _restartButton.visible = false
        _score = 0
        _scoreLabel.position.x = 0.5
        _timer = 5.0
        _timerBar.position.x = 0.5
        _timerBar.scaleX = 0.5
        self.userInteractionEnabled = true
        // new tree and branches
    }
}
