//
//  MarkStudentUIViewController.swift
//  Assignment3
//
//  Created by mobiledev on 23/5/21.
//

import UIKit
import DropDown
import Firebase
import FirebaseFirestoreSwift

class MarkStudentUIViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var stuIdLabel: UILabel!
    @IBOutlet var markView: UIScrollView!
    
    @IBOutlet var gradeLabel: UILabel!
    var selectedStudent:StudentSummary?
    var selectedScheme:Scheme?
    
    let level_HD = ["HD+", "HD", "DN", "CR", "PP", "NN"]
    let level_A = ["A", "B", "C", "D", "F"]
    let attendance = ["Attend", "Absent"]
    
    
    @IBAction func onMarkSave(_ sender: Any) {
        
        (sender as! UIBarButtonItem).title = "Loading..."
        let db = Firestore.firestore()
        
        do
        {
            try db.collection("students").document(selectedStudent!.docId!).setData(from: selectedStudent!) {err in
                if let err = err {
                    print("Error updating document: \(err)")
                }else {
                    print("Document successfully updated")
                    self.performSegue(withIdentifier: "saveMarkSegue", sender: sender)
                }
            }
        } catch {
            print("Error updating document \(error)")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameLabel.text = selectedStudent!.name
        stuIdLabel.text = selectedStudent!.id
        
        let grades = selectedStudent!.grades
        
        let contentView = vStack()
        if self.selectedScheme!.type == "level_HD"
        {
            let choose = (grades[selectedScheme!.week-1] == "") ? level_HD.last : grades[selectedScheme!.week-1]
            if grades[selectedScheme!.week-1] == "" //give initial for user save
            {
                selectedStudent!.grades[selectedScheme!.week-1] = level_HD.last!
            }
            contentView.addArrangedSubview(buildDropDown(data: level_HD, selected: choose!, week: selectedScheme!.week, bgcolor: UIColor.yellow))
            
        }else if self.selectedScheme!.type == "level_A"
        {
            let choose = (grades[selectedScheme!.week-1] == "") ? level_A.last : grades[selectedScheme!.week-1]
            if grades[selectedScheme!.week-1] == "" //give initial for user save
            {
                selectedStudent!.grades[selectedScheme!.week-1] = level_A.last!
            }
            contentView.addArrangedSubview(buildDropDown(data: level_A, selected: choose!, week: selectedScheme!.week, bgcolor: UIColor.yellow))
            
        }else if selectedScheme!.type == "checkbox"
        {
            let choose = (grades[selectedScheme!.week-1] == "") ? getInitCheckBox(box_size: Int(selectedScheme!.extra)!) : grades[selectedScheme!.week-1]
            if grades[selectedScheme!.week-1] == "" //give initial for user save
            {
                selectedStudent!.grades[selectedScheme!.week-1] = getInitCheckBox(box_size: Int(selectedScheme!.extra)!)
            }
            contentView.addArrangedSubview(buildCheckBoxes(boxes: choose, week: selectedScheme!.week))
            
        }else if selectedScheme!.type == "score"
        {
            let choose = (grades[selectedScheme!.week-1] == "") ? "0" : grades[selectedScheme!.week-1]
            if grades[selectedScheme!.week-1] == "" //give initial for user save
            {
                selectedStudent!.grades[selectedScheme!.week-1] = "0"
            }
            contentView.addArrangedSubview(hStack(views:buildNumTextField(word: choose, placeholder: "Only Number", week: selectedScheme!.week, extra: Int(selectedScheme!.extra)!, bgColor: UIColor.yellow), buildLabelView(word: "/\(selectedScheme!.extra)", bgColor: UIColor.white)))
            
        }else if self.selectedScheme!.type == "attendance"
        {
            let choose = (grades[selectedScheme!.week-1] == "") ? attendance.last : grades[selectedScheme!.week-1]
            if grades[selectedScheme!.week-1] == "" //give initial for user save
            {
                selectedStudent!.grades[selectedScheme!.week-1] = attendance.last!
            }
            contentView.addArrangedSubview(buildDropDown(data: attendance, selected: choose!, week: selectedScheme!.week, bgcolor: UIColor.yellow))
        }
        
        markView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            markView.leadingAnchor.constraint(equalTo: markView.leadingAnchor),
            markView.trailingAnchor.constraint(equalTo: markView.trailingAnchor),
            markView.topAnchor.constraint(equalTo: markView.topAnchor),
            markView.bottomAnchor.constraint(equalTo: markView.bottomAnchor, constant: 0.0),
            
            contentView.leadingAnchor.constraint(equalTo: markView.leadingAnchor),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: markView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: markView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: markView.bottomAnchor)
        ])
        
    }
    
    func hStack(views:UIView...) ->UIStackView{
        let hView = UIStackView(arrangedSubviews: views)
        hView.backgroundColor = .white
        hView.axis = .horizontal
        //make each arranged subview equal width
        hView.distribution = .fillProportionally
        //center the arranged subviews vertically
        hView.alignment = .center
        //horizontal gap between arranged subviews
        hView.spacing = 8
        hView.translatesAutoresizingMaskIntoConstraints = false
        return hView
    }
    
    func vStack() ->UIStackView{
        let vView = UIStackView()
        vView.backgroundColor = .white
        vView.axis = .vertical
        //make each arranged subview equal width
        vView.distribution = .fill
        //center the arranged subviews vertically
        vView.alignment = .leading
        //horizontal gap between arranged subviews
        vView.spacing = 20
        vView.translatesAutoresizingMaskIntoConstraints = false
        return vView
    }
    
    func buildLabelView(word:String, bgColor:UIColor) ->UIView
    {
        let testLabel = UILabel()
        testLabel.translatesAutoresizingMaskIntoConstraints = false
        testLabel.backgroundColor = bgColor
        testLabel.textAlignment = .left
        testLabel.text = word
        
        return testLabel
    }
    
    func buildDropDown(data:Array<String>, selected:String, week:Int, bgcolor: UIColor) ->UIView
    {
        let btn = DropDownButton(data: data, selected: selected, bgColor: bgcolor, wk: week)
        btn.addTarget(self, action: #selector(self.tapDropdownAction(sender:)), for: UIControl.Event.touchUpInside)
        
        return btn
    }
    
    func buildCheckBoxes(boxes:String, week:Int) ->UIView
    {
        print("week \(week), boxes: \(boxes)")
        let arr_box = boxes.components(separatedBy: ",")
        let v_view = vStack()
        v_view.spacing = 1
        for index in 0...(arr_box.count-1)
        {
            let w = "Task "+String(index+1)
            let checkbox = CheckBoxButton(word: w, pos: index, week: week)
            //set initial data
            let box = checkbox.arrangedSubviews.last as! CheckBox
            if Int(arr_box[index]) == 1
            {
                box.isOn = true
            }else{
                box.isOn = false
            }
            //set addtarget here
            box.addTarget(self, action: #selector(tapCheckBox(sender:)), for: UIControl.Event.valueChanged)
            
            v_view.addArrangedSubview(checkbox)
        }
        return v_view
    }
    
    func buildNumTextField(word:String, placeholder:String, week:Int, extra: Int, bgColor:UIColor) ->UIView{
        let txt = NumTextField(word: word, placeholder: placeholder, wk: week, ex: extra, bgcolor: bgColor)
        //add target
        txt.addTarget(self, action: #selector(tapNumText(sender:)), for: UIControl.Event.editingChanged)
        return txt
    }
    
    @objc func tapNumText(sender: NumTextField){
        let txt = sender as NumTextField
        print("typing: \(txt.text!)")
        if txt.text == ""{
            txt.text = "0"
            return
        }else if Int(txt.text!)! > txt.extra!
        {
            txt.text = String(txt.extra!)
        }else if Int(txt.text!)! < 0
        {
            txt.text = "0"
            //add 0 to grade
            
        }
        selectedStudent!.grades[txt.week!-1] = String(Int(txt.text!)!)
        sender.text = String(Int(txt.text!)!) //remove captical 0
        
    }
    
    @objc func tapCheckBox(sender: CheckBox){
        let box = (sender as CheckBox)
        print("week: \(box.week!), position: \(box.position!)")
        //assign result to grade
        let splitNum = (selectedStudent!.grades[box.week!-1] == "") ? self.getInitCheckBox(box_size: Int(self.selectedScheme!.extra)!) : selectedStudent!.grades[box.week!-1]
        var arr_splitNum = splitNum.components(separatedBy: ",")
        if box.isOn == true
        {
            arr_splitNum[box.position!] = "1"
        }else
        {
            arr_splitNum[box.position!] = "0"
        }
        selectedStudent!.grades[box.week!-1] = arr_splitNum.joined(separator: ",")
        
    }
    
    @objc func tapDropdownAction(sender : DropDownButton){
    
        let dropDown = DropDown()
        dropDown.dataSource = sender.dropDownList!
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height) //6
        dropDown.show() //7
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in //8
            guard let _ = self else { return }
            sender.setTitle(item, for: .normal) //9
            //assign result to grade
            self!.selectedStudent!.grades[sender.week!-1] = item
        }
     
    }
    
    func getInitCheckBox(box_size:Int) ->String{
        var arr = Array<String>()
        for _ in 1...box_size
        {
            arr.append("0")
        }
        return arr.joined(separator: ",")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
