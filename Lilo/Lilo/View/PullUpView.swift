//
//  PullUpView.swift
//  Lilo
//
//  Created by Maïlys Perez on 01/01/2021.
//

import UIKit

@IBDesignable
class PullUpView: UIView {

    override func awakeFromNib() {
        self.setupView()
    }
    
    func setupView() {
        self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.clipsToBounds = true
        self.layer.cornerRadius = 30
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
