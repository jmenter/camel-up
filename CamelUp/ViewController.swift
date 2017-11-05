
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
    
    let camelHeight: CGFloat = 40.0
    let margin: CGFloat = 20.0
    let board = Board()
    let blueCamel = UIImageView(frame: CGRect.zero)
    let greenCamel = UIImageView(frame: CGRect.zero)
    let orangeCamel = UIImageView(frame: CGRect.zero)
    let yellowCamel = UIImageView(frame: CGRect.zero)
    let whiteCamel = UIImageView(frame: CGRect.zero)
    
    let boardLabels:[UILabel] = (0..<16).map { number in
        let label = UILabel(frame: CGRect.zero);
        label.tag = number
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 11)
        return label
    }
    @IBAction func simulationCountControlWasTapped(_ sender: Any) {
        configureCamels()
    }
    
    @IBAction func resetWasTapped(_ sender: Any) {
        resultsTextView.text = ""
        board.reset()
        configureCamels()
    }
    
    @IBAction func camelWasTapped(_ sender: Any) {
        resultsTextView.text = resultsTextView.text + board.doCamel()
        if board.gameIsOver {
            resultsTextView.text = resultsTextView.text + "\(board.currentWinner().color.rawValue) wins race"
        }
        configureCamels()
   }
    
    @IBAction func legWasTapped(_ sender: Any) {
        resultsTextView.text = resultsTextView.text + board.doLeg()
        if board.gameIsOver {
            resultsTextView.text = resultsTextView.text + "\(board.currentWinner().color.rawValue) wins race"
        }
        configureCamels()
    }
    
    @IBAction func raceWasTapped(_ sender: Any) {
        while !board.gameIsOver {
            resultsTextView.text = resultsTextView.text + board.doLeg()
        }
        resultsTextView.text = resultsTextView.text + "\(board.currentWinner().color.rawValue) wins race"
        configureCamels()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.subviews.flatMap({ $0 as? UIButton}).forEach({ $0.makeButtonSane() })
        
        blueCamel.tintColor = UIColor.blue
        greenCamel.tintColor = UIColor.green
        orangeCamel.tintColor = UIColor.orange
        yellowCamel.tintColor = UIColor(red: 0.9, green: 0.9, blue: 0.0, alpha: 1.0)
        whiteCamel.tintColor = UIColor(white: 0.9, alpha: 1.0)
        [blueCamel, greenCamel, orangeCamel, yellowCamel, whiteCamel].forEach({
            $0.image = UIImage(named: "camel")
            $0.contentMode = .scaleAspectFill
            $0.isUserInteractionEnabled = false;
            self.view.addSubview($0)
        })
        boardLabels.forEach({
            $0.layer.borderColor = UIColor.gray.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 4
            $0.textAlignment = .center
            self.view.addSubview($0)
        })
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped(gr:))))
    }
    
    @objc
    func viewWasTapped(gr: UITapGestureRecognizer) {
        let location = gr.location(in: view)
        if  location.x > margin &&
            location.x < view.frame.width - margin &&
            location.y > view.frame.height - margin - camelHeight &&
            location.y < view.frame.height - margin {
            
            let width: CGFloat = (view.frame.width - margin - margin) / 16.0
            let cellIndex = Int((location.x - 20.0) / width)
            //            let modifier = location.y - (view.frame.height - margin - camelHeight)
            let boardCell = board.boardCells[cellIndex]
            let previousCell = (cellIndex - 1) < 0 ? nil : board.boardCells[cellIndex - 1].desertTile
            let nextCell = (cellIndex + 1) >= board.boardCells.count ? nil : board.boardCells[cellIndex + 1].desertTile
            if previousCell == nil && nextCell == nil {
                if boardCell.desertTile == .plus {
                    boardCell.desertTile = .minus
                } else if boardCell.desertTile == .minus {
                    boardCell.desertTile = nil
                } else {
                    boardCell.desertTile = .plus
                }
                configureCamels()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        boardLabels.forEach { label in
            let width: CGFloat = (view.frame.width - margin - margin) / 16.0
            let xPosition: CGFloat = (CGFloat(label.tag) * width) + margin
            let yPosition: CGFloat = self.view.frame.height - camelHeight - margin
            label.frame = CGRect(x: xPosition, y: yPosition, width: width, height: camelHeight)
        }
        configureCamels()
    }
    
    private func configureCamels() {
        board.camels.forEach({camel in
            let viewForCamel = self.viewFor(camel: camel)
            let width: CGFloat = (view.frame.width - margin - margin) / 16.0
            let xPosition: CGFloat = (CGFloat(camel.location) * width) + margin
            let camelsBelow: CGFloat = CGFloat(self.board.camelsBelow(camel: camel))
            let yPosition: CGFloat = self.view.frame.height - margin - camelHeight - (camelsBelow * (camelHeight * 0.75))
            UIView.animate(withDuration: 0.25, animations: {
                viewForCamel.frame = CGRect(x: xPosition, y: yPosition, width: width, height: self.camelHeight)
            })
        })
        boardLabels.forEach { label in
            let boardCell = self.board.boardCells[label.tag]
            let labelText = "\(label.tag + 1)"
            if let desertTile = boardCell.desertTile {
                if desertTile == .plus {
                    label.text = "(+\(desertTile.rawValue))" + "\n" + labelText + "\n"
                    label.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.05)
                } else {
                    label.text = "\n" + labelText + "\n" + "(\(desertTile.rawValue))"
                    label.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.05)
                }
            } else {
                label.text = labelText
                label.backgroundColor = UIColor.clear
            }
        }
        runLegSimulations()
        runRaceSimulations()
        camelButton.isEnabled = !board.gameIsOver
        legButton.isEnabled = !board.gameIsOver
        raceButton.isEnabled = !board.gameIsOver
        if board.dicePyramid.dice.count == 0 {
            infoLabel3.text = "dice remaining: none"
        } else {
            infoLabel3.text = "dice remaining: " + board.dicePyramid.dice.flatMap({ $0.color.rawValue + " " })
        }
    }
    
    private func simulationCount() -> Int {
        let title = simulationCountControl.titleForSegment(at: simulationCountControl.selectedSegmentIndex) ?? "1000"
        return Int(title) ?? 1000
    }
    
    private func runLegSimulations() {
        let countedSet = NSCountedSet()
        for _ in 1...simulationCount() {
            let boardCopy = board.copy() as! Board
            _ = boardCopy.doLeg()
            countedSet.add(boardCopy.currentWinner().color)
        }
        infoLabel.text = "\(simulationCount()) leg simulations:\n" +
            "blue: \(formatCount(count: countedSet.count(for: Color.blue)))\n" +
            "green: \(formatCount(count: countedSet.count(for: Color.green)))\n" +
            "orange: \(formatCount(count: countedSet.count(for: Color.orange)))\n" +
            "yellow: \(formatCount(count: countedSet.count(for: Color.yellow)))\n" +
        "white: \(formatCount(count: countedSet.count(for: Color.white)))"
    }
    
    private func formatCount(count: Int) -> String {
        let fraction = Double(count) / Double(simulationCount())
        let percentage = Int(fraction * 100.0)
        return "\(count) -> \(percentage)%"
    }
    
    private func runRaceSimulations() {
        let countedSet = NSCountedSet()
        for _ in 1...simulationCount() {
            let boardCopy = board.copy() as! Board
            while !boardCopy.gameIsOver {
                _ = boardCopy.doLeg()
            }
            countedSet.add(boardCopy.currentWinner().color)
        }
        infoLabel2.text = "\(simulationCount()) race simulations:\n" +
            "blue: \(formatCount(count: countedSet.count(for: Color.blue)))\n" +
            "green: \(formatCount(count: countedSet.count(for: Color.green)))\n" +
            "orange: \(formatCount(count: countedSet.count(for: Color.orange)))\n" +
            "yellow: \(formatCount(count: countedSet.count(for: Color.yellow)))\n" +
        "white: \(formatCount(count: countedSet.count(for: Color.white)))"
    }
    
    private func viewFor(camel: Camel) -> UIView {
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

