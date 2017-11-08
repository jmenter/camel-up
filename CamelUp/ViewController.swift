
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var xvLabels: [UILabel]!
    @IBOutlet weak var legLabel: UILabel!
    @IBOutlet weak var raceLabel: UILabel!
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
    
    @IBOutlet var diceButtons: [DieButton]!
    
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
        boardLabels.forEach({ $0.clipsToBounds = true; self.view.addSubview($0) })
        for (index, camel) in board.camels.enumerated() {
            self.xvLabels[index].textColor = camel.color.color
            
            self.diceButtons[index].color = camel.color
            self.diceButtons[index].tintColor = camel.color.color
            self.diceButtons[index].makeButtonSane()
            self.diceButtons[index].layer.borderColor = camel.color.color.cgColor
            self.diceButtons[index].layer.borderWidth = 1
            self.diceButtons[index].setBackgroundColor(.white, for: .selected)
            self.diceButtons[index].setTitleColor(self.diceButtons[index].tintColor, for: .selected)
            self.diceButtons[index].addTarget(self, action: #selector(dieWasTapped(_:)), for: .touchUpInside)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutBoardLabels()
        applyBoardState()
    }
    
    @IBAction func dieWasTapped(_ sender: DieButton) {
        if let die = board.dicePyramid.dice.filter({$0.color == sender.color}).first,
            let index = board.dicePyramid.dice.index(of: die) {
            board.dicePyramid.dice.remove(at: index)
        } else {
            if let color = sender.color {
                board.dicePyramid.dice.append(Die(color: color))
            }
        }
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
    
    @IBAction func viewWasTapped(_ sender: UITapGestureRecognizer) {
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
    
    var pannedCamel: Camel?
    @IBAction func viewWasPanned(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: sender.view)
        if sender.state == .began {
            guard location.x > margin &&
                location.x < view.frame.width - margin else { return }
            let cellIndex = Int((location.x - 20.0) / cellWidth)
            if let camel = board.camels.filter({ $0.location == cellIndex && $0.camelUpColor == nil }).first {
                pannedCamel = camel
            }
        } else if sender.state == .changed {
            pannedCamel?.imageView?.center = location
        } else if sender.state == .ended {
            if let pannedCamel = pannedCamel {
                var cellIndex = Int((location.x - 20.0) / cellWidth)
                cellIndex = cellIndex < 0 ? 0 : cellIndex > Board.numberOfCells - 1 ? Board.numberOfCells - 1 : cellIndex
                board.move(camel: pannedCamel, fromLocation: pannedCamel.location, toLocation: cellIndex)
                self.pannedCamel = nil
                applyBoardState()
            }
        }
    }

    fileprivate func applyBoardState() {
        camelButton.isEnabled = !board.gameIsOver
        legButton.isEnabled = !board.gameIsOver
        raceButton.isEnabled = !board.gameIsOver
        layoutCamels()
        raceLabel.text = runSimulations(simulationType: .race)
        legLabel.text = runSimulations(simulationType: .leg)
        populateBoardLabels()
        for (index, camel) in board.camels.enumerated() {
            self.diceButtons[index].isSelected = board.dicePyramid.dice.filter({$0.color == camel.color }).count != 0
        }
        resultsTextView.scrollRangeToVisible(NSMakeRange(resultsTextView.text.count, 0))
    }
    
    fileprivate func layoutCamels() {
        board.camels.forEach({camel in
            let camelOffset = CGFloat(self.board.camelsBelow(camel: camel)) * camelHeight * 0.70
            UIView.animate(withDuration: 0.25, animations: {
                camel.imageView?.frame = CGRect(x: (CGFloat(camel.location) * self.cellWidth) + self.margin,
                                                y: self.view.frame.height - self.margin - self.camelHeight - self.camelHeight - camelOffset,
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
        // remove camelhit values on cells that aren't meaningful
        boardLabels.forEach({ label in
            var noNeighborDesertTiles = true
            if (label.tag - 1 >= 0 && board.boardCells[label.tag - 1].desertTile != nil) ||
                (label.tag + 1 < Board.numberOfCells && board.boardCells[label.tag + 1].desertTile != nil) {
                noNeighborDesertTiles = false
            }
            let noCamelsOnSpace = board.camels.filter({ $0.location == label.tag }).count == 0
            let noDesertTileOnSpace = board.boardCells[label.tag].desertTile == nil
            
            if !noNeighborDesertTiles || !noCamelsOnSpace || !noDesertTileOnSpace {
                self.board.boardCells[label.tag].camelHits = 0
            }
        })
        
        var biggest = CGFloat(self.board.boardCells.sorted(by: {$0.camelHits > $1.camelHits}).first?.camelHits ?? 1)
        biggest = (biggest < 1 ? 1 : biggest)
        boardLabels.forEach({label in
            let alpha = CGFloat(board.boardCells[label.tag].camelHits) / biggest
            let percentage = CGFloat(board.boardCells[label.tag].camelHits) / CGFloat(self.simulationCount)
            label.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: alpha)
            if alpha > 0.01 {
                label.text = "\n\(label.tag + 1)\n\(Int(percentage * 100.0))%"
            } else {
                label.text = "\(label.tag + 1)"
            }
            
            guard let desertTile = self.board.boardCells[label.tag].desertTile else { return }
            label.backgroundColor = desertTile.color
            switch desertTile {
            case .plus:
                label.text = "\(desertTile.description)\n\(label.tag + 1)\n"
            case .minus:
                label.text = "\n\(label.tag + 1)\n\(desertTile.description)"
            }

        })
    }
    
    fileprivate func runSimulations(simulationType: SimulationType) -> String {
        let countedSet = NSCountedSet()
        let boardCells = board.boardCells.map({ $0.copy() })
        board.boardCells.forEach({ $0.camelHits = 0 })
        for _ in 1...simulationCount {
            let boardCopy = board.copy()
            switch simulationType {
            case .race:
                while !boardCopy.gameIsOver { _ = boardCopy.doLeg() }
            case .leg:
                _ = boardCopy.doLeg()
                for (index, cell) in boardCopy.boardCells.enumerated() {
                    boardCells[index].camelHits += cell.camelHits
                }
            }
            countedSet.add(boardCopy.currentWinner().color)
        }
        board.boardCells = boardCells
        return formatResults(set: countedSet, for: simulationType)
    }
    
    fileprivate func formatResults(set: NSCountedSet, for simulationType: SimulationType) -> String {
        if simulationType == .leg {
            for (index, color) in Color.allColors.enumerated() {
                let winPercentage = Double(set.count(for: color)) / Double(simulationCount)
                self.xvLabels[index].text = "\(xvFormatted(5.0, winPercentage))  \(xvFormatted(3.0, winPercentage))  \(xvFormatted(2.0, winPercentage))"
            }
        }
        return "results of \(simulationCount) \(simulationType.rawValue)s:" +
            Color.allColors.flatMap({ color in "\n\(color.rawValue): \(self.formatCount(count: set.count(for: color)))" })
    }
    
    fileprivate func xvFormatted(_ baseValue: Double, _ winPercentage: Double) -> String {
        let actualXv = (winPercentage * baseValue) - (1.0 - winPercentage)
        let prefix = actualXv > 0.0 ? "+" : ""
        return "\(Int(baseValue)):\(prefix)\(String(format:"%0.2f", actualXv))"
    }
    
    fileprivate func formatCount(count: Int) -> String {
        let percentage = Int(Double(count) / Double(simulationCount) * 100.0)
        return "\(count): \(percentage)%"
    }
    
}

