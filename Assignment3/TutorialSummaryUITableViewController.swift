//
//  TutorialSummaryUITableViewController.swift
//  Assignment3
//
//  Created by mobiledev on 22/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class TutorialSummaryUITableViewController: UITableViewController {

    var schemes = [Scheme]()
    var students = [StudentSummary]()
    var calculator = CalculatorForGrade()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        let schemeCollection = db.collection("schemes").order(by: "week")
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return schemes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TutorialSummaryUITableViewCell", for: indexPath)

        // Configure the cell...
        let scheme = schemes[indexPath.row]
        
        if let schemeCell = cell as? TutorialSummaryUITableViewCell
        {
            schemeCell.weekLabel.text = "Week \(String(scheme.week))"
            switch scheme.type {
                case "level_HD":
                    schemeCell.schemeTypeLabel.text = "Grade of level"
                    schemeCell.schameTypeDetailLabel.text = "(HD+/HD/DN/CR/PP/NN)"
                case "level_A":
                    schemeCell.schemeTypeLabel.text = "Grade of level"
                    schemeCell.schameTypeDetailLabel.text = "(A/B/C/D/F)"
                case "attendance":
                    schemeCell.schemeTypeLabel.text = "Attendance"
                    schemeCell.schameTypeDetailLabel.text = "(Attend/Absent)"
                case "score":
                    schemeCell.schemeTypeLabel.text = "Score of \(scheme.extra)"
                    schemeCell.schameTypeDetailLabel.text = "Total mark: \(scheme.extra)"
                case "checkbox":
                    schemeCell.schemeTypeLabel.text = "CheckBoxes of \(scheme.extra)"
                    schemeCell.schameTypeDetailLabel.text = "Total boxes: \(scheme.extra)"
                default:
                    schemeCell.schemeTypeLabel.text = "N/A"
                    schemeCell.schameTypeDetailLabel.text = "N/A"
            }
            schemeCell.gradeLabel.text = calculator.getClassAvgGrade(students: students, scheme: scheme)
            
        }
        

        return cell
    }
    
    @IBAction func unwindToTutorialList(sender: UIStoryboardSegue)
    {
        if let newSchemeScreen = sender.source as? AddNewSchemeUIViewController
        {
            viewDidLoad()
        }
    }

    @IBAction func unwindToTutorialListWithCancel(sender: UIStoryboardSegue)
    {
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
        if segue.identifier == "ClassStudentSummarySegue"
        {
            guard let classStudentViewController = segue.destination as? ClassStudentSummaryUITableViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedSchemeCell = sender as? TutorialSummaryUITableViewCell else
            {
                fatalError("Unexpected sender: \( String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedSchemeCell) else
            {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedScheme = schemes[indexPath.row]
            
            //send scheme to class student summary
            classStudentViewController.selectedScheme = selectedScheme
        } else if segue.identifier == "AddNewSchemeSegue"
        {
            guard let addNewSchemeViewController = segue.destination as? AddNewSchemeUIViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            addNewSchemeViewController.newSchemeWeek = schemes.count+1
        }
        
    }
    

}
