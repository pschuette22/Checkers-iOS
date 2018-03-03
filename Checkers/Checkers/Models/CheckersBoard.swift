//
//  CheckersBoard.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/1/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation

enum TileColor {
    case black
    case white
}

enum TilePiece {
    case empty
    case whitePiece
    case whiteKing
    case blackPiece
    case blackKing
}

struct Tile {

    let color: TileColor
    let piece: TilePiece

    init(color: TileColor, piece: TilePiece) {
        self.color = color
        self.piece = piece
    }
}

class CheckersBoard {

    private var tiles = [[Tile]]()

    init() {

        // Initialize the checkers board model
        // Should contain an 8x8 multi-array of tiles
        initTiles()
    }

}

// MARK: - Private class functions
extension CheckersBoard {

    /// Initialize the tiles before anyone has played
    private func initTiles() {

        var isWhiteTile = true
        for x in 0 ..< 8 {
            var row = [Tile]()
            for _ in 0 ..< 8 {

                var piece: TilePiece = .empty
                if (isWhiteTile) {
                    if (x < 3) {
                        piece = .whitePiece
                    } else if (x > 4) {
                        piece = .blackPiece
                    }
                }

                let color: TileColor = isWhiteTile ? .white : .black
                let tile = Tile(color: color, piece: piece)
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

    func getTile(x: Int, y: Int) -> Tile {
        return tiles[y][x]
    }

}
