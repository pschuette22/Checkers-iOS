//
//  UIView.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/5/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func removeAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}
