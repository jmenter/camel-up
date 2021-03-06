
import UIKit

enum DesertTile: Int {
    
    case plus = 1
    case minus = -1
    
    var color: UIColor {
        switch self {
        case .plus:
            return UIColor(red: 0, green: 1, blue: 0, alpha: 0.33)
        case .minus:
            return UIColor(red: 1, green: 0.5, blue: 0, alpha: 0.33)
        }
    }
    
    var description: String {
        switch self {
        case .plus:
            return "+1"
        case .minus:
            return "-1"
        }
    }
}
