//
//  Nibbed.swift
//  TodoAppTutorial
//
//  Created by 차상진 on 2/22/25.
//

import Foundation
import UIKit



protocol Nibbed {
    static var uinib: UINib { get }
}

extension Nibbed {
    static var uinib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension UITableViewCell : Nibbed { }

