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

    private var defaultColor: UIColor?

    var tileMask: UIColor? {
        didSet {
            if tileMask == nil {
                self.backgroundColor = defaultColor
            } else {
                self.backgroundColor = tileMask
            }
        }
    }

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

        removeAllSubviews()

        switch tile.color {
        case .black:
            self.defaultColor = UIColor.black
        case .white:
            self.defaultColor = UIColor.white
        }
        self.backgroundColor = self.defaultColor

        // If the piece is empty, return
        if tile.piece == .outOfPlay || tile.piece == .empty {
            return
        }

        // TODO: draw over the tile with the piece value

        let textFrame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        let textView = UITextView(frame: textFrame)

        if let owner = tile.owner {
            var text: String!
            switch owner {
            case .red:
                text = "Red"
                textView.textColor = UIColor.red
            case .black:
                text = "Blk"
                textView.textColor = UIColor.black
            }
            if tile.piece == .king {
                print("It's a King!")
                text = "[" + text + "]"
                textView.font = UIFont.boldSystemFont(ofSize: 12.0)
            }

            textView.text = text
        }

        // style the text piece
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = UIColor.clear

        addSubview(textView)

    }

}
