//
//  CheckersBoard.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/1/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation


/// Model class for the Checkers Board
class CheckersBoard {

    /// Tiles on the board
    private var tiles = [[Tile]]()

    /// initialize the checkers board with two players
    ///
    /// - Parameters:
    ///   - player1: player 1 is headed in the down direction
    ///   - player2: player 2 is headed in the up direction
    init(player1: Player, player2: Player) {

        // Initialize the checkers board model
        // Should contain an 8x8 multi-array of tiles
        initTiles(player1: player1, player2: player2)
    }

}

// MARK: - Private class functions
extension CheckersBoard {

    /// Initialize the tiles before anyone has played
    private func initTiles(player1: Player, player2: Player) {

        var isWhiteTile = true
        for x in 0 ..< 8 {
            var row = [Tile]()
            for _ in 0 ..< 8 {

                var piece: TilePiece
                var owner: Player?
                if (isWhiteTile) {
                    if (x < 3) {
                        piece = .pawn
                        owner = player1
                    } else if (x > 4) {
                        piece = .pawn
                        owner = player2
                    } else {
                        piece = .empty
                    }
                } else {
                    piece = .outOfPlay
                }

                let color: TileColor = isWhiteTile ? .white : .black
                let tile = Tile(color: color, piece: piece, owner: owner)
                row.append(tile)
                isWhiteTile = !isWhiteTile
            }
            // Add the row we just built
            tiles.append(row)
            // Flip it again at the end to account for the change in color per row
            isWhiteTile = !isWhiteTile
        }

    }

}

// MARK: - Class functions
extension CheckersBoard {

    func tile(at index: TileIndex) -> Tile {
        return tiles[index.y][index.x]
    }

    func set(tile: Tile, at index: TileIndex) {
        tiles[index.y][index.x] = tile
    }

    func place(_ piece: TilePiece, withOwner player: Player?, at index: TileIndex) {
        // Order matters, piece will be nil after owner is set
        tiles[index.y][index.x].owner = player
        tiles[index.y][index.x].piece = piece
    }

    func setEmpty(at index: TileIndex) {
        tiles[index.y][index.x].owner = nil
    }

    func isKingingTile(at index: TileIndex, for player: Player) -> Bool {

        return index.y == (player.pawnDirection == .up ? 0 : 7)
    }

    func tileCount(for player: Player) -> Int {
        var count = 0
        for row in tiles {
            count += row.filter({$0.owner == player}).count
        }
        return count
    }

    func reset(player1: Player, player2: Player) {
        tiles.removeAll()
        initTiles(player1: player1, player2: player2)
    }
}
