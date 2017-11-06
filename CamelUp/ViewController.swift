
import UIKit

enum SimulationType: String {
    case leg = "leg"
    case race = "race"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoLabel2: UILabel!
    @IBOutlet weak var infoLabel3: UILabel!
    @IBOutlet weak var resultsTextView: UITextView!
    @IBOutlet weak var camelButton: UIButton!
    @IBOutlet weak var legButton: UIButton!
    @IBOutlet weak var raceButton: UIButton!
    @IBOutlet weak var simulationCountControl: UISegmentedControl!
    
    fileprivate let camelHeight: CGFloat = 40.0
    fileprivate let margin: CGFloat = 20.0
    fileprivate let board = Board()
    fileprivate let blueCamel = UIImageView.camelImageView(tintColor: UIColor.blue)
    fileprivate let greenCamel = UIImageView.camelImageView(tintColor: UIColor.green)
    fileprivate let orangeCamel = UIImageView.camelImageView(tintColor: UIColor.orange)
    fileprivate let yellowCamel = UIImageView.camelImageView(tintColor: UIColor.darkYellow)
    fileprivate let whiteCamel = UIImageView.camelImageView(tintColor: UIColor.darkWhite)
    fileprivate let boardLabels:[UILabel] = (0..<Board.numberOfCells).map { UILabel.smallLabelWith(tag: $0) }
    
    fileprivate var simulationCount: Int { return Int(simulationCountControl.titleForSelectedSegment ?? "1000") ?? 1000 }
    fileprivate var camelViews:[UIImageView] { return [blueCamel, greenCamel, orangeCamel, yellowCamel, whiteCamel] } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTextView.layoutManager.allowsNonContiguousLayout = false
        view.subviews.flatMap({ $0 as? UIButton}).forEach({ $0.makeButtonSane() })
        camelViews.forEach({ self.view.addSubview($0) })
        boardLabels.forEach({ self.view.addSubview($0) })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutBoardLabels()
        applyBoardState()
    }
    
    @IBAction func simulationCountControlWasTapped(_ sender: Any) {
        applyBoardState()
    }
    
    @IBAction func resetWasTapped(_ sender: Any) {
        resultsTextView.text = ""
        board.reset()
        applyBoardState()
    }
    
    @IBAction func camelWasTapped(_ sender: Any) {
        resultsTextView.text = resultsTextView.text + board.doCamel()
        applyBoardState()
    }
    
    @IBAction func legWasTapped(_ sender: Any) {
        resultsTextView.text = resultsTextView.text + board.doLeg()
        applyBoardState()
    }
    
    @IBAction func raceWasTapped(_ sender: Any) {
        resultsTextView.text = resultsTextView.text + board.doRace()
        applyBoardState()
    }
    
    @IBAction func viewWasTappped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        if  location.x > margin &&
            location.x < view.frame.width - margin &&
            location.y > view.frame.height - margin - camelHeight &&
            location.y < view.frame.height - margin {
            
            let width: CGFloat = (view.frame.width - margin - margin) / CGFloat(Board.numberOfCells)
            let cellIndex = Int((location.x - 20.0) / width)
            let boardCell = board.boardCells[cellIndex]
            let previousCell = (cellIndex - 1) < 0 ? nil : board.boardCells[cellIndex - 1].desertTile
            let nextCell = (cellIndex + 1) >= board.boardCells.count ? nil : board.boardCells[cellIndex + 1].desertTile
            if previousCell == nil && nextCell == nil && board.camels.filter({ $0.location == cellIndex}).count == 0 {
                if boardCell.desertTile == .plus {
                    boardCell.desertTile = .minus
                } else if boardCell.desertTile == .minus {
                    boardCell.desertTile = nil
                } else {
                    boardCell.desertTile = .plus
                }
                applyBoardState()
            }
        }
        
    }
    
    fileprivate func layoutBoardLabels() {
        boardLabels.forEach { label in
            let width: CGFloat = (view.frame.width - margin - margin) / CGFloat(Board.numberOfCells)
            let xPosition: CGFloat = (CGFloat(label.tag) * width) + margin
            let yPosition: CGFloat = self.view.frame.height - camelHeight - margin
            label.frame = CGRect(x: xPosition, y: yPosition, width: width, height: camelHeight)
        }
    }
    
    fileprivate func layoutCamels() {
        board.camels.forEach({camel in
            let width: CGFloat = (view.frame.width - margin - margin) / CGFloat(Board.numberOfCells)
            let xPosition: CGFloat = (CGFloat(camel.location) * width) + margin
            let camelsBelow: CGFloat = CGFloat(self.board.camelsBelow(camel: camel))
            let yPosition: CGFloat = self.view.frame.height - margin - camelHeight - (camelsBelow * (camelHeight * 0.75))
            UIView.animate(withDuration: 0.25, animations: {
                self.viewFor(camel: camel).frame = CGRect(x: xPosition, y: yPosition, width: width, height: self.camelHeight)
            })
        })
    }
    
    fileprivate func populateBoardLabels() {
        boardLabels.forEach { label in
            let boardCell = self.board.boardCells[label.tag]
            let labelText = "\(label.tag + 1)"
            if let desertTile = boardCell.desertTile {
                switch desertTile {
                case .plus:
                    label.text = "(+\(desertTile.rawValue))" + "\n" + labelText + "\n"
                    label.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.05)
                case .minus:
                    label.text = "\n" + labelText + "\n" + "(\(desertTile.rawValue))"
                    label.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.05)
                }
            } else {
                label.text = labelText
                label.backgroundColor = UIColor.clear
            }
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
        infoLabel3.text = "dice remaining: " + (board.dicePyramid.dice.count == 0 ? "none" :
            "" + board.dicePyramid.dice.flatMap({ $0.color.rawValue + " " }))
        resultsTextView.scrollRangeToVisible(NSMakeRange(resultsTextView.text.count, 0))
    }
    
    fileprivate func runSimulations(simulationType: SimulationType) -> String {
        let countedSet = NSCountedSet()
        for _ in 1...simulationCount {
            let boardCopy = board.copy() as! Board
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
            [Color.blue, Color.green, Color.orange, Color.yellow, Color.white].flatMap({ color in
                "\n\(color.rawValue): \(self.formatCount(count: set.count(for: color)))"
            })
    }
    
    fileprivate func formatCount(count: Int) -> String {
        let percentage = Int(Double(count) / Double(simulationCount) * 100.0)
        return "\(count) -> \(percentage)%"
    }
    
    fileprivate func viewFor(camel: Camel) -> UIView {
        switch camel.color {
        case .blue:
            return blueCamel
        case .green:
            return greenCamel
        case .orange:
            return orangeCamel
        case .yellow:
            return yellowCamel
        case .white:
            return whiteCamel
        }
    }
    
}

