//
//  Empty.swift
//  Demo
//
//  Created by Zero.D.Saber on 2021/1/19.
//  Copyright © 2021 Zero.D.Saber. All rights reserved.
//

import Foundation
import ZDFlexLayoutKit

class ZDXView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubViews() {
        let view1 = UIView()
        let view2 = UIView()
        
        view1.zds.makeFlexLayout { (make) in
            make.width(100).aspectRatio(0.7)
        }
        ZDFlexLayoutDiv.zds.makeFlexLayout { (make) in
            make.isEnable(true).paddingHorizontal(10)
        }
        view2.zds.makeFlexLayout {
            $0.width(100).height(200)
        }
    }
}
