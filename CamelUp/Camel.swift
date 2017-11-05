
import Foundation

class Camel: CustomDebugStringConvertible, NSCopying {
    
    let color: Color
    var camelUpColor: Color?
    var location: Int = 0
    
    func copy(with zone: NSZone? = nil) -> Any {
        let newCopy = Camel(color: color)
        newCopy.camelUpColor = camelUpColor
        newCopy.location = location
        return newCopy
    }
    
    init(color: Color) {
        self.color = color
    }
    
    var debugDescription: String {
        return "\n\tcamel: \(color) at: \(location) up: \(camelUpColor?.rawValue ?? "noCamel")"
    }
    
}
