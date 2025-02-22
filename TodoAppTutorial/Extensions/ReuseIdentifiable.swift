//
//  ReuseIdentifiable.swift
//  TodoAppTutorial
//
//  Created by 차상진 on 2/22/25.
//

import Foundation
import UIKit



extension UITableViewCell : ReuseIdentifiable {}

protocol ReuseIdentifiable {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}



