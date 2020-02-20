//
//  UISpringTimingParameters+Ex.swift
//  HarfModalTest
//
//  Created by 服部　翼 on 2019/09/18.
//  Copyright © 2019 服部　翼. All rights reserved.
//

import UIKit

extension UISpringTimingParameters {
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}
