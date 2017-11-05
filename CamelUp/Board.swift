
import Foundation

class Board: NSCopying {

    var boardCells:[BoardCell] = (0..<16).map { _ in BoardCell() }
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
    
    func doCamel() {
        if dicePyramid.dice.count == 0 {
            legCount += 1
            dicePyramid.reset()
        }
        guard let die = dicePyramid.roll(), let camel = camels.filter({ $0.color == die.color }).first else { return }
        
        var newLocation = camel.location + die.value + modifierAt(location: camel.location + die.value)
        newLocation = newLocation > 16 ? 16 : newLocation
        move(camel: camel, fromLocation: camel.location, toLocation: newLocation)
        if camel.location > 15 { gameIsOver = true }
    }
    
    func doLeg() {
        while dicePyramid.dice.count > 0 {
            guard let die = dicePyramid.roll(), let camel = camels.filter({ $0.color == die.color }).first else { break }
            
            var newLocation = camel.location + die.value + modifierAt(location: camel.location + die.value)
            newLocation = newLocation > 16 ? 16 : newLocation
            move(camel: camel, fromLocation: camel.location, toLocation: newLocation)
            if camel.location > 15 { gameIsOver = true; break }
        }
        
        legCount += 1
        dicePyramid.reset()
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
