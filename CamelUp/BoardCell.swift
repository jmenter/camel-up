
import Foundation

class BoardCell: CustomDebugStringConvertible, NSCopying {
    
    var desertTile:DesertTile?
    var debugDescription: String { return "\(desertTile?.rawValue ?? 0)" }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let newCopy = BoardCell()
        newCopy.desertTile = desertTile
        return newCopy
    }
}
