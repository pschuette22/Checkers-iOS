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
    
    var activePlayer: Player

    var otherPlayer: Player {
        get {
            let isDown = activePlayer.pawnDirection == .down
            let direction: Direction = isDown ? .up : .down
            return delegate!.player(going: direction)
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
    private var isJumpChain = false

    init(delegate: GameEngineDelegate, activePlayer: Player) {
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
            return didStartTurn(for: activePlayer, on: tile, at: tileIndex)
        } else if selectedTileIndex == tileIndex && !isJumpChain {
            return didUnselectTile(at: tileIndex)
        } else if tile.owner == activePlayer && !isJumpChain {
            _ = didUnselectTile(at: selectedTileIndex!)
            return didStartTurn(for: activePlayer, on: tile, at: tileIndex)
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

    private func didStartTurn(for player: Player, on tile: Tile, at index: TileIndex) -> Bool {

        if tile.owner != activePlayer {
            delegate?.selectIgnored("Tried to select tile active player doesn't own")
            return false
        }

        // This owner has a tile at this location
        // Calculate the moves from here
        selectedTileIndex = index
        validMoves = calculateMoves(for: player, in: delegate!.board, at: index, jumpsOnly: false)

        delegate?.didStartTurn(at: index, with: validMoves!)

        return true
    }

    func calculateMoves(for player: Player, in board: CheckersBoard, at index: TileIndex, jumpsOnly: Bool) -> [Move] {

        let tile = board.tile(at: index)
        
        if tile.owner != player {
            print("Cannot calculate moves for a tile the player does not own")
            return []
        }
        
        var moves = [Move]()

        var verticals = [Direction]()

        if tile.piece == .king {
            verticals.append(contentsOf: [.up, .down])
        } else if tile.piece == .pawn {
            verticals.append(player.pawnDirection)
        }

        for moveIndex in index.validMoveIndexes(verticleMovements: verticals) {
            // Iterate over the valid move indexes
            // determine if movement to this tile is valid
            let tile = board.tile(at: moveIndex)

            if tile.piece == .empty && !jumpsOnly {
                // add a change position move
                moves.append(Move(target: index, destination: moveIndex, jump: nil))
            } else if tile.owner != nil && tile.owner != activePlayer {
                // This tile is owned by the opponent
                guard let jumpToIndex = moveIndex.jumpIndex else {
                    continue
                }
                let jumpedTile = board.tile(at: jumpToIndex)
                if jumpedTile.piece == .empty {
                    // Add a jump move
                    moves.append(Move(target: index, destination: jumpToIndex, jump: moveIndex))
                }
            }

        }

        return moves
    }

    private func didMove(_ move: Move, ignoring otherMoves: [Move]) -> Bool {
        // Execute the move logic
        guard let destination =  delegate?.board.tile(at: move.destination) else { return false }

        delegate?.board.player(activePlayer, did: move)

        delegate?.didMove(move, ignoring: otherMoves)

        if move.type == .jump && didSetupJumpChain(fromPrevious: move, on: destination) {
            return true
        }

        return didFinishTurn(move)
    }

    /// Setup a double jump move
    ///
    /// - Parameters:
    ///   - move: previous move leading into double jump
    ///   - tile: tile that piece landed on from previous move
    /// - Returns: true if a chain jump is available
    private func didSetupJumpChain(fromPrevious move: Move, on tile: Tile) -> Bool {

        // Is there an opportunity for another jump ?
        // Calculate jump moves for this tile
        let activeTileIndex = move.destination!
        var doubleJumpMoves = calculateMoves(for: activePlayer, in: delegate!.board, at: activeTileIndex, jumpsOnly: true)
        if doubleJumpMoves.isEmpty {
            return false
        }

        // Add stay move
        let move = Move(target: activeTileIndex, destination: move.destination, jump: nil)
        doubleJumpMoves.append(move)
        self.validMoves = doubleJumpMoves
        selectedTileIndex = move.destination
        delegate?.didStartTurn(at: activeTileIndex, with: doubleJumpMoves)
        isJumpChain = true
        return true
    }

    // Called when a move is completed
    private func didFinishTurn(_ move: Move) -> Bool {

        var keepPlaying = true
        if delegate?.board.tileCount(for: otherPlayer) == 0 {
            didFinishGame(winner: activePlayer)
            keepPlaying = false
        }
        
        // TODO: did this turn create a tie game ?

        // Switch the active player
        activePlayer = otherPlayer
        // Clear out the selected tile
        selectedTileIndex = nil
        isJumpChain = false
        // indicates the player has finished their turn
        if keepPlaying {
            delegate?.turnDidStart(for: activePlayer)
        }
        return true
    }

    private func didFinishGame(winner:Player) {
        delegate?.didFinishGame(winner)
    }
}
