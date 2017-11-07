
import UIKit

class DieButton: UIButton {
    
    var color: Color?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    @objc
    fileprivate func handleTap() {
        isSelected = !isSelected
    }
}
