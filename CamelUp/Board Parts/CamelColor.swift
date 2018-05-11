
import UIKit

enum CamelColor : String {
    
    case blue = "blue"
    case green = "green"
    case orange = "orange"
    case yellow = "yellow"
    case white = "white"
    
    static let allColors:[CamelColor] = [.blue, .green, .orange, .yellow, .white]
    
    var color: UIColor {
        switch self {
        case .blue:
            return UIColor.darkBlue
        case .green:
            return UIColor.darkGreen
        case .orange:
            return UIColor.orange
        case .yellow:
            return UIColor.darkYellow
        case .white:
            return UIColor.darkWhite
        }
    }
}

