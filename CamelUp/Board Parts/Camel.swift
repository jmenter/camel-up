
import UIKit

class Camel {
    
    let camelColor: CamelColor
    var camelUpColor: CamelColor?
    var location: Int = 0
    weak var imageView: UIImageView?
    weak var label: UILabel?
    
    init(camelColor: CamelColor) {
        self.camelColor = camelColor
    }
    
    func copy() -> Camel {
        let newCopy = Camel(camelColor: camelColor)
        newCopy.camelUpColor = camelUpColor
        newCopy.location = location
        newCopy.imageView = imageView
        newCopy.label = label
        return newCopy
    }
    
}

extension Array where Element: Camel {
    
    func camelOf(color: CamelColor) -> Camel? {
        return filter({$0.camelColor == color}).first
    }
    
    func reset() {
        forEach({$0.location = -1; $0.camelUpColor = nil})
    }
    
    func disattachFrom(camel: Camel) {
        filter({ $0.camelUpColor == camel.camelColor }).forEach({ $0.camelUpColor = nil })
    }
    
    func topCamelAt(index: Int) -> Camel? {
        return filter({$0.location == index && $0.camelUpColor == nil}).first
    }
    
    func countOfCamelsBelow(camel: Camel) -> Int {
        var count = 0
        var testCamel: Camel? = camel
        
        while filter({$0.camelUpColor == testCamel?.camelColor}).count > 0 {
            count += 1
            testCamel = filter({$0.camelUpColor == testCamel?.camelColor}).first
        }
        return count
    }

}
