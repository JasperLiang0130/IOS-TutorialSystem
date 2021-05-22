//
//  StudentSummaryUITableViewController.swift
//  Assignment3
//
//  Created by mobiledev on 14/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift


class StudentSummaryUITableViewController: UITableViewController {
    
    var students = [StudentSummary]()
    var schemes = [Scheme]()
    let calculator = CalculatorForGrade()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation item
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped)
        
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
                
                let schemeCollection = db.collection("schemes")
                schemeCollection.getDocuments()
                { result, error in
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
                                    //print("Scheme: \(scheme)")
                                    
                                    //assign to students
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
                        
                        self.tableView.reloadData()
                        
                        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDB(notification:)), name: Notification.Name("reloadDBToStudent"), object: nil)
                        
                    }
                }
            }
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
    }
    
    @objc func reloadDB(notification: Notification){
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
        
        let schemeCollection = db.collection("schemes")
        schemeCollection.getDocuments()
        { result, error in
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
                            //print("Scheme: \(scheme)")
                            
                            //assign to students
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
            }
        }
        
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return students.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentSummaryUITableViewCell", for: indexPath)

        // Configure the cell...
        let student = students[indexPath.row]
        
        //down-cast the cell from UITableViewCell to our cell class MovieUITableViewCell
        //note, this could fail, so we use an if let.
        if let studentCell = cell as? StudentSummaryUITableViewCell
        {
            //populate the cell
            studentCell.nameLabel.text = student.name
            studentCell.stuId.text = String(student.id)
            let imgDecoded : Data = Data(base64Encoded: student.img, options: .ignoreUnknownCharacters)!
            let decodedImg = UIImage(data:imgDecoded)
            studentCell.imgView.image = decodedImg
            studentCell.gradeLabel.text = calculator.getStudentAvgGrade(grades: student.grades, schemes: schemes) + "%"
        }
        
        return cell
    }
    
    @IBAction func unwindToStudentListWithCancel(sender: UIStoryboardSegue)
    {
    }
    
    @IBAction func unwindToStudentList(sender: UIStoryboardSegue)
    {
        viewDidLoad()
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

    @objc func addTapped(){
        print("add a new student form coming...")
        addNewStudentForm()
    }
    
    func addNewStudentForm(){
        
        var stuName:UITextField!
        var stuID:UITextField!
        
        let alert = UIAlertController(title:"", message: "Add a new student", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:"Cancel", style: .cancel)
        let submitAction = UIAlertAction(title:"OK", style: .default)
        {
            (action) -> Void in
            //to action
            print("name: \(stuName.text!)")
            print("stu id: \(stuID.text!)")
        }
        
        let cameraAction = UIAlertAction(title:"Camera", style:.default, handler: {action in self.capturePhoto()})
        
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
      
        
        //custom text field
        alert.addTextField(configurationHandler: {
            (textField:UITextField!) in
            textField.placeholder = "Name"
            stuName = textField
            
        })
        alert.addTextField(configurationHandler: {
            (textField:UITextField!) in
            textField.placeholder = "Student ID"
            stuID = textField
        })
        
        //has to refresh all data
        self.present(alert, animated: true, completion: nil)
    }
    
    func capturePhoto(){
        let alert = UIAlertController(title:"Capture Photo", message: "", preferredStyle: .alert)
        
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    //passing the data
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "addNewStudentSegue"
        {
            guard let addNewStudentViewController = segue.destination as? AddNewStudentUIViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            addNewStudentViewController.schemesSize = schemes.count
        }else if segue.identifier == "studentDetailSegue"
        {
            guard let studentDetailController = segue.destination as? StudentDetailUIViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedStudentCell = sender as? StudentSummaryUITableViewCell else
            {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedStudentCell) else
            {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedStudent = students[indexPath.row]
            studentDetailController.avgPassGrade = calculator.getStudentAvgGrade(grades: selectedStudent.grades, schemes: self.schemes) + "%"
            studentDetailController.selectedStudent = selectedStudent
            
        }
        
    }
    
    
}

