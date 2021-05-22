//
//  AddNewSchemeUIViewController.swift
//  Assignment3
//
//  Created by mobiledev on 22/5/21.
//

import UIKit
import DropDown
import Firebase
import FirebaseFirestoreSwift

class AddNewSchemeUIViewController: UIViewController {

    let schesmeList = ["Attendance", "Grade(HD-PP)", "Grade(A-F)", "Score of X", "CheckBox"]
    @IBOutlet var weekLabel: UILabel!
    
    @IBOutlet var dropDownBtn: UIButton!
    @IBAction func dropDownButton(_ sender: UIButton) {
        let dropDown = DropDown()
        dropDown.dataSource = schesmeList
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height) //6
        dropDown.show() //7
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in //8
            guard let _ = self else { return }
            sender.setTitle(item, for: .normal) //9
            //assign result
            if item == "Score of X"
            {
                self!.extraLabel.isHidden = false
                self!.extraTextField.isHidden = false
                self!.extraLabel.text = "    X :"
            }else if item == "CheckBox"
            {
                self!.extraLabel.isHidden = false
                self!.extraTextField.isHidden = false
                self!.extraLabel.text = "Box num:"
            }else
            {
                self!.extraLabel.isHidden = true
                self!.extraTextField.isHidden = true
            }
        }
    }
    
    @IBOutlet var extraLabel: UILabel!
    
    @IBOutlet var extraTextField: NumTextField!
    @IBAction func extraTextField(_ sender: NumTextField) {
        print("typing... \(sender.text!)")
        if sender.text == ""
        {
            extraTextField.text = "0"
        }
    }
    
    var newSchemeWeek:Int?
    
    @IBAction func onSaveNewScheme(_ sender: Any) {
        (sender as! UIBarButtonItem).title = "Loading..."
        
        
        
        if dropDownBtn.currentTitle == "Score of X" || dropDownBtn.currentTitle == "CheckBox"
        {
            let msg = (dropDownBtn.currentTitle == "Score of X") ? "X cannot be ZERO.":"Box num cannot be ZERO."
            if extraTextField.text == "0"
            {
                showToast(controller: self, message: msg, seconds: 1.5)
                return
            }
        }
        let ext = (extraTextField.text! == "0") ? "" : extraTextField.text!
        let newScheme = Scheme(docId: nil, pk: "", week: newSchemeWeek!, type: transferSchemeTypeDBtype(s: dropDownBtn.currentTitle!), extra: ext)
        
        let db = Firestore.firestore()
        let schemeCollection = db.collection("schemes")
        do
        {
            try schemeCollection.addDocument(from: newScheme, completion: { (err) in
                if let err = err {
                    print("Error adding document: \(err)")
                }
                else
                {
                    print("Successfully created scheme")
                    
                    //update students grade
                    
                    self.performSegue(withIdentifier: "saveSchemeSegue", sender: sender)
                    
                }
            })
        }catch let error {
            print("Error writing scheme to firestore: \(error)")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dropDownBtn.setTitle(schesmeList.first, for: .normal)
        extraTextField.setBottomBorder(_bgColor: UIColor.white)
        extraTextField.textAlignment = .center
        extraTextField.text = "0"
        extraLabel.isHidden = true
        extraTextField.isHidden = true
        weekLabel.text = "Week: \(String(newSchemeWeek!))"
    }
    
    private func transferSchemeTypeDBtype(s:String) ->String{
        switch s {
        case "Attendance":
            return "attendance"
        case "Grade(HD-PP)":
            return "level_HD"
        case "Grade(A-F)":
            return "level_A"
        case "Score of X":
            return "score"
        case "CheckBox":
            return "checkbox"
        default:
            return ""
        }
    }
    
    func showToast(controller: UIViewController, message: String, seconds: Double){
        let alert = UIAlertController(title:nil, message:message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.9
        alert.view.layer.cornerRadius = 15
        controller.present(alert, animated:true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds){
            alert.dismiss(animated: true)
        }
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
