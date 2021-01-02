//
//  PullUpView.swift
//  Lilo
//
//  Created by Maïlys Perez on 01/01/2021.
//

import UIKit

class PullUpView: UIView {

    override func awakeFromNib() {
        self.setupView()
    }
    
    func setupView() {
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.clipsToBounds = true
        self.layer.cornerRadius = 30
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
