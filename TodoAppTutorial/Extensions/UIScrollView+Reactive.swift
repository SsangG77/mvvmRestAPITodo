//
//  UIScrollView+Reactive.swift
//  TodoAppTutorial
//
//  Created by 차상진 on 3/1/25.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa

extension Reactive where Base: UIScrollView {
    var bottomReached: Observable<Void> {
        
        
        return contentOffset.map {
            (offset : CGPoint) in
                let height = self.base.frame.size.height
                let contentYOffset = offset.y
                let distanceFromBottom = self.base.contentSize.height - contentYOffset
                
            return distanceFromBottom - 200 < height
           
        }
        .filter{ $0 == true }.map { _ in }
        
      
    }
}
