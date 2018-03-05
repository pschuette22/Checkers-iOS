//
//  TileIndex.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/3/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation

enum Direction {
    case up
    case down
    case left
    case right
}

class TileIndex: Hashable {

    let hashValue: Int
    let x: Int
    let y: Int

    var isOnBoard: Bool {
        get {
            return x >= 0 && x < 8 && y >= 0 && y < 8
        }
    }

    init?(x: Int, y: Int) {
        hashValue = x * 8 + y
        self.x = x
        self.y = y
        if !isOnBoard {
            return nil
        }
    }

    static func ==(lhs: TileIndex, rhs: TileIndex) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func validMoveIndexes(verticleMovements: [Direction]) -> [NeighborIndex] {
        var indexes = [NeighborIndex]()

        for vert in verticleMovements {
            if let leftMove = self.neighbor(vertical: vert, horizontal: .left) {
                indexes.append(leftMove)
            }
            if let rightMove = self.neighbor(vertical: vert, horizontal: .right) {
                indexes.append(rightMove)
            }
        }

        return indexes
    }

    /// Calculate the tile index of a neighbor with a veritical and horizontal movement
    ///
    /// - Parameters:
    ///   - verticle: y axis movement
    ///   - horizontal: x axis movement
    /// - Returns: tile index if a valid one exists
    func neighbor(vertical: Direction, horizontal: Direction) -> NeighborIndex? {

        return NeighborIndex(index: self, vertical: vertical, horizontal: horizontal)
    }
}

/// A tile found in proximity to a given tile
class NeighborIndex: TileIndex {

    private var vertical: Direction!
    private var horizontal: Direction!

    var jumpIndex: NeighborIndex? {
        get {
            // Chain this neighbor direction for the jump index
            return NeighborIndex(index: self, vertical: self.vertical, horizontal: self.horizontal)
        }
    }

    convenience init?(index: TileIndex, vertical: Direction, horizontal: Direction) {

        var x = index.x
        var y = index.y

        switch vertical {
        case .up:
            y -= 1
        case .down:
            y += 1
        default:
            // Indicates a bug!
            print("Invalid verticle direction")
        }

        switch horizontal {
        case .left:
            x -= 1
        case .right:
            x += 1
        default:
            // Indicates a bug!
            print("Invalid horizonal direction")
        }

        self.init(x: x, y: y)
        self.horizontal = horizontal
        self.vertical = vertical

    }

    // Hide the init chain to ensure a vertical/horizontal direction is specified
    private override init?(x: Int, y: Int) {
        super.init(x: x, y: y)
    }

}
