
import UIKit

enum Color : String {
    
    case blue = "blue"
    case green = "green"
    case orange = "orange"
    case yellow = "yellow"
    case white = "white"
    
    static let allColors:[Color] = [.blue, .green, .orange, .yellow, .white]
    
    var color: UIColor {
        switch self {
        case .blue:
            return UIColor.blue
        case .green:
            return UIColor.green
        case .orange:
            return UIColor.orange
        case .yellow:
            return UIColor.darkYellow
        case .white:
            return UIColor.darkWhite
        }
    }
}

