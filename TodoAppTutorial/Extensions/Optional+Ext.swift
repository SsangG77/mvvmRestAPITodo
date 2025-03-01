//
//  Optional+Ext.swift
//  TodoAppTutorial
//
//  Created by 차상진 on 2/28/25.
//

import Foundation

extension Optional {
    init<T, U>(tuple: (T?, U?)) where Wrapped == (T, U) {
        switch tuple {
        case (let t?, let u?):
            self = (t, u)
        default:
            self = nil
        }
    }
}
