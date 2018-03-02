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
            for x in 0 ..< 8 {
                // Draw the tile at this location
                drawTile(x: x, y: y, width: tileWidth, height: tileHeight)
            }
        }
    }
    
    
    /// Remove all the tiles from the view
    func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    
    /// Draw a tile on the board
    ///
    /// - Parameters:
    ///   - x: x coordinate of the tile
    ///   - y: y coordinate of the tile
    ///   - height: height of the tile
    ///   - width: width of the tile
    func drawTile(x: Int, y: Int, width: CGFloat, height: CGFloat) {
        guard let tile = delegate?.getTitle(x: x, y: y) else {
            fatalError("Must be able to fetch tiles at any point")
        }
        
        
        let tileFrame = CGRect(x: CGFloat(integerLiteral: x) * width, y: CGFloat(integerLiteral: y) * height, width: width, height: height)
        
        let tileView = UIBoardTile(frame: tileFrame)
        self.addSubview(tileView)
        tileView.doDraw(tile: tile)
        
    }
    
}
