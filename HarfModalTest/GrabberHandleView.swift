//
//  GrabberHandleView.swift
//  HarfModalTest
//
//  Created by 服部　翼 on 2019/09/18.
//  Copyright © 2019 服部　翼. All rights reserved.
//

import UIKit

class GrabberHandleView: UIView {
    struct  Default {
        static let width: CGFloat = 36.0
        static let height: CGFloat = 5.0
        static let barColor: UIColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }

    init() {
        let size = CGSize(width: Default.width, height: Default.height)
        super .init(frame: CGRect(origin: .zero, size: size))
        self.backgroundColor = Default.barColor
        render()
    }
    
    private func render() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = frame.size.height * 0.5
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

}
