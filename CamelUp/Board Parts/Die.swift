
import Foundation

class Die: Equatable {
    
    let color: CamelColor
    var value:Int = 1
    
    init(color: CamelColor) {
        self.color = color
        roll()
    }
    
    func roll() {
        value = Int(arc4random_uniform(3)) + 1
    }
    
    static func ==(left: Die, right: Die) -> Bool {
        return left.color == right.color
    }
    
    func copy() -> Die {
        let newCopy = Die(color: color)
        newCopy.value = value
        return newCopy
    }
    
}
