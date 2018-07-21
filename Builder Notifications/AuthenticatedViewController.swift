//
//  AuthenticatedViewController.swift
//  Builder Notifications
//
//  Created by Gary Baker on 3/07/18.
//  Copyright © 2018 Gary Baker. All rights reserved.
//


import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class AuthenticatedViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = notificationList[indexPath.row]
        return cell
    }
    
    @IBOutlet weak var jobsite: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var NewTxtEmail: UITextField!
    

    @IBOutlet weak var pickerUpdateTextField: UITextField!
    @IBOutlet weak var lblUpdateEmailStatus: UILabel!
    @IBOutlet weak var pickerTextField: UITextField?
    @IBOutlet weak var locationTextField: UITextField?
    @IBOutlet weak var  post: UITextField?
    @IBOutlet weak var  location: UITextField?
 

    var handle = DatabaseHandle()
    var notificationHandler = DatabaseHandle()
    var pickOption = [String]()
    var notificationList = [String]()
    
    @IBAction func UpdateEmail(_ sender: Any) {
        let user = Auth.auth().currentUser
        user?.updateEmail(to: NewTxtEmail.text!) { error in
            if error != nil {
                self.lblUpdateEmailStatus.text = "Error"
            } else {
                self.lblUpdateEmailStatus.text = "Email updated."
            }
        }
    }

    
    @IBAction func UpdateLocation(_ sender: Any) {
        let jobsite: String = self.jobsite!.text!
        
        let userID = Auth.auth().currentUser!.uid
        Database.database().reference().child("users").child(userID).child("Job Site").setValue([jobsite])
        
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                if error != nil{
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }else {
                    let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
            })
        }))
        //PRESENT ALERT
        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }
    
    @IBAction func sendPost(sender: UIButton) {
        let post: String = self.post!.text!
        _ = Auth.auth().currentUser!.uid
        _ = Auth.auth().currentUser!.displayName
        Database.database().reference().child("notifications").childByAutoId().setValue(["post": post])
        
        
        Messaging.messaging().sendMessage(["body" : "messageData"], to: "184904612529@gcm.googleapis.com", withMessageID: "messageId", timeToLive: 200)
    }
 
    @IBAction func authLogout(sender: UIButton) {
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error while signing out!")
        }
    }
  
    @IBAction func addLocation(sender: UIButton) {
        let location: String = self.location!.text!
        Database.database().reference().child("locations").childByAutoId().setValue(["location": location])
    }
    
    @IBAction func removeLocation(sender: UIButton) {
        var ref = Database.database().reference().child("locations").childByAutoId();
        
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        self.pickerTextField?.inputView = pickerView
        self.pickerUpdateTextField?.inputView = pickerView
        
        let toolbar = UIToolbar(frame: CGRect(x:0,y: 0,width:self.view.frame.size.width, height:40))
        toolbar.barStyle = UIBarStyle.blackTranslucent
        toolbar.tintColor = UIColor.white
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(ViewController.donePressed(sender:)))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0,y: 0, width:self.view.frame.size.width/3, height: 40))
        
        label.font = UIFont.systemFont(ofSize: 14)
        
        label.textColor = UIColor.yellow
        
        label.textAlignment = NSTextAlignment.center
        
        label.text = "Jobsite"
        
        let labelButton = UIBarButtonItem(customView: label)
        
        toolbar.setItems([flexButton, flexButton, labelButton, flexButton, doneButton], animated:true)
        pickerUpdateTextField?.inputAccessoryView = toolbar
        pickerTextField?.inputAccessoryView = toolbar
        let ref = Database.database().reference()
        
        let tableView = UITableView()
        tableView.delegate = self
        
        notificationHandler = ref.child("notifications").observe(.childAdded) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot {
                    if let data = snap.value as? String {
                        self.notificationList.append(data)
                    }
                }
            }
        }
        
        handle = ref.child("locations").observe(.childAdded) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot {
                    if let data = snap.value as? String {
                        self.pickOption.append(data)
                    }
                }
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField?.text = pickOption[row]
        pickerUpdateTextField?.text = pickOption[row]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func donePressed(sender: UIBarButtonItem) {
        pickerTextField?.resignFirstResponder()
        pickerUpdateTextField?.resignFirstResponder()
    }
}
