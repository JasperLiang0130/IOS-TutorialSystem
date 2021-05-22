//
//  NumTextField.swift
//  Assignment3
//
//  Created by mobiledev on 21/5/21.
//

import Foundation
import UIKit

extension UITextField {
    func setBottomBorder(_bgColor:UIColor) {
        self.borderStyle = .none
        self.layer.backgroundColor = _bgColor.cgColor
            
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

class NumTextField : UITextField, UITextFieldDelegate {
    var week:Int? = nil
    var extra:Int? = nil
    
    init(word:String, placeholder:String, wk: Int, ex:Int, bgcolor:UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        week = wk
        extra = ex
        delegate = self
        center = self.center
        keyboardType = .numberPad
        translatesAutoresizingMaskIntoConstraints = false
        self.placeholder = placeholder
        textAlignment = .center
        text = word
        backgroundColor = .white
        setBottomBorder(_bgColor: bgcolor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
