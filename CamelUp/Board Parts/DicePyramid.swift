
import Foundation

class DicePyramid {
    
    var dice = Color.allColors.map({ Die(color: $0) })
    
    init() {
        reset()
    }
    
    func reset() {
        dice = Color.allColors.map({ Die(color: $0) })
    }
    
    func roll() -> Die? {
        guard dice.count > 0 else { return nil }
        
        let index = Int(arc4random_uniform(UInt32(dice.count)))
        let die = dice[index]
        die.roll()
        dice.remove(at: index)
        return die
    }
    
    func copy() -> DicePyramid {
        let newCopy = DicePyramid()
        newCopy.dice = dice.map({ $0.copy() })
        return newCopy
    }
    
}
