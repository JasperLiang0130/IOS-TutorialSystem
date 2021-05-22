//
//  StudentDetailUIViewController.swift
//  Assignment3
//
//  Created by mobiledev on 19/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import DropDown

class StudentDetailUIViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    var selectedStudent : StudentSummary?
    var avgPassGrade : String?
    
    @IBOutlet var nameText: UITextField!
    @IBOutlet var stuIdText: UITextField!
    @IBOutlet var displayImg: UIImageView!
    @IBOutlet var avgGrade: UILabel!
    @IBOutlet var cameraBtn: UIButton!
    @IBOutlet var galleryBtn: UIButton!
    @IBOutlet var delete: UIButton!
    @IBOutlet var gradeView: UIScrollView!
    
    var schemes = [Scheme]()
    let level_HD = ["HD+", "HD", "DN", "CR", "PP", "NN"]
    let level_A = ["A", "B", "C", "D", "F"]
    let attendance = ["Attend", "Absent"]
    let calculator = CalculatorForGrade()
    var grades:Array<String>? = nil

    @IBAction func deleteAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Alert", message: "Are you sure for deleting student \(nameText.text!)?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in self.deleteAction() }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
        
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        var share_arr = Array<String>()
        for i in 0...(schemes.count-1)
        {
            switch schemes[i].type {
            case "level_HD":
                if grades![i] == ""
                {
                    share_arr.append("Week \(String(i+1)): \(level_HD.last!)")
                }else{
                    share_arr.append("Week \(String(i+1)): \(grades![i])")
                }
            case "level_A":
                if grades![i] == ""
                {
                    share_arr.append("Week \(String(i+1)): \(level_A.last!)")
                }else{
                    share_arr.append("Week \(String(i+1)): \(grades![i])")
                }
            case "attendance":
                if grades![i] == ""
                {
                    share_arr.append("Week \(String(i+1)): \(attendance.last!)")
                }else{
                    share_arr.append("Week \(String(i+1)): \(grades![i])")
                }
            case "score":
                if grades![i] == ""
                {
                    share_arr.append("Week \(String(i+1)): 0/\(schemes[i].extra)")
                }else{
                    share_arr.append("Week \(String(i+1)): \(grades![i])/\(schemes[i].extra)")
                }
            case "checkbox":
                if grades![i] == ""
                {
                    share_arr.append("Week \(String(i+1)): 0/\(String(schemes[i].extra))")
                }else{
                    share_arr.append("Week \(String(i+1)): \(calculator.transferCheckBoxSlash(s: grades![i]))")
                }
            default:
                break
            }
        }
        let shareViewController = UIActivityViewController(activityItems: ["Student Name:\(selectedStudent!.name), Student id: \(selectedStudent!.id), All weeks grades: \(share_arr.joined(separator: ", ")), Summary grade: \(avgGrade.text!)"], applicationActivities: [])
        present(shareViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        sender.title = "Loading..."
        
        if nameText.text! == "" || stuIdText.text! == ""
        {
           print("input is empty")
           showToast(controller: self, message: "Input is not allowed empty", seconds: 2)
        }
        else{
            let db = Firestore.firestore()
            let imageBase64String = resizeImage(image: displayImg.image!, newWidth: 180).pngData()!.base64EncodedString(options: .lineLength64Characters)
            selectedStudent?.name = nameText.text!
            selectedStudent?.id = stuIdText.text!
            selectedStudent?.img = imageBase64String
            selectedStudent?.grades = self.grades!
            do
            {
                try db.collection("students").document(selectedStudent!.docId!).setData(from: selectedStudent!) {err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    }else {
                        print("Document successfully updated")
                        self.performSegue(withIdentifier: "saveStudentSegue", sender: sender)
                    }
                }
            } catch {
                print("Error updating document \(error)")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //showing student detail
        nameText.text = selectedStudent!.name
        stuIdText.text = selectedStudent!.id
        let imgDecoded : Data = Data(base64Encoded: selectedStudent!.img, options: .ignoreUnknownCharacters)!
        let decodedImg = UIImage(data:imgDecoded)
        displayImg.image = decodedImg
        avgGrade.text = avgPassGrade
        
        grades = selectedStudent!.grades
        
        let db = Firestore.firestore()
        let schemeCollection = db.collection("schemes").order(by: "week")
        schemeCollection.getDocuments()
        { [self] result, error in
                //check for server error
            if let err = error
            {
                print("Error getting document: \(err)")
            }
            else
            {
                //loop through the results
                self.schemes.removeAll()
                for document in result!.documents
                {
                    //attempt to convert to student object
                    let conversionResult = Result
                    {
                        try document.data(as: Scheme.self)
                    }
                    //check if conversionResult is success or failure
                    switch conversionResult
                    {
                    case .success(let convertedDoc):
                         if var scheme = convertedDoc
                         {
                            scheme.docId = document.documentID
                            print("Scheme: \(scheme)")
                            
                            //assign to schemes
                            self.schemes.append(scheme)
                         }
                         else
                         {
                            print("Document does not exist")
                         }
                    case .failure(let error):
                        print("Error decoding scheme: \(error)")
                    }
                }
                
                //assign dynamic ui view
                let contentView = vStack()
                
                if self.schemes.count == 0
                {
                    print("There is no tutorial!!!")
                }else{
                    for index in 1...(schemes.count)
                    {
                        if self.schemes[index-1].type == "level_HD"
                        {
                            let choose = (grades![index-1] == "") ? level_HD.last : grades![index-1]
                            contentView.addArrangedSubview(hStack(views: buildLabelView(word: "Week "+String(index), bgColor: .white), buildLabelView(word: transferTypeToWord(type: schemes[index-1].type, extra: schemes[index-1].extra), bgColor: .white), buildDropDown(data: level_HD, selected: choose!, week: schemes[index-1].week, bgcolor: UIColor.yellow)))
                            
                        }else if self.schemes[index-1].type == "level_A"
                        {
                            let choose = (grades![index-1] == "") ? level_A.last : grades![index-1]
                            contentView.addArrangedSubview(hStack(views: buildLabelView(word: "Week "+String(index), bgColor: .white), buildLabelView(word: transferTypeToWord(type: schemes[index-1].type, extra: schemes[index-1].extra), bgColor: .white), buildDropDown(data: level_A, selected: choose!, week: schemes[index-1].week, bgcolor: UIColor.yellow)))
                            
                        }else if schemes[index-1].type == "checkbox"
                        {
                            let choose = (grades![index-1] == "") ? getInitCheckBox(box_size: Int(schemes[index-1].extra)!) : grades![index-1]
                            contentView.addArrangedSubview(hStack(views: buildLabelView(word: "Week "+String(index), bgColor: .white), buildLabelView(word: transferTypeToWord(type: schemes[index-1].type, extra: schemes[index-1].extra), bgColor: .white), buildCheckBoxes(boxes: choose, week: schemes[index-1].week)))
                            
                        }else if schemes[index-1].type == "score"
                        {
                            let choose = (grades![index-1] == "") ? "0" : grades![index-1]
                            contentView.addArrangedSubview(hStack(views: buildLabelView(word: "Week "+String(index), bgColor: .white), buildLabelView(word: transferTypeToWord(type: schemes[index-1].type, extra: schemes[index-1].extra), bgColor: .white), buildNumTextField(word: choose, placeholder: "Only Number", week: schemes[index-1].week, extra: Int(schemes[index-1].extra)!, bgColor: UIColor.yellow)))
                            
                        }else if schemes[index-1].type == "attendance"
                        {
                            let choose = (grades![index-1] == "") ? attendance.last : grades![index-1]
                            contentView.addArrangedSubview(hStack(views: buildLabelView(word: "Week "+String(index), bgColor: .white), buildLabelView(word: transferTypeToWord(type: schemes[index-1].type, extra: schemes[index-1].extra), bgColor: .white), buildDropDown(data: attendance, selected: choose!, week: schemes[index-1].week, bgcolor: UIColor.yellow)))
                        }
                    }        }
                
                gradeView.addSubview(contentView)
                
                NSLayoutConstraint.activate([
                    gradeView.leadingAnchor.constraint(equalTo: gradeView.leadingAnchor),
                    gradeView.trailingAnchor.constraint(equalTo: gradeView.trailingAnchor),
                    gradeView.topAnchor.constraint(equalTo: gradeView.topAnchor),
                    gradeView.bottomAnchor.constraint(equalTo: gradeView.bottomAnchor, constant: 0.0),
                    gradeView.heightAnchor.constraint(equalToConstant: 540),
                    gradeView.widthAnchor.constraint(equalToConstant: 350),
                    
                    contentView.leadingAnchor.constraint(equalTo: gradeView.leadingAnchor),
                    contentView.trailingAnchor.constraint(lessThanOrEqualTo: gradeView.trailingAnchor),
                    contentView.topAnchor.constraint(equalTo: gradeView.topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: gradeView.bottomAnchor)
                ])
            }
        }
    }
    
    func deleteAction(){
        let db = Firestore.firestore()
        db.collection("students").document(selectedStudent!.docId!).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.performSegue(withIdentifier: "saveStudentSegue", sender: UIBarButtonItem.self)
            }
        }
        
    }
    
    @IBAction func galleryButtonTapped(_ sender: UIButton)
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            print("Gallery available")
            
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        {
            print("Camera available")
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            print("No camera available")
            showToast(controller: self, message: "No camera available.", seconds: 2)
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            displayImg.image = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func getInitCheckBox(box_size:Int) ->String{
        var arr = Array<String>()
        for _ in 1...box_size
        {
            arr.append("0")
        }
        return arr.joined(separator: ",")
    }
    
    func transferTypeToWord(type:String, extra:String) ->String{
        switch type {
        case "attendance":
            return "ATTENDANCE"
        case "level_HD":
            return "HD+/HD/DN/CR/PP/NN"
        case "level_A":
            return "A/B/C/D/F"
        case "score":
            return "Score of "+extra
        case "checkbox":
            return "CHECKBOX"
        default:
            return ""
        }
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
            txt.text = ""
            return
        }else if Int(txt.text!)! > txt.extra!
        {
            txt.text = String(txt.extra!)
        }else if Int(txt.text!)! < 0
        {
            txt.text = "0"
            //add 0 to grade
            
        }
        grades![txt.week!-1] = txt.text!
        avgGrade.text = calculator.getStudentAvgGrade(grades: grades!, schemes: schemes) + "%"

    }
    
    @objc func tapCheckBox(sender: CheckBox){
        let box = (sender as CheckBox)
        print("week: \(box.week!), position: \(box.position!)")
        //assign result to grade
        let splitNum = (grades![box.week!-1] == "") ? self.getInitCheckBox(box_size: Int(self.schemes[box.week!-1].extra)!) : grades![box.week!-1]
        var arr_splitNum = splitNum.components(separatedBy: ",")
        if box.isOn == true
        {
            arr_splitNum[box.position!] = "1"
        }else
        {
            arr_splitNum[box.position!] = "0"
        }
        grades![box.week!-1] = arr_splitNum.joined(separator: ",")
        avgGrade.text = calculator.getStudentAvgGrade(grades: grades!, schemes: schemes) + "%"
        
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
            self!.grades![sender.week!-1] = item
            self!.avgGrade.text = self!.calculator.getStudentAvgGrade(grades: self!.grades!, schemes: self!.schemes) + "%"
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
