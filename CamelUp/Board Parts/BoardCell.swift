
import Foundation

class BoardCell {
    
    var camelHits: Int = 0
    var desertTile:DesertTile?
    
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
