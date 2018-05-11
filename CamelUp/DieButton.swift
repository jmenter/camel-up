
import UIKit

class DieButton: UIButton {
    
    var color: CamelColor?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    func configureFor(camelColor: CamelColor) {
        color = camelColor
        tintColor = camelColor.color
        makeButtonSane()
        layer.borderColor = camelColor.color.cgColor
        layer.borderWidth = 1
        setBackgroundColor(.white, for: .selected)
        setTitleColor(tintColor, for: .selected)
    }
    
    @objc
    fileprivate func handleTap() {
        isSelected = !isSelected
    }
    
}
