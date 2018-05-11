
import UIKit

extension UILabel {
    class func smallLabelWith(tag: Int) -> UILabel {
        let newLabel = UILabel(frame: CGRect.zero)
        newLabel.tag = tag
        newLabel.numberOfLines = 0
        newLabel.font = UIFont.systemFont(ofSize: 11)
        newLabel.layer.borderColor = UIColor.gray.cgColor
        newLabel.layer.borderWidth = 1
        newLabel.layer.cornerRadius = 4
        newLabel.textAlignment = .center
        return newLabel
    }
}

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
        UIGraphicsBeginImageContextWithOptions(.one, false, 0)
        color.setFill()
        UIRectFill(.one)
        if let image = UIGraphicsGetImageFromCurrentImageContext(), let cgImage = image.cgImage {
            self.init(cgImage: cgImage)
        } else {
            self.init()
        }
        UIGraphicsEndImageContext()
    }
    
}

extension CGSize {
    public static var one: CGSize { get { return CGSize(width: 1, height: 1) } }
}

extension CGRect {
    public static var one: CGRect { get { return CGRect(origin: .zero, size: .one) } }
}

extension UIImageView {
    class func camelImageView(tintColor: UIColor) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "camel"))
        imageView.tintColor = tintColor
        imageView.contentMode = .scaleAspectFill;
        imageView.isUserInteractionEnabled = false
        return imageView
    }
}

extension UIColor {
    class var darkYellow: UIColor { return UIColor(red: 0.9, green: 0.9, blue: 0.0, alpha: 1.0) }
    class var darkGreen: UIColor { return UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0) }
    class var darkBlue: UIColor { return UIColor(red: 0.4, green: 0.4, blue: 1.0, alpha: 1.0) }
    class var darkWhite: UIColor { return UIColor(white: 0.8, alpha: 1.0) }
}

extension UISegmentedControl {
    var selectedSegmentTitle: String? { return titleForSegment(at: selectedSegmentIndex) }
}
