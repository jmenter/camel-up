
import Foundation

class Board: NSCopying {

    var boardCells:[BoardCell] = (0..<16).map { _ in BoardCell() }
    var dicePyramid = DicePyramid()
    var camels = [Camel(color: .blue), Camel(color: .green), Camel(color: .orange), Camel(color: .yellow), Camel(color: .white)]
    
    var gameIsOver = false
    var legCount = 0
    
    func copy(with zone: NSZone? = nil) -> Any {
        let newCopy = Board()
        
        newCopy.boardCells = boardCells.map({ $0.copy() as! BoardCell })
        newCopy.camels = camels.map({ $0.copy() as! Camel })
        newCopy.dicePyramid = dicePyramid.copy() as! DicePyramid
        newCopy.legCount = legCount
        newCopy.gameIsOver = gameIsOver
        
        return newCopy
    }
    
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
        guard fromLocation != toLocation else {
//            print("from and to are same, exiting")
            return
        }
        
//        print("\nmoving camel \(camel.color) from: \(fromLocation) to: \(toLocation)")
        // if camel below from, disattach
        camels.filter({ $0.camelUpColor == camel.color }).forEach({
            $0.camelUpColor = nil
//            print("disattaching from \($0.color) at \($0.location)")
        })
        
        // create stack of camels to move
        var camelStack = [camel]
        
        var currentCamel:Camel? = camel

        while currentCamel?.camelUpColor != nil {
            currentCamel = camels.filter({ $0.color == currentCamel?.camelUpColor}).first
            camelStack.append(currentCamel!)
        }
//        print("camelStack pre move: \(camelStack.debugDescription)")
        // if camel below at destination, attach
        if let preexistingCamel = camels.filter({$0.location == toLocation && $0.camelUpColor == nil}).first {
//            print("adding to top of \(preexistingCamel.color) at location: \(preexistingCamel.location)")
            preexistingCamel.camelUpColor = camel.color
        }

        // change location of all camels in the stack
        camelStack.forEach({$0.location = toLocation})
//        print("camelStack post move: \(camelStack.debugDescription)")
    }
    
    func modifierAt(location: Int) -> Int {
        guard location < boardCells.count else { return 0 }
        return boardCells[location].desertTile?.rawValue ?? 0
    }
    
    func doCamel() {
        if dicePyramid.dice.count == 0 { dicePyramid.reset() }
        
        guard let die = dicePyramid.roll(), let camel = camels.filter({ $0.color == die.color }).first else { return }
        
        let newLocation = camel.location + die.value + modifierAt(location: camel.location + die.value)
        
        move(camel: camel, fromLocation: camel.location, toLocation: newLocation)
        
        if camel.location > 15 {
            gameIsOver = true
        }
    }
    
    func doLeg() {
        legCount += 1
        while dicePyramid.dice.count > 0 {
            guard let die = dicePyramid.roll(), let camel = camels.filter({ $0.color == die.color }).first else { break }
            
            let newLocation = camel.location + die.value + modifierAt(location: camel.location + die.value)

            move(camel: camel, fromLocation: camel.location, toLocation: newLocation)

            if camel.location > 15 {
                gameIsOver = true
                break
            }
        }
        
        if gameIsOver {
//            print("game over, \(currentWinner().color.rawValue) wins, leg count: \(legCount)\n")
        } else {
//            print("leg over, \(currentWinner().color.rawValue) wins leg\n")
        }
        dicePyramid.reset()
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
    
    func camelConfiguration() -> String {
        var base = ""
        camels.forEach { camel in
            base = base + camel.debugDescription + "\n"
        }
        return base
    }
}
