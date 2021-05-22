//
//  CheckBoxButton.swift
//  Assignment3
//
//  Created by mobiledev on 21/5/21.
//

import Foundation
import UIKit

class CheckBox: UISwitch {
    var week:Int? = nil
    var position:Int? = nil
    
    func setWeek(w:Int){
        week = w
    }
    func setPosition(p:Int){
        position = p
    }
}

class CheckBoxButton: UIStackView {
    
    var label = UILabel()
    let box = CheckBox()
    init(word:String, pos:Int, week: Int){
        super.init(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        label.text = word
        axis = .horizontal
        backgroundColor = .yellow
        distribution = .fill
        alignment = .center
        spacing = 20
        translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(label)
        box.setWeek(w: week)
        box.setPosition(p: pos)
        addArrangedSubview(box)
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
