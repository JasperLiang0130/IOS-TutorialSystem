//
//  AddNewStudentUIViewController.swift
//  Assignment3
//
//  Created by mobiledev on 18/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class AddNewStudentUIViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    @IBOutlet var displayImg: UIImageView!
    
    @IBOutlet var stuIDTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    
    var schemesSize : Int? //get it from student summary

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onSave(_ sender: Any)
    {
        
        if nameTextField.text! == "" || stuIDTextField.text! == ""
        {
           print("input is empty")
           showToast(controller: self, message: "Input is not allowed empty", seconds: 2)
        }
        else{
            var gds = Array<String>()
            for index in 1...schemesSize!
            {
                gds.append("")
            }
            let man = UIImage(named: "default-man")
            
            if (displayImg.image!.isSymbolImage)
            {
                print("student img is nil")
                displayImg.image = man
            }
            print("origin img size: \(displayImg.image!.size)")
            print("after img resize: \(resizeImage(image: displayImg.image!, newWidth: 170).size)")
            let imageBase64String = resizeImage(image: displayImg.image!, newWidth: 180).pngData()!.base64EncodedString(options: .lineLength64Characters)
            let newStudent = StudentSummary(docId: nil, name: nameTextField.text!, pk: "", id: stuIDTextField.text!, grades: gds, img: imageBase64String)
            
            let db = Firestore.firestore()
            let studentCollection = db.collection("students")
            do
            {
                try studentCollection.addDocument(from: newStudent, completion: { (err) in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                    else
                    {
                        print("Successfully created student")
                        
                        self.performSegue(withIdentifier: "saveStudentSegue", sender: sender)
                        
                    }
                })
            }catch let error {
                print("Error writing student to firestore: \(error)")
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
}
