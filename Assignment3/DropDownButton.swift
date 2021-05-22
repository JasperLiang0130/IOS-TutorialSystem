//
//  DropDownButton.swift
//  Assignment3
//
//  Created by mobiledev on 20/5/21.
//

import Foundation
import UIKit

class DropDownButton : UIButton{
    var dropDownList: Array<String>? = nil
    var week:Int? = nil
    
    init(data:Array<String>, selected:String, bgColor:UIColor, wk: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 10))
        setTitleColor(UIColor.black, for: .normal)
        backgroundColor = bgColor
        week = wk
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(selected, for: .normal)
        dropDownList = data
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDropDownList(data:Array<String>){
        self.dropDownList = data
    }
}
