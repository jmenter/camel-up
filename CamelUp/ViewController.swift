
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var xvLabels: [UILabel]!
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
    fileprivate let camelImageViews: [UIImageView]
    fileprivate let camelLabels: [UILabel]
    fileprivate var simulationCount: Int { return Int(simulationCountControl.selectedSegmentTitle ?? "1000") ?? 1000 }
    
    @IBOutlet var diceButtons: [DieButton]!
    
    required init?(coder aDecoder: NSCoder) {
        camelImageViews = board.camels.map({ camel in
            let camelImageView = UIImageView.camelImageView(tintColor: camel.camelColor.color)
            camel.imageView = camelImageView
            return camelImageView
        })
        camelLabels = board.camels.map({ camel in
            let camelLabel = UILabel()
            camelLabel.textAlignment = .center
            camelLabel.font = UIFont.systemFont(ofSize: 8)
            camelLabel.numberOfLines = 0
            camel.label = camelLabel
            return camelLabel
        })
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTextView.layoutManager.allowsNonContiguousLayout = false
        view.subviews.compactMap({ $0 as? UIButton}).forEach({ $0.makeButtonSane() })
        camelImageViews.forEach({ self.view.addSubview($0) })
        camelLabels.forEach({ self.view.addSubview($0) })
        boardLabels.forEach({ $0.clipsToBounds = true; self.view.addSubview($0) })
        for (index, camel) in board.camels.enumerated() {
            self.xvLabels[index].textColor = camel.camelColor.color
            self.diceButtons[index].configureFor(camelColor: camel.camelColor)
            self.diceButtons[index].addTarget(self, action: #selector(dieWasTapped(_:)), for: .touchUpInside)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutBoardLabels()
        applyBoardState()
    }
    
    @IBAction func dieWasTapped(_ sender: DieButton) {
        board.dicePyramid.toggleDie(color: sender.color)
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
        guard locationIsInTileZone(sender.location(in: sender.view)) else { return }
        
        let cellIndex = Int((sender.location(in: sender.view).x - margin) / cellWidth)
        board.cycleDesertTileAt(index: cellIndex)
        applyBoardState()
    }
    
    fileprivate func locationIsInTileZone(_ location: CGPoint) -> Bool {
        return location.x > margin && location.x < view.frame.width - margin &&
            location.y > view.frame.height - margin - camelHeight && location.y < view.frame.height - margin
    }
    
    var pannedCamel: Camel?
    @IBAction func viewWasPanned(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: sender.view)
        if sender.state == .began {
            guard location.x > margin && location.x < view.frame.width - margin else { return }
            let cellIndex = Int((location.x - 20.0) / cellWidth)
            pannedCamel = board.camels.topCamelAt(index: cellIndex)
        } else if sender.state == .changed {
            pannedCamel?.imageView?.center = location
            pannedCamel?.label?.center = location
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
        _ = runSimulations(simulationType: .leg)
        _ = runSimulations(simulationType: .race)
        populateBoardLabels()
        configureDiceButtons()
        resultsTextView.font = UIFont.systemFont(ofSize: 10)
        resultsTextView.scrollRangeToVisible(NSMakeRange(resultsTextView.text.count, 0))
    }
    
    fileprivate func configureDiceButtons() {
        for (index, camel) in board.camels.enumerated() {
            self.diceButtons[index].setTitle(board.dicePyramid.stringValueFor(color: camel.camelColor), for: .normal)
            self.diceButtons[index].isSelected = board.dicePyramid.contains(color: camel.camelColor)
        }
    }
    
    fileprivate func layoutCamels() {
        board.camels.forEach({camel in
            let camelOffset = CGFloat(self.board.camels.countOfCamelsBelow(camel:camel)) * camelHeight * 0.70
            UIView.animate(withDuration: 0.25, animations: {
                camel.imageView?.frame = CGRect(x: (CGFloat(camel.location) * self.cellWidth) + self.margin,
                                                y: self.view.frame.height - self.margin - self.camelHeight * 2.0 - camelOffset,
                                                width: self.cellWidth,
                                                height: self.camelHeight)
                camel.label?.frame = camel.imageView?.frame ?? .zero
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
            //            let percentage = CGFloat(board.boardCells[label.tag].camelHits) / CGFloat(self.simulationCount)
            label.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: alpha)
            if alpha > 0.01 {
                label.text = "\n\(label.tag + 1)\n\(String(format: "%.2f", alpha))"
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
        let winnderSet = NSCountedSet()
        let runnerUpSet = NSCountedSet()
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
            winnderSet.add(boardCopy.currentWinner().camelColor)
            runnerUpSet.add((boardCopy.currentRunnerUp().camelColor))
        }
        board.boardCells = boardCells
        return formatResults(winnerSet: winnderSet, runnerUpSet: runnerUpSet, for: simulationType)
    }
    
    fileprivate func formatResults(winnerSet: NSCountedSet, runnerUpSet: NSCountedSet, for simulationType: SimulationType) -> String {
        if simulationType == .leg {
            for (index, color) in CamelColor.allColors.enumerated() {
                let winPercentage = Double(winnerSet.count(for: color)) / Double(simulationCount)
                if let camel = board.camels.camelOf(color: color), let label = camel.label {
                    label.text = "\(Int(winPercentage * 100.0))%L"
                }
                let runnerUpPercentage = Double(runnerUpSet.count(for: color)) / Double(simulationCount)
                self.xvLabels[index].text = "\(xvFormatted(5.0, winPercentage, runnerUpPercentage))  \(xvFormatted(3.0, winPercentage, runnerUpPercentage))  \(xvFormatted(2.0, winPercentage, runnerUpPercentage))"
            }
        } else {
            CamelColor.allColors.forEach({color in
                if let camel = board.camels.camelOf(color: color), let label = camel.label {
                    let winPercentage = Double(winnerSet.count(for: color)) / Double(simulationCount)
                    let currentText = label.text ?? ""
                    label.text = currentText + "\n\(Int(winPercentage * 100.0))%R"
                }
            })
        }
        return "results of \(simulationCount) \(simulationType.rawValue)s:" +
            CamelColor.allColors.flatMap({ color in "\n\(color.rawValue): \(self.formatCount(count: winnerSet.count(for: color)))" })
    }
    
    fileprivate func xvFormatted(_ baseValue: Double, _ winPercentage: Double, _ runnerUpPercentage: Double) -> String {
        let losePercentage = 1.0 - winPercentage - runnerUpPercentage;
        let actualXv = (winPercentage * baseValue) + (runnerUpPercentage * 1.0) - (losePercentage * 1.0)
        let prefix = actualXv > 0.0 ? "+" : ""
        return "\(Int(baseValue)):\(prefix)£\(String(format:"%0.2f", actualXv))"
    }
    
    fileprivate func formatCount(count: Int) -> String {
        let percentage = Int(Double(count) / Double(simulationCount) * 100.0)
        return "\(count): \(percentage)%"
    }
    
}

