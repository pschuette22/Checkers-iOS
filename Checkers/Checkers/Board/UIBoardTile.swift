//
//  UIBoardTile.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/1/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation
import UIKit

class UIBoardTile: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension UIBoardTile {

    /// Draw the tile based on the color and piece
    ///
    /// - Parameter tile: specifics of the app to be displayed
    func doDraw(tile: Tile) {

        switch tile.color {
        case .black:
            self.backgroundColor = UIColor.black
        case .white:
            self.backgroundColor = UIColor.white
        }

        // If the piece is empty, return
        if tile.piece == .empty  {
            return
        }
        
        // TODO: draw over the tile with the piece value

        let textFrame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        let textView = UITextView(frame: textFrame)
        
        switch tile.piece {
        case .whitePiece:
            textView.text = "W"
        case .blackPiece:
            textView.text = "B"
        default:
            return
        }
        
        // style the board
        textView.isEditable = false
        textView.isSelectable = false
        
        
        
        addSubview(textView)
        
    }

}
