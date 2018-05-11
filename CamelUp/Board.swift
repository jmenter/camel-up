
import Foundation

class Board {
    
    static let numberOfCells = 16
    var boardCells: [BoardCell] = (0..<Board.numberOfCells).map { _ in BoardCell() }
    var dicePyramid = DicePyramid()
    var camels = CamelColor.allColors.map({ Camel(camelColor: $0) })
    
    var gameIsOver = false
    
    init() {
        reset()
    }
    
    func reset() {
        gameIsOver = false
        boardCells.reset()
        camels.reset()
        dicePyramid.reset()
        initializeCamelLocations()
        dicePyramid.reset()
    }
    
    fileprivate func initializeCamelLocations() {
        while dicePyramid.dice.count > 0 {
            guard let die = dicePyramid.roll(), let camel = camels.camelOf(color: die.color) else { break }
            
            move(camel: camel, fromLocation: camel.location, toLocation: die.value - 1)
        }
    }
    
    func doCamel() -> String {
        if dicePyramid.dice.count == 0 { dicePyramid.reset() }
        
        guard let die = dicePyramid.roll(), let camel = camels.camelOf(color: die.color) else { return "" }
        
        let newLocation = camel.location + die.value
        let modifier = boardCells.desertTileModifierStringAt(location: newLocation)
        let postfix = boardCells.desertTileModifierAt(location: newLocation) == 0 ? ". " : " and hit " + modifier + " desert tile at \(camel.location + die.value + 1). "
        var modifiedNewLocation = newLocation + boardCells.desertTileModifierAt(location: newLocation)
        modifiedNewLocation = modifiedNewLocation > Board.numberOfCells ? Board.numberOfCells : modifiedNewLocation
        move(camel: camel, fromLocation: camel.location, toLocation: modifiedNewLocation)
        if camel.location >= Board.numberOfCells { gameIsOver = true }
        var legWinner = ""
        if dicePyramid.dice.count == 0 || gameIsOver {
            dicePyramid.reset()
            boardCells.reset()
            legWinner = "\n\(currentWinner().camelColor.rawValue) wins leg\n\(currentRunnerUp().camelColor.rawValue) gets 2nd in leg\n\n"
       }
        return "\(camel.camelColor.rawValue) moved \(die.value) space" + (die.value == 1 ? "" : "s") + postfix + legWinner + (gameIsOver ? "\(currentWinner().camelColor.rawValue) wins race\n\(currentLoser().camelColor.rawValue) loses race" : "")
    }
    
    func doLeg() -> String {
        var results = ""
        while dicePyramid.dice.count > 0 {
            guard let die = dicePyramid.roll(), let camel = camels.filter({ $0.camelColor == die.color }).first else { break }
            
            let newLocation = camel.location + die.value
            let modifier = boardCells.desertTileModifierAt(location: newLocation) == -1 ? "-1" :
                boardCells.desertTileModifierAt(location: newLocation) == 1 ? "+1" : ""
            let postfix = boardCells.desertTileModifierAt(location: newLocation) == 0 ? ". " : " and hit " + modifier + " desert tile at \(camel.location + die.value + 1). "
            var modifiedNewLocation = camel.location + die.value + boardCells.desertTileModifierAt(location: newLocation)
            modifiedNewLocation = modifiedNewLocation > Board.numberOfCells ? Board.numberOfCells : modifiedNewLocation
            move(camel: camel, fromLocation: camel.location, toLocation: modifiedNewLocation)
            results += "\(camel.camelColor.rawValue) moved \(die.value) space" + (die.value == 1 ? "" : "s") + postfix
            if camel.location >= Board.numberOfCells { gameIsOver = true; break }
        }
        dicePyramid.reset()
        boardCells.reset()
        results += "\n\(currentWinner().camelColor.rawValue) wins leg\n\(currentRunnerUp().camelColor.rawValue) gets 2nd in leg\n\n"
        if gameIsOver {
            results += "\(currentWinner().camelColor.rawValue) wins race\n\(currentLoser().camelColor.rawValue) loses race"
        }
        return results
    }
    
    func doRace() -> String {
        var results = ""
        while !gameIsOver {
            results = results + doLeg()
        }
        return results
    }
    
    func move(camel: Camel, fromLocation: Int, toLocation: Int) {
        if toLocation < boardCells.count &&
            camels.filter({ $0.location == toLocation}).count == 0 &&
            boardCells[toLocation].desertTile == nil {
            boardCells[toLocation].camelHits += 1
        }
        guard fromLocation != toLocation else { return }
        
        camels.disattachFrom(camel: camel)
        
        var camelStack = [camel]
        var testCamel:Camel? = camel
        
        while testCamel?.camelUpColor != nil {
            testCamel = camels.camelOf(color: testCamel!.camelUpColor!)
            camelStack.append(testCamel!)
        }
        
        camels.topCamelAt(index: toLocation)?.camelUpColor = camel.camelColor
        camelStack.forEach({$0.location = toLocation})
    }
    
    func currentWinner() -> Camel {
        let furthestCamelLocation = camels.sorted(by: { $0.location > $1.location }).first?.location
        let furthestCamels = camels.filter({$0.location == furthestCamelLocation})
        return furthestCamels.filter({$0.camelUpColor == nil}).first!
    }
    
    func currentRunnerUp() -> Camel {
        let currentWinnerColor = currentWinner().camelColor
        let nonFirstCamels = camels.filter({$0.camelColor != currentWinnerColor})
        let furthestCamelLocation = nonFirstCamels.sorted(by: { $0.location > $1.location }).first?.location
        let furthestCamels = nonFirstCamels.filter({$0.location == furthestCamelLocation})
        
        // if there's a furthest camel with no camel up (i.e., current winner is out by itself)
        if let furthestCamel = furthestCamels.filter({$0.camelUpColor == nil}).first {
            return furthestCamel
        }
        // otherwise there's a furthest camel with the current winner on top
        return furthestCamels.filter({$0.camelUpColor == currentWinner().camelColor}).first!
    }
    
    func currentLoser() -> Camel {
        let nearestCamelLocation = camels.sorted(by: { $0.location < $1.location }).first?.location
        let nearestCamels = camels.filter({$0.location == nearestCamelLocation})
        var testCamel: Camel? = nearestCamels.filter({$0.camelUpColor == nil}).first!
        
        while camels.filter({$0.camelUpColor == testCamel?.camelColor}).count > 0 {
            testCamel = self.camels.filter({$0.camelUpColor == testCamel?.camelColor}).first
        }
        return testCamel!
    }
    
    func cycleDesertTileAt(index: Int) {
        guard index < boardCells.count && index >= 0 else { return }
        
        let boardCell = boardCells[index]
        let previousCell = (index - 1) < 0 ? nil : boardCells[index - 1].desertTile
        let nextCell = (index + 1) >= boardCells.count ? nil : boardCells[index + 1].desertTile
        if previousCell == nil && nextCell == nil && camels.filter({ $0.location == index}).count == 0 {
            boardCell.cycleDesertTile()
        }
    }
        

    func copy() -> Board {
        let newCopy = Board()
        
        newCopy.boardCells = boardCells.map({ $0.copy() })
        newCopy.camels = camels.map({ $0.copy() })
        newCopy.dicePyramid = dicePyramid.copy()
        newCopy.gameIsOver = gameIsOver
        
        return newCopy
    }
    
}
