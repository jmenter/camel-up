
import Foundation

class Board: NSCopying {

    static let numberOfCells = 16
    var boardCells:[BoardCell] = (0..<Board.numberOfCells).map { _ in BoardCell() }
    var dicePyramid = DicePyramid()
    var camels = [Camel(color: .blue), Camel(color: .green), Camel(color: .orange), Camel(color: .yellow), Camel(color: .white)]
    
    var gameIsOver = false
    var legCount = 0
    
    init() {
        reset()
    }
    
    func reset() {
        gameIsOver = false
        boardCells.forEach({$0.desertTile = nil})
        camels.forEach({$0.location = -1; $0.camelUpColor = nil})
        dicePyramid.reset()
        while dicePyramid.dice.count > 0 {
            guard let die = dicePyramid.roll(), let camel = camels.filter({ $0.color == die.color }).first else { break }
            
            move(camel: camel, fromLocation: camel.location, toLocation: die.value - 1)
        }
        dicePyramid.reset()
    }
    
    func doCamel() -> String {
        if dicePyramid.dice.count == 0 {
            legCount += 1
            dicePyramid.reset()
        }
        guard let die = dicePyramid.roll(), let camel = camels.filter({ $0.color == die.color }).first else { return "" }
        
        let modifier = modifierAt(location: camel.location + die.value) == -1 ? "-1" :
                       modifierAt(location: camel.location + die.value) == 1 ? "+1" : ""
        let postfix = modifierAt(location: camel.location + die.value) == 0 ? ". " : " and hit " + modifier + " desert tile at \(camel.location + die.value + 1). "
        var newLocation = camel.location + die.value + modifierAt(location: camel.location + die.value)
        newLocation = newLocation > Board.numberOfCells ? Board.numberOfCells : newLocation
        move(camel: camel, fromLocation: camel.location, toLocation: newLocation)
        if camel.location >= Board.numberOfCells { gameIsOver = true }
        var winner = ""
        if dicePyramid.dice.count == 0 || gameIsOver {
            legCount += 1
            dicePyramid.reset()
            winner = "\n\(currentWinner().color.rawValue) wins leg\n\n"
        }
        return "\(camel.color.rawValue) moved \(die.value) space" + (die.value == 1 ? "" : "s") + postfix + winner + (gameIsOver ? "\(currentWinner().color.rawValue) wins race" : "")
    }
    
    func doLeg() -> String {
        var results = ""
        while dicePyramid.dice.count > 0 {
            guard let die = dicePyramid.roll(), let camel = camels.filter({ $0.color == die.color }).first else { break }
            
            let modifier = modifierAt(location: camel.location + die.value) == -1 ? "-1" :
                modifierAt(location: camel.location + die.value) == 1 ? "+1" : ""
            let postfix = modifierAt(location: camel.location + die.value) == 0 ? ". " : " and hit " + modifier + " desert tile at \(camel.location + die.value + 1). "
            var newLocation = camel.location + die.value + modifierAt(location: camel.location + die.value)
            newLocation = newLocation > Board.numberOfCells ? Board.numberOfCells : newLocation
            move(camel: camel, fromLocation: camel.location, toLocation: newLocation)
            results +=  "\(camel.color.rawValue) moved \(die.value) space" + (die.value == 1 ? "" : "s") + postfix
            if camel.location >= Board.numberOfCells { gameIsOver = true; break }
        }
        results += "\n\(currentWinner().color.rawValue) wins leg\n\n"

        legCount += 1
        dicePyramid.reset()
        return results + (gameIsOver ? "\(currentWinner().color.rawValue) wins race" : "")
    }
    
    func doRace() -> String {
        var results = ""
        while !gameIsOver {
            results = results + doLeg()
        }
        return results
    }

    func move(camel: Camel, fromLocation: Int, toLocation: Int) {
        guard fromLocation != toLocation else { return }
        
        camels.filter({ $0.camelUpColor == camel.color }).forEach({ $0.camelUpColor = nil })
        
        var camelStack = [camel]
        var testCamel:Camel? = camel
        
        while testCamel?.camelUpColor != nil {
            testCamel = camels.filter({ $0.color == testCamel?.camelUpColor }).first
            camelStack.append(testCamel!)
        }
        
        if let topDestinationCamel = camels.filter({$0.location == toLocation && $0.camelUpColor == nil}).first {
            topDestinationCamel.camelUpColor = camel.color
        }
        
        camelStack.forEach({$0.location = toLocation})
    }
    

    func modifierAt(location: Int) -> Int {
        return location >= boardCells.count ? 0 : boardCells[location].desertTile?.rawValue ?? 0
    }
    
    func camelsBelow(camel: Camel) -> Int {
        var count = 0
        var testCamel: Camel? = camel
        
        while camels.filter({$0.camelUpColor == testCamel?.color}).count > 0 {
            count += 1
            testCamel = self.camels.filter({$0.camelUpColor == testCamel?.color}).first
        }
        return count
    }

    func currentWinner() -> Camel {
        let furthestCamelLocation = camels.sorted(by: { $0.location > $1.location }).first?.location
        let furthestCamels = camels.filter({$0.location == furthestCamelLocation})
        return furthestCamels.filter({$0.camelUpColor == nil}).first!
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let newCopy = Board()
        
        newCopy.boardCells = boardCells.map({ $0.copy() as! BoardCell })
        newCopy.camels = camels.map({ $0.copy() as! Camel })
        newCopy.dicePyramid = dicePyramid.copy() as! DicePyramid
        newCopy.legCount = legCount
        newCopy.gameIsOver = gameIsOver
        
        return newCopy
    }
    

}
