
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoLabel2: UILabel!
    let board = Board()
    let blueCamel = UIView(frame: CGRect.zero)
    let greenCamel = UIView(frame: CGRect.zero)
    let orangeCamel = UIView(frame: CGRect.zero)
    let yellowCamel = UIView(frame: CGRect.zero)
    let whiteCamel = UIView(frame: CGRect.zero)

    let boardLabels:[UILabel] = (0..<16).map { number in
        let label = UILabel(frame: CGRect.zero);
        label.tag = number
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 9)
        return label
    }
    
    @IBAction func resetWasTapped(_ sender: Any) {
        board.reset()
        configureCamels()
    }
    
    @IBAction func camelWasTapped(_ sender: Any) {
        board.doCamel()
        configureCamels()
    }
    
    @IBAction func legWasTapped(_ sender: Any) {
        board.doLeg()
        configureCamels()
    }
    
    @IBAction func raceWasTapped(_ sender: Any) {
        while !board.gameIsOver {
            board.doLeg()
        }
        configureCamels()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        blueCamel.backgroundColor = UIColor.blue
        greenCamel.backgroundColor = UIColor.green
        orangeCamel.backgroundColor = UIColor.orange
        yellowCamel.backgroundColor = UIColor.yellow
        whiteCamel.backgroundColor = UIColor.lightGray
        [blueCamel, greenCamel, orangeCamel, yellowCamel, whiteCamel].forEach({
            $0.isUserInteractionEnabled = false;
            self.view.addSubview($0)
        })
        boardLabels.forEach({
            $0.layer.borderColor = UIColor.darkGray.cgColor
            $0.layer.borderWidth = 1
            $0.textAlignment = .center
            self.view.addSubview($0)
        })
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped(gr:))))
        infoLabel.text = "infolabel"
    }

    @objc
    func viewWasTapped(gr: UITapGestureRecognizer) {
        let location = gr.location(in: view)
        if  location.x > 20.0 && location.x < view.frame.width - 20.0 &&
            location.y > view.frame.height - 70 && location.y < view.frame.height - 20 {
            
            let width: CGFloat = (view.frame.width - 40.0) / 16.0
            let cellIndex = (location.x - 20.0) / width
            let modifier = location.y - (view.frame.height - 70.0)
            let boardCell = board.boardCells[Int(cellIndex)]
            if modifier < 16.666 {
                boardCell.desertTile = .minus
            } else if modifier < 32 {
                boardCell.desertTile = nil
            } else {
                boardCell.desertTile = .plus
            }
            configureCamels()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureCamels()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        boardLabels.forEach { label in
            let width: CGFloat = (view.frame.width - 40.0) / 16.0
            let xPosition: CGFloat = (CGFloat(label.tag) * width) + 20.0
            let yPosition: CGFloat = self.view.frame.height - 70.0
            label.frame = CGRect(x: xPosition, y: yPosition, width: width, height: 50)
        }

    }
    private func configureCamels() {
        board.camels.forEach({camel in
            let viewForCamel = self.viewFor(camel: camel)
            let width: CGFloat = (view.frame.width - 40.0) / 16.0
            let xPosition: CGFloat = (CGFloat(camel.location) * width) + 20.0
            let camelsBelow: CGFloat = CGFloat(self.board.camelsBelow(camel: camel))
            let yPosition: CGFloat = self.view.frame.height - 70.0 - (camelsBelow * 50.0)
            UIView.animate(withDuration: 0.25, animations: {
                viewForCamel.frame = CGRect(x: xPosition, y: yPosition, width: width, height: 50)
            })
        })
        boardLabels.forEach { label in
            let boardCell = self.board.boardCells[label.tag]
            if let desertTile = boardCell.desertTile {
                label.text = "\(label.tag + 1)\n(\(desertTile.rawValue))"
            } else {
                label.text = "\(label.tag + 1)\n"
            }
        }
        runLegSimulations()
        runRaceSimulations()
    }
    
    private func runLegSimulations() {
        let simulationCount = 1000
        let countedSet = NSCountedSet()
        for _ in 1...simulationCount {
            let boardCopy = board.copy() as! Board
            boardCopy.doLeg()
            countedSet.add(boardCopy.currentWinner().color)
        }
        infoLabel.text = "leg simulations:\n" +
            "blue: \(countedSet.count(for: Color.blue))\n" +
            "green: \(countedSet.count(for: Color.green))\n" +
            "orange: \(countedSet.count(for: Color.orange))\n" +
            "yellow: \(countedSet.count(for: Color.yellow))\n" +
            "white: \(countedSet.count(for: Color.white))\n"
    }
    
    private func runRaceSimulations() {
        let simulationCount = 1000
        let countedSet = NSCountedSet()
        for _ in 1...simulationCount {
            let boardCopy = board.copy() as! Board
            while !boardCopy.gameIsOver {
                boardCopy.doLeg()
            }
            countedSet.add(boardCopy.currentWinner().color)
        }
        infoLabel2.text = "race simulations:\n" +
            "blue: \(countedSet.count(for: Color.blue))\n" +
            "green: \(countedSet.count(for: Color.green))\n" +
            "orange: \(countedSet.count(for: Color.orange))\n" +
            "yellow: \(countedSet.count(for: Color.yellow))\n" +
        "white: \(countedSet.count(for: Color.white))\n"

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

