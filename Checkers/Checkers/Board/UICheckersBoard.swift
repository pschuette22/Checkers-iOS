//
//  UICheckersBoard.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/1/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation
import UIKit

/// Display a checkers board and
class UICheckersBoard: UIView {

    var delegate: UICheckersBoardDelegate?

    convenience init(frame: CGRect, delegate: UICheckersBoardDelegate?) {
        self.init(frame: frame)
        self.delegate = delegate
        doDraw()
    }

    override init (frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        // Does not support defining in StoryBoard
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Class Functions
extension UICheckersBoard {

    /// Draw the board
    func doDraw() {

        // Remove the subviews for this
        removeAllSubviews()

        let tileHeight = self.frame.height / 8
        let tileWidth = self.frame.width / 8

        for y in 0 ..< 8 {
            let rowY = CGFloat(integerLiteral: y) * tileHeight
            let rowFrame = CGRect(x: 0.0, y: rowY, width: self.frame.width, height: tileHeight)
            let row = UIView(frame: rowFrame)
            self.addSubview(row)

            for x in 0 ..< 8 {
                // Draw the tile at this location
                let tileIndex = TileIndex(x: x, y: y)!
                drawTile(in: row, at: tileIndex, width: tileWidth, height: tileHeight)
            }
        }
    }

    /// Draw a tile on the board
    ///
    /// - Parameters:
    ///   - x: x coordinate of the tile
    ///   - y: y coordinate of the tile
    ///   - height: height of the tile
    ///   - width: width of the tile
    private func drawTile(in rowView: UIView, at index: TileIndex, width: CGFloat, height: CGFloat) {
        guard let tile = delegate?.getTile(at: index) else {
            fatalError("Must be able to fetch tiles at any point")
        }

        let x = CGFloat(integerLiteral: index.x) * width
        let tileFrame = CGRect(x: x, y: 0.0, width: width, height: height)

        let tileView = UIBoardTile(frame: tileFrame)
        rowView.addSubview(tileView)
        tileView.doDraw(tile: tile)

    }

    // Redraw a tile and remove mask at this index
    func redrawTile(at index: TileIndex) {
        removeTileMask(at: index)
        guard let tile = delegate?.getTile(at: index) else {
            fatalError("Unable to retrieve tile for redraw")
        }
        tileView(at: index)?.doDraw(tile: tile)
    }

    /// Calculate a tile index from a point in the board view
    ///
    /// - Parameter point: location in view
    /// - Returns: tile index for selected location
    func tileIndex(at point: CGPoint) -> TileIndex? {

        let tileWidth = self.frame.width / 8
        let tileHeight = self.frame.height / 8

        let x = Int(floor(point.x / tileWidth))
        let y = Int(floor(point.y / tileHeight))

        return TileIndex(x: x, y: y)
    }

    func addTileMask(at index: TileIndex, mask: UIColor) {
        tileView(at: index)?.tileMask = mask
    }

    func removeTileMask(at index: TileIndex) {
        tileView(at: index)?.tileMask = nil
    }

    private func tileView(at index: TileIndex) -> UIBoardTile? {

        if let tileView = subviews[index.y].subviews[index.x] as? UIBoardTile {
            return tileView
        }
        return nil
    }

}
