
import UIKit

extension UIButton {
    
    func makeButtonSane() {
        clipsToBounds = true
        layer.cornerRadius = 4
        setBackgroundColor(tintColor, for: .normal)
        setBackgroundColor(.lightGray, for: .disabled)
        setTitleColor(.white, for: .normal)
    }
    
    func setBackgroundColor(_ color: UIColor, for state:UIControlState) {
        setBackgroundImage(UIImage(color: color), for: state)
    }
}

extension UIImage {
    
    convenience init(color: UIColor) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        if let image = UIGraphicsGetImageFromCurrentImageContext(), let cgImage = image.cgImage {
            self.init(cgImage: cgImage)
        } else {
            self.init()
        }
        UIGraphicsEndImageContext()
    }
    
}
