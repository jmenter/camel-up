
import Foundation

class DicePyramid: NSCopying {
    
    var dice = [Die]()
    
    init() {
        reset()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let newCopy = DicePyramid()
        newCopy.dice = dice.map({ $0.copy() as! Die })
        return newCopy
    }
    
    func roll() -> Die? {
        guard dice.count > 0 else { return nil }
        
        let index = Int(arc4random_uniform(UInt32(dice.count)))
        let die = dice[index]
        die.roll()
        dice.remove(at: index)
        return die
    }
    
    func reset() {
        dice = [Die(color:.blue),
                Die(color:.green),
                Die(color:.orange),
                Die(color:.yellow),
                Die(color:.white)]
    }
    
}
