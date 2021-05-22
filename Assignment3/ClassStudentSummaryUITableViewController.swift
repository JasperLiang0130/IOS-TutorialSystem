//
//  ClassStudentSummaryUITableViewController.swift
//  Assignment3
//
//  Created by mobiledev on 22/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ClassStudentSummaryUITableViewController: UITableViewController {

    var selectedScheme: Scheme?
    var students = [StudentSummary]()
    var calculator = CalculatorForGrade()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        loadDB()
        
        //update navigation title
        self.navigationItem.title = "Week \(String(selectedScheme!.week)): \(transferTypeToWord(type: selectedScheme!.type, extra: selectedScheme!.extra))"
    }
    
    func loadDB(){
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
                
                self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassStudentSummaryUITableViewCell", for: indexPath)

        // Configure the cell...
        let student = students[indexPath.row]
        
        if let classStudentCell = cell as? ClassStudentSummaryUITableViewCell
        {
            let imgDecoded : Data = Data(base64Encoded: student.img, options: .ignoreUnknownCharacters)!
            let decodedImg = UIImage(data:imgDecoded)
            classStudentCell.displayImg.image = decodedImg
            classStudentCell.studentName.text = student.name
            classStudentCell.studentID.text = student.id
            classStudentCell.gradelabel.text = calculator.getStudentGradeSlash(student: student, scheme: selectedScheme!)
        }

        return cell
    }
    
    
    func transferTypeToWord(type:String, extra:String) ->String{
        switch type {
        case "attendance":
            return "ATTENDANCE"
        case "level_HD":
            return "HD-NN"
        case "level_A":
            return "A-F"
        case "score":
            return "Score of "+extra
        case "checkbox":
            return "CHECKBOX"
        default:
            return ""
        }
    }
    
    @IBAction func unwindToStudentMark(sender: UIStoryboardSegue)
    {
        if let markScreen = sender.source as? MarkStudentUIViewController
        {
            loadDB()
            NotificationCenter.default.post(name: Notification.Name("reloadDBFromMarking"), object: nil)
            
        }
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "MarkingStudentSegue"
        {
            guard let markingViewController = segue.destination as? MarkStudentUIViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedStudentCell = sender as? ClassStudentSummaryUITableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedStudentCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedStudent = students[indexPath.row]
            
            markingViewController.selectedScheme = selectedScheme
            markingViewController.selectedStudent = selectedStudent
        }
    }
    

}
