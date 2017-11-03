
import Foundation

enum Color : String {
    case blue = "blue"
    case green = "green"
    case red = "red"
    case yellow = "yellow"
    case white = "white"
}

class Camel {
    
    let color: Color
    var camelUp: Camel?
    var location: Int = 0
    
    init(color: Color) {
        self.color = color
    }
    
}

enum DesertTile {
    case plus
    case minus
}

class Die {
    
    let color: Color
    var value:Int = 1
    
    init(color: Color) {
        self.color = color
        roll()
    }
    
    func roll() {
        value = Int(arc4random_uniform(3)) + 1
    }
    
}

class DicePyramid {
    
    var dice = [Die]()
    
    init() {
        resetDice()
    }
    
    func roll() -> Die? {
        guard dice.count > 0 else { return nil }
        
        let index = Int(arc4random_uniform(UInt32(dice.count)))
        let die = dice[index]
        dice.remove(at: index)
        return die
    }
    
    func resetDice() {
        dice = [Die(color:.blue),
                Die(color:.green),
                Die(color:.red),
                Die(color:.yellow),
                Die(color:.white)]
    }

}

class Cell {
    
    var desertTile:DesertTile?
    var camels = [Camel]()

    func description() -> String {
        return ""
    }
    
    
}

class Board {

//    let cells = (0..<16).map { _ in Cell() }
    let dicePyramid = DicePyramid()
    let camels = [Camel(color: .blue), Camel(color: .green), Camel(color: .red), Camel(color: .yellow), Camel(color: .white)]
    var gameIsOver = false
    var legCount = 0
    
    init() {
        dicePyramid.resetDice()
        while dicePyramid.dice.count > 0 {
            guard let die = dicePyramid.roll(), let camel = camels.filter({ $0.color == die.color }).first else { break }

            camel.location = camel.location + die.value
        }
        dicePyramid.resetDice()
    }
    
    func doLeg() {
        legCount += 1
        while dicePyramid.dice.count > 0 {
            guard let die = dicePyramid.roll(), let camel = camels.filter({ $0.color == die.color }).first else { break }
            camel.location = camel.location + die.value
            if camel.location > 15 {
                gameIsOver = true
                break
            }
        }
        print("leg over, \( camels.sorted(by: { $0.location > $1.location }).first?.color.rawValue ?? "don't know" ) wins leg")
        if gameIsOver {
            print("game over, leg count: \(legCount)")
        }
        dicePyramid.resetDice()
    }
    
    func camelConfiguration() -> String {
        var base = ""
        camels.forEach { camel in
            base = base + "\n camel: \(camel.color.rawValue), location: \(camel.location)"
        }
        return base
    }
}
