
import Foundation

class BoardCell {
    
    var camelHits: Int = 0
    var desertTile: DesertTile?
    
    func cycleDesertTile() {
        if desertTile == .plus {
            desertTile = .minus
        } else if desertTile == .minus {
            desertTile = nil
        } else {
            desertTile = .plus
        }
    }
    
    func copy() -> BoardCell {
        let newCopy = BoardCell()
        newCopy.desertTile = desertTile
        return newCopy
    }
}

extension Array where Element: BoardCell {
    
    func desertTileModifierAt(location: Int) -> Int {
        return (location >= count || location < 0) ? 0 : self[location].desertTile?.rawValue ?? 0
    }

    func desertTileModifierStringAt(location: Int) -> String {
        return desertTileModifierAt(location: location) == -1 ? "-1" :
               desertTileModifierAt(location: location) == 1 ? "+1" : ""

    }
    
    func reset() {
        forEach({ $0.desertTile = nil })
    }
}
