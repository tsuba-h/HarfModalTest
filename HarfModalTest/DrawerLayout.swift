//
//  DrawerLayout.swift
//  HarfModalTest
//
//  Created by 服部　翼 on 2019/09/17.
//  Copyright © 2019 服部　翼. All rights reserved.
//

import UIKit

public enum DrawerPositionType: Int {
    case full
    case half
    case tip
    
    func isBeginningArea(fractionPoint: CGFloat, velocity: CGPoint, halfAreaBorderPoint: CGFloat) -> Bool {
        switch self {
        case .tip:
            //..<0.2 ~= fractionPointは fractionPointが0.2未満ならという意味になる。
            print(
                "velo",velocity.y,
                "fractionPoint",fractionPoint
            )
            return velocity.y > 300 || ..<0.2 ~= fractionPoint && velocity.y >= 0.0 || halfAreaBorderPoint >= fractionPoint && velocity.y > 0
        case .full:
            return velocity.y < 0.0 || ..<0.35 ~= fractionPoint && velocity.y <= 0.0 || halfAreaBorderPoint >= fractionPoint && velocity.y < 0.0
        case .half:
            fatalError()
        }
    }
    
    func isEndArea(fractionPoint: CGFloat, velocity: CGPoint, halfAreaBorderPoint: CGFloat) -> Bool {
        switch self {
        // velocityが-30０より下ということは、し下から上に思いっきり引っ張ったということ
        case .tip:
            return velocity.y < -300 || 0.65... ~= fractionPoint && velocity.y <= 0 || halfAreaBorderPoint <= fractionPoint && velocity.y < 0
        // velocityが300より上ということは上から下にｐ思いっきり引っ張ったということ
        case .full:
            return velocity.y > 300 || 0.8... ~= fractionPoint && velocity.y >= 0 || halfAreaBorderPoint <= fractionPoint && velocity.y > 0
        case .half:
            fatalError()
        }
    }
}
