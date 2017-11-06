
import UIKit

class Camel {
    
    let color: Color
    var camelUpColor: Color?
    var location: Int = 0
    weak var imageView: UIImageView?
    
    init(color: Color) {
        self.color = color
    }
    
    func copy() -> Camel {
        let newCopy = Camel(color: color)
        newCopy.camelUpColor = camelUpColor
        newCopy.location = location
        newCopy.imageView = imageView
        return newCopy
    }
    
}
