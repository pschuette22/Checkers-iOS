//
//  GameEngine.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/3/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation

/// Checkers game engine
/// This drives the logic of the game
class GameEngine {

    private weak var delegate: GameEngineDelegate?
    private var activePlayer: Player!

    private var otherPlayer: Player! {
        get {
            return (activePlayer == .red) ? .black : .red
        }
    }

    // Turn state logic variables
    private var selectedTileIndex: TileIndex? {
        didSet {
            if selectedTileIndex == nil {
                // After removing the selected tile index, remove valid moves
                validMoves = nil
            }
        }
    }

    private var validMoves: [Move]?

    init(delegate: GameEngineDelegate, activePlayer: Player = .red) {
        self.delegate = delegate
        self.activePlayer = activePlayer
    }
}

// MARK: - Turn State Logic
extension GameEngine {

    func didSelect(_ tileIndex: TileIndex) -> Bool {
        // Indicates that a tile was tapped
        guard let tile = delegate?.board.tile(at: tileIndex) else {
            delegate?.selectIgnored("Unable to retrieve tile")
            return false
        }

        if tile.piece == .outOfPlay {
            delegate?.selectIgnored("Tile out of play")
        } else if selectedTileIndex == nil {
            // There isn't a currently selected tile,
            return didStartTurn(on: tile, at: tileIndex)
        } else if selectedTileIndex == tileIndex {
            return didUnselectTile(at: tileIndex)
        } else if tile.owner == activePlayer {
            _ = didUnselectTile(at: selectedTileIndex!)
            return didStartTurn(on: tile, at: tileIndex)
        } else if let move = validMoves?.first(where: {$0.destination == tileIndex}) {
            let otherMoves = validMoves?.filter({$0 != move}) ?? []
            return didMove(move, ignoring: otherMoves)
        }
        // If we get here, this is an invalid tap
        return false
    }

    private func didUnselectTile(at tileIndex: TileIndex) -> Bool {
        delegate?.didUnselectTile(at: tileIndex, with: validMoves ?? [])
        selectedTileIndex = nil
        return true
    }

    private func didStartTurn(on tile: Tile, at index: TileIndex) -> Bool {

        if tile.owner != activePlayer {
            delegate?.selectIgnored("Tried to select tile active player doesn't own")
            return false
        }

        // This owner has a tile at this location
        // Calculate the moves from here
        selectedTileIndex = index
        validMoves = calculateMoves(on: tile, at: index)

        delegate?.didStartTurn(at: index, with: validMoves!)

        return true
    }

    private func calculateMoves(on tile: Tile, at index: TileIndex) -> [Move] {

        var moves = [Move]()

        var verticals: [Direction] = [.up, .down]

        if tile.piece == .pawn {
            if tile.owner == .red {
                // Remove up direction
                verticals.remove(at: 0)
            } else if tile.owner == .black {
                // Remove down direction
                verticals.remove(at: 1)
            }
        }

        for moveIndex in index.validMoveIndexes(verticleMovements: verticals) {
            // Iterate over the valid move indexes
            // determine if movement to this tile is valid
            guard let tile = delegate?.board.tile(at: moveIndex) else {
                continue
            }

            if tile.piece == .empty {
                // add a change position move
                moves.append(Move(target: index, destination: moveIndex, jump: nil))
            } else if tile.owner != nil && tile.owner != activePlayer {
                // This tile is owned by the opponent
                guard let jumpToIndex = moveIndex.jumpIndex,
                    let jumpedTile = delegate?.board.tile(at: jumpToIndex) else {
                    continue
                }
                if jumpedTile.piece == .empty {
                    // Add a jump move

                    moves.append(Move(target: index, destination: jumpToIndex, jump: moveIndex))
                    // TODO: Implement double+ jumps
                }
            }

        }

        return moves
    }

    private func didMove(_ move: Move, ignoring otherMoves: [Move]) -> Bool {
        // Execute the move logic
        guard let target = delegate?.board.tile(at: move.target), let destination =  delegate?.board.tile(at: move.destination) else { return false }
        if target.piece == .pawn && delegate?.board.isKingingTile(at: move.destination, for: activePlayer) ?? false {
            target.piece = .king
        }
        // swap the move tiles
        delegate?.board.set(tile: target, at: move.destination)
        delegate?.board.set(tile: destination, at: move.target)
        // If there is a was a jump, make that tile an empty tile
        if let jump = move.jump, let jumpTile = delegate?.board.tile(at: jump) {
            jumpTile.owner = nil
            // TODO: Check to see if the game has been won
            if delegate?.board.tileCount(for: otherPlayer) == 0 {
                didFinishGame(winner: activePlayer)
            }
        }

        delegate?.didMove(move, ignoring: otherMoves)

        return didFinishTurn(move)
    }

    // Called when a move is completed
    private func didFinishTurn(_ move: Move) -> Bool {

        // Switch the active player
        activePlayer = (activePlayer == .black) ? .red : .black
        // Clear out the selected tile
        selectedTileIndex = nil

        return true
    }

    private func didFinishGame(winner: Player) {
        delegate?.didFinishGame(winner)
    }
}
