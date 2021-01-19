//
//  Empty.swift
//  Demo
//
//  Created by Zero.D.Saber on 2020/12/1.
//  Copyright © 2020 Zero.D.Saber. All rights reserved.
//

import Foundation
import ZDFlexLayoutKit

class XController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view1 = UIView()
        view1.zds.makeFlexLayout {
            $0.width(100%).aspectRatio(0.7)
        }
    }
}
