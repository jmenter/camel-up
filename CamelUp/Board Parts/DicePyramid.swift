
import Foundation

class DicePyramid {
    
    var dice = CamelColor.allColors.map({ Die(color: $0) })
    var rolledDice = [Die]()
    
    init() {
        reset()
    }
    
    func reset() {
        dice = CamelColor.allColors.map({ Die(color: $0) })
        rolledDice = [Die]()
    }
    
    func roll() -> Die? {
        guard dice.count > 0 else { return nil }
        
        let index = Int(arc4random_uniform(UInt32(dice.count)))
        let die = dice[index]
        die.roll()
        rolledDice.append(die)
        dice.remove(at: index)
        return die
    }
    
    func contains(color: CamelColor) -> Bool {
        return dice.filter({$0.color == color }).count != 0
    }
    
    func stringValueFor(color: CamelColor) -> String {
        return "\(rolledDice.filter({$0.color == color}).first?.value.description ?? "🎲")"
    }
    
    func toggleDie(color: CamelColor?) {
        if let die = dice.filter({$0.color == color}).first,
            let index = dice.index(of: die) {
            dice.remove(at: index)
        } else {
            if let color = color {
                dice.append(Die(color: color))
            }
        }
    }
    
    func copy() -> DicePyramid {
        let newCopy = DicePyramid()
        newCopy.dice = dice.map({ $0.copy() })
        newCopy.rolledDice = rolledDice.map({ $0.copy() })
        return newCopy
    }
    
}
