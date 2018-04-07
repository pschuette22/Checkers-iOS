//
//  ViewController.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/1/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICheckersBoardDelegate, GameEngineDelegate {

    var players = Set<Player>()
    
    var boardView: UICheckersBoard!

    var board: CheckersBoard!
 
    var engine: GameEngine!

    private var tapRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initPlayers()
        // Draw the board
        drawInitialBoard()
        // Register a gesture recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        boardView.addGestureRecognizer(tapRecognizer)

        engine = GameEngine(delegate: self, activePlayer: player(going: .up))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {

        // Ignore this tap
        if recognizer.state != .ended {
            return
        }

        // Convert the recognized location to a tile within the board
        let location = recognizer.location(in: boardView)
        guard let tileIndex = boardView.tileIndex(at: location) else {
            return
        }

        // Send the selected Tile Index to the game engine
        if engine.didSelect(tileIndex) {
            // trigger a redraw ?
            // only do this every time if the
        }
    }

}

// MARK: - Private class functions
extension ViewController {
    
    
    /// Initialize the player set
    private func initPlayers() {
        let player1 = Player(name: "p1", color: .red, pawnDirection: .down)
        let player2 = Player(name: "p2", color: .black, pawnDirection: .up)
        players.insert(player1)
        players.insert(player2)
    }
    
    private func drawInitialBoard() {

        board = CheckersBoard(player1: player(going: .down), player2: player(going: .up))
        
        let topPadding = UIApplication.shared.statusBarFrame.size.height + 8

        // Top padding of 8, side padding 0. Must be a square
        var maxHeight = self.view.frame.height - topPadding
        var maxWidth = self.view.frame.width

        if (maxHeight > maxWidth) {
            maxHeight = maxWidth
        } else {
            maxWidth = maxHeight
        }

        let leftPadding = (self.view.frame.width - maxWidth) / 2

        let frame = CGRect(x: leftPadding, y: topPadding, width: maxWidth, height: maxHeight)
        boardView = UICheckersBoard(frame: frame, delegate: self)
        self.view.addSubview(boardView)

    }

    private func resetGame() {
        board.reset(player1: player(going: .down), player2: player(going: .up))
        boardView.doDraw()
    }
}

// MARK: - UICheckersBoardDelegate methods
extension ViewController {

    func getTile(at index: TileIndex) -> Tile {
        return board.tile(at: index)
    }

}

// MARK: - GameEngineDelegate methods
extension ViewController {

    func player(going direction: Direction) -> Player {
        return players.first(where: {$0.pawnDirection == direction})!
    }
    
    func selectIgnored(_ message: String) {
        print("Select Ignored: \(message)")
    }

    func didUnselectTile(at index: TileIndex, with moves: [Move]) {
        boardView.removeTileMask(at: index)

        for move in moves {
            boardView.removeTileMask(at: move.destination)

            if let jumpIndex = move.jumps?.first {
                boardView.removeTileMask(at: jumpIndex)
            }
        }
    }

    func didStartTurn(at index: TileIndex, with moves: [Move]) {
        // Add a tile mask to the selected item
        boardView.addTileMask(at: index, mask: .cyan)

        for move in moves {
            boardView.addTileMask(at: move.destination, mask: .green)

            if let jumpIndex = move.jumps?.first {
                boardView.addTileMask(at: jumpIndex, mask: .gray)
            }
        }

    }

    func didMove(_ move: Move, ignoring otherMoves: [Move]) {

        // Do a complete redraw of tiles involved in the move
        boardView.redrawTile(at: move.target)
        boardView.redrawTile(at: move.destination)
        if let jumpIndex = move.jumps?.first {
            boardView.redrawTile(at: jumpIndex)
        }

        for ignoredMove in otherMoves {
            boardView.removeTileMask(at: ignoredMove.destination)
            if let jumpIndex = ignoredMove.jumps?.first {
                boardView.removeTileMask(at: jumpIndex)
            }
        }
    }

    func didFinishGame(_ winner: Player) {
        let title =  "\(winner.name) wins!"

        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cool", style: UIAlertActionStyle.cancel, handler: nil))
        let resetAction = UIAlertAction(title: "Play Again?", style: .default) { (_) in
            self.resetGame()
        }
        alert.addAction(resetAction)
        present(alert, animated: true, completion: nil)
    }

}
