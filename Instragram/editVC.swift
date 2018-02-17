//
//  editVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 14.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse


class editVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ENSideMenuDelegate {

    // UI objects
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var avaImg: UIImageView!
    
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
        // pickerView & pickerData
        var genderPicker : UIPickerView!
        let genders = ["male","female"]
	
	
	var popupController: CNPPopupController?
    
    // value to hold keyboard frmae size
    var keyboard = CGRect()
    
    
    func sideMenuWillOpen() {
		
	}
	
	func sideMenuWillClose() {
		
	}
	
	func sideMenuShouldOpenSideMenu() -> Bool {
		
		return true
	}
	
	func sideMenuDidOpen() {
		
	}
	
	func sideMenuDidClose() {
		
		
	}
	
	
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = "Edit Profile"
		
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 65, height: 20))
		button.addTarget(self, action: #selector(MyNavigationController.toggleSideMenuView), for: .touchUpInside)
		
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 65, height: 20))
		label.text = "Settings"
		label.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
	
		button.addSubview(label)
	
		let settingsItem = UIBarButtonItem(customView: button)
		settingsItem.target = self
		settingsItem.action = #selector(MyNavigationController.toggleSideMenuView)
		self.navigationItem.leftBarButtonItem = settingsItem
	
		let widthConstraint = button.widthAnchor.constraint(equalToConstant: 65)
		let heightConstraint = button.heightAnchor.constraint(equalToConstant: 20)
		heightConstraint.isActive = true
		widthConstraint.isActive = true
		
		self.sideMenuController()?.sideMenu?.delegate = self
	
		self.tabBarController?.tabBar.isHidden = false

        
        // create picker
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(editVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(editVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // tap to choose image
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(editVC.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)
        
        // call alignment function
        alignment()
        
        // call information function
        information()
    }
    
    
    // func to hide keyboard
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // func when keyboard is shown
    @objc func keyboardWillShow(_ notification: Notification) {
    
        // define keyboard frame size
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // move up with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.contentSize.height = self.view.frame.size.height + self.keyboard.height / 2
        }) 
    }
    
    
    // func when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {
        
        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.contentSize.height = 0
        }) 
    }
    
    
    // func to call UIImagePickerController
    @objc func loadImg (_ recognizer : UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    // method to finilize our actions with UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // alignment function
    func alignment() {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        avaImg.frame = CGRect(x: width - 68 - 10, y: 15, width: 68, height: 68)
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
        fullnameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y, width: width - avaImg.frame.size.width - 30, height: 30)
        usernameTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: width - avaImg.frame.size.width - 30, height: 30)
        webTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: width - 20, height: 30)
        
        bioTxt.frame = CGRect(x: 10, y: webTxt.frame.origin.y + 40, width: width - 20, height: 60)
        bioTxt.layer.borderWidth = 1
        bioTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).cgColor
        bioTxt.layer.cornerRadius = bioTxt.frame.size.width / 50
        bioTxt.clipsToBounds = true
        
        emailTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 100, width: width - 20, height: 30)
        telTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: width - 20, height: 30)
        genderTxt.frame = CGRect(x: 10, y: telTxt.frame.origin.y + 40, width: width - 20, height: 30)
        
        titleLbl.frame = CGRect(x: 15, y: emailTxt.frame.origin.y - 30, width: width - 20, height: 30)
    }
    
    
    // user information function
    func information() {
		
        if (PFUser.current()?.object(forKey: "ava") != nil) {
		
			// receive profile picture
			let ava = PFUser.current()?.object(forKey: "ava") as! PFFile
			ava.getDataInBackground { (data, error) -> Void in
				self.avaImg.image = UIImage(data: data!)
			}
        }
        
        // receive text information
        usernameTxt.text = PFUser.current()?.username
        fullnameTxt.text = PFUser.current()?.object(forKey: "fullname") as? String
        bioTxt.text = PFUser.current()?.object(forKey: "bio") as? String
        webTxt.text = PFUser.current()?.object(forKey: "web") as? String

        emailTxt.text = PFUser.current()?.email
        telTxt.text = PFUser.current()?.object(forKey: "tel") as? String
        genderTxt.text = PFUser.current()?.object(forKey: "gender") as? String
    }
    
    
    // regex restrictions for email textfield
    func validateEmail (_ email : String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // regex restrictions for web textfield
    func validateWeb (_ web : String) -> Bool {
        let regex = "www.+[A-Z0-9a-z._%+-]+.[A-Za-z]{2}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    
    // alert message function
    func alert (_ error: String, message : String) {
        
        self.showPopupWithStyle(.centered, titleText: error, bodyText: message)
    }
    
    
    // clicked save button
    @IBAction func save_clicked(_ sender: AnyObject) {
        
        // if incorrect email according to regex
        if !validateEmail(emailTxt.text!) {
            alert("Incorrect email", message: "please provide correct email address")
            return
        }
        
        // if incorrect weblink according to regex
        if !validateWeb(webTxt.text!) {
            alert("Incorrect web-link", message: "please provide correct website")
           return
        }
        
        // save filled in information
        let user = PFUser.current()!
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user["fullname"] = fullnameTxt.text?.lowercased()
        user["web"] = webTxt.text?.lowercased()
        user["bio"] = bioTxt.text
        
        // if "tel" is empty, send empty data, else entered data
        if telTxt.text!.isEmpty {
            user["tel"] = ""
        } else {
            user["tel"] = telTxt.text
        }
        
        // if "gender" is empty, send empty data, else entered data
        if genderTxt.text!.isEmpty {
            user["gender"] = ""
        } else {
            user["gender"] = genderTxt.text
        }
        
        // send profile picture
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        
        // send filled information to server
        user.saveInBackground (block: { (success, error) -> Void in
            if success{
                
                // hide keyboard
                self.view.endEditing(true)
                
                // dismiss editVC
                self.dismiss(animated: true, completion: nil)
                
                // send notification to homeVC to be reloaded
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    
    // clicked cancel button
    @IBAction func cancel_clicked(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // PICKER VIEW METHODS
    // picker comp numb
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // picker text numb
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    // picker text config
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    // picker did selected some value from it
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }
	
    //MARK:
	//MARK: Animation
	
	func showPopupWithStyle(_ popupStyle: CNPPopupStyle, titleText: String, bodyText: String) {
		
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.center
		
        let title = NSAttributedString(string: titleText, attributes: [NSAttributedStringKey.font:UIFont(name: "AvenirNext-Bold", size: 20)!, NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)])
        let description = NSAttributedString(string: bodyText, attributes: [NSAttributedStringKey.font:UIFont(name: "AvenirNext-Bold", size: 14)!, NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)])
		
		
        let button = CNPPopupButton.init(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 20)!
        button.setTitle("Okay", for: UIControlState())
		
        button.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
		
		
            self.popupController?.dismiss(animated: true)
        }
		
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title
		
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.attributedText = description;
		
        let popupController = CNPPopupController(contents:[titleLabel, descriptionLabel, button])
        popupController.theme = .default()
        popupController.theme.popupStyle = popupStyle
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
	}
}


extension editVC : CNPPopupControllerDelegate {
	
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        //print("Popup controller will be dismissed")
    }
	
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        //print("Popup controller presented")
    }
}

