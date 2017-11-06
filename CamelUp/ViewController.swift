
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoLabel2: UILabel!
    @IBOutlet weak var infoLabel3: UILabel!
    @IBOutlet weak var resultsTextView: UITextView!
    @IBOutlet weak var camelButton: UIButton!
    @IBOutlet weak var legButton: UIButton!
    @IBOutlet weak var raceButton: UIButton!
    @IBOutlet weak var simulationCountControl: UISegmentedControl!
    
    fileprivate let board = Board()
    fileprivate let camelHeight: CGFloat = 40.0
    fileprivate let margin: CGFloat = 20.0
    fileprivate var cellWidth: CGFloat { return (view.frame.width - (margin * 2.0)) / CGFloat(Board.numberOfCells) }
    fileprivate let boardLabels: [UILabel] = (0..<Board.numberOfCells).map { UILabel.smallLabelWith(tag: $0) }
    fileprivate let camelImageViews:[UIImageView]
    fileprivate var simulationCount: Int { return Int(simulationCountControl.titleForSelectedSegment ?? "1000") ?? 1000 }
    
    required init?(coder aDecoder: NSCoder) {
        camelImageViews = board.camels.map({ camel in
            let camelImageView = UIImageView.camelImageView(tintColor: camel.color.color)
            camel.imageView = camelImageView
            return camelImageView
        })
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTextView.layoutManager.allowsNonContiguousLayout = false
        view.subviews.flatMap({ $0 as? UIButton}).forEach({ $0.makeButtonSane() })
        camelImageViews.forEach({ self.view.addSubview($0) })
        boardLabels.forEach({ self.view.addSubview($0) })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutBoardLabels()
        applyBoardState()
    }
    
    @IBAction func simulationCountControlWasTapped(_ sender: UISegmentedControl) {
        applyBoardState()
    }
    
    @IBAction func resetWasTapped(_ sender: UIButton) {
        resultsTextView.text = ""
        board.reset()
        applyBoardState()
    }
    
    @IBAction func camelWasTapped(_ sender: UIButton) {
        resultsTextView.text = resultsTextView.text + board.doCamel()
        applyBoardState()
    }
    
    @IBAction func legWasTapped(_ sender: UIButton) {
        resultsTextView.text = resultsTextView.text + board.doLeg()
        applyBoardState()
    }
    
    @IBAction func raceWasTapped(_ sender: UIButton) {
        resultsTextView.text = resultsTextView.text + board.doRace()
        applyBoardState()
    }
    
    @IBAction func viewWasTappped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        guard location.x > margin &&
            location.x < view.frame.width - margin &&
            location.y > view.frame.height - margin - camelHeight &&
            location.y < view.frame.height - margin else { return }
        
        let cellIndex = Int((location.x - 20.0) / cellWidth)
        let boardCell = board.boardCells[cellIndex]
        let previousCell = (cellIndex - 1) < 0 ? nil : board.boardCells[cellIndex - 1].desertTile
        let nextCell = (cellIndex + 1) >= board.boardCells.count ? nil : board.boardCells[cellIndex + 1].desertTile
        if previousCell == nil && nextCell == nil && board.camels.filter({ $0.location == cellIndex}).count == 0 {
            boardCell.cycleDesertTile()
            applyBoardState()
        }
    }
    
    fileprivate func applyBoardState() {
        camelButton.isEnabled = !board.gameIsOver
        legButton.isEnabled = !board.gameIsOver
        raceButton.isEnabled = !board.gameIsOver
        layoutCamels()
        populateBoardLabels()
        infoLabel.text = runSimulations(simulationType: .leg)
        infoLabel2.text = runSimulations(simulationType: .race)
        infoLabel3.text = "dice remaining: " + board.dicePyramid.dice.flatMap({ $0.color.rawValue + " " })
        resultsTextView.scrollRangeToVisible(NSMakeRange(resultsTextView.text.count, 0))
    }
    
    fileprivate func layoutCamels() {
        board.camels.forEach({camel in
            let camelOffset = CGFloat(self.board.camelsBelow(camel: camel)) * camelHeight * 0.70
            UIView.animate(withDuration: 0.25, animations: {
                camel.imageView?.frame = CGRect(x: (CGFloat(camel.location) * self.cellWidth) + self.margin,
                                                y: self.view.frame.height - self.margin - self.camelHeight - camelOffset,
                                                width: self.cellWidth,
                                                height: self.camelHeight)
            })
        })
    }
    
    fileprivate func layoutBoardLabels() {
        boardLabels.forEach { label in
            label.frame = CGRect(x: (CGFloat(label.tag) * cellWidth) + margin,
                                 y: self.view.frame.height - camelHeight - margin,
                                 width: cellWidth,
                                 height: camelHeight)
        }
    }
    
    fileprivate func populateBoardLabels() {
        boardLabels.forEach { label in
            label.text = "\(label.tag + 1)"
            label.backgroundColor = self.board.boardCells[label.tag].desertTile?.color ?? UIColor.clear
            
            guard let desertTile = self.board.boardCells[label.tag].desertTile else { return }
            
            switch desertTile {
            case .plus:
                label.text = "\(desertTile.description)\n\(label.tag + 1)\n"
            case .minus:
                label.text = "\n\(label.tag + 1)\n\(desertTile.description)"
            }
        }
    }
    
    fileprivate func runSimulations(simulationType: SimulationType) -> String {
        let countedSet = NSCountedSet()
        for _ in 1...simulationCount {
            let boardCopy = board.copy()
            switch simulationType {
            case .race:
                while !boardCopy.gameIsOver { _ = boardCopy.doLeg() }
            case .leg:
                _ = boardCopy.doLeg()
            }
            countedSet.add(boardCopy.currentWinner().color)
        }
        return formatResults(set: countedSet, for: simulationType.rawValue)
    }
    
    fileprivate func formatResults(set: NSCountedSet, for value: String) -> String {
        return "\(value) results for \(simulationCount) simulations:" +
            Color.allColors.flatMap({ color in "\n\(color.rawValue): \(self.formatCount(count: set.count(for: color)))" })
    }
    
    fileprivate func formatCount(count: Int) -> String {
        let percentage = Int(Double(count) / Double(simulationCount) * 100.0)
        return "\(count) -> \(percentage)%"
    }
    
}

