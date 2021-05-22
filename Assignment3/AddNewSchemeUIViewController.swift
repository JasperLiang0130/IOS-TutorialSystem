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
    var students = [StudentSummary]()
    
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
        let ext = (extraTextField.text! == "0") ? "" : String(Int(extraTextField.text!)!)
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
                    
                        do
                        {
                            //update students grade
                            for var s in self.students
                            {
                                s.grades.append("") //new scheme and give ""
                                
                                try db.collection("students").document(s.docId!).setData(from: s) {err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                }else {
                                    print("Document student successfully updated")
                                    }
                                }
                            }
                            self.performSegue(withIdentifier: "saveSchemeSegue", sender: sender)
                        } catch {
                            print("Error updating document \(error)")
                        } 
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
        
        let db = Firestore.firestore()
        let studentCollection = db.collection("students")
        studentCollection.getDocuments()
        { result, error in
                //check for server error
            if let err = error
            {
                print("Error getting document: \(err)")
            }
            else
            {
                //loop through the results
                self.students.removeAll()
                for document in result!.documents
                {
                    //attempt to convert to student object
                    let conversionResult = Result
                    {
                        try document.data(as: StudentSummary.self)
                    }
                    //check if conversionResult is success or failure
                    switch conversionResult
                    {
                    case .success(let convertedDoc):
                         if var student = convertedDoc
                         {
                            student.docId = document.documentID
                            //print("Student: \(student)")
                            
                            //assign to students
                            self.students.append(student)
                         }
                         else
                         {
                            print("Document does not exist")
                         }
                    case .failure(let error):
                        print("Error decoding student: \(error)")
                    }
                }
            }
        }
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
