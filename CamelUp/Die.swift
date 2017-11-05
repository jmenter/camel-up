
import Foundation

class Die: NSCopying {
    
    let color: Color
    var value:Int = 1
    
    init(color: Color) {
        self.color = color
        roll()
    }
    
    func roll() {
        value = Int(arc4random_uniform(3)) + 1
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let newCopy = Die(color: color)
        newCopy.value = value
        return newCopy
    }
    
}
