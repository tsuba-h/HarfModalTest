//
//  ViewPanGestureRecognizer.swift
//  HarfModalTest
//
//  Created by 服部　翼 on 2019/09/18.
//  Copyright © 2019 服部　翼. All rights reserved.
//

import UIKit

class ViewPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        switch state {
        case .began: return
        default:
            super.touchesBegan(touches, with: event)
            state = .began
        }
    }
}
