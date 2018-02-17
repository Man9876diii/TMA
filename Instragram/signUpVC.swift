//
//  signUpVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 07.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse


class signUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // profile image
    @IBOutlet weak var avaImg: UIImageView!
    
    // textfields
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    
    // buttons
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    // scrollView
    @IBOutlet weak var scrollView: UIScrollView!
    
    // reset default size
    var scrollViewHeight : CGFloat = 0
    
    // keyboard frame size
    var keyboard = CGRect()
	
    var popupController: CNPPopupController?
	
	@IBOutlet weak var rulesLabel: UILabel!
	
    override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
	
		animateViews(out: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
	
		super.viewWillDisappear(animated)
	
		
		animateViews(out: true)
	}
	
	func animateViews(out: Bool) {
		
		if out == true {
			
			self.avaImg.alpha = 1
			self.usernameTxt.alpha = 1
			self.passwordTxt.alpha = 1
			self.repeatPassword.alpha = 1
			self.emailTxt.alpha = 1
			self.fullnameTxt.alpha = 1
			self.bioTxt.alpha = 1
			self.webTxt.alpha = 1
			self.cancelBtn.alpha = 1
			self.signUpBtn.alpha = 1
			self.rulesLabel.alpha = 1
			
			UIView.animate(withDuration: 0.8, animations: {

				
				self.avaImg.alpha = 0
				self.usernameTxt.alpha = 0
				self.passwordTxt.alpha = 0
				self.repeatPassword.alpha = 0
				self.emailTxt.alpha = 0
				self.fullnameTxt.alpha = 0
				self.bioTxt.alpha = 0
				self.webTxt.alpha = 0
				self.cancelBtn.alpha = 0
				self.signUpBtn.alpha = 0
				self.rulesLabel.alpha = 0
			})
			
		} else {
		
			self.avaImg.alpha = 0
			self.usernameTxt.alpha = 0
			self.passwordTxt.alpha = 0
			self.repeatPassword.alpha = 0
			self.emailTxt.alpha = 0
			self.fullnameTxt.alpha = 0
			self.bioTxt.alpha = 0
			self.webTxt.alpha = 0
			self.cancelBtn.alpha = 0
			self.signUpBtn.alpha = 0
			self.rulesLabel.alpha = 0
		
			UIView.animate(withDuration: 0.8, animations: {

				
				self.avaImg.alpha = 1
				self.usernameTxt.alpha = 1
				self.passwordTxt.alpha = 1
				self.repeatPassword.alpha = 1
				self.emailTxt.alpha = 1
				self.fullnameTxt.alpha = 1
				self.bioTxt.alpha = 1
				self.webTxt.alpha = 1
				self.cancelBtn.alpha = 1
				self.signUpBtn.alpha = 1
				self.rulesLabel.alpha = 1
			})
			
		}
	}
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
        // scrollview frame size
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        // check notifications if keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(signUpVC.showKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signUpVC.hideKeybard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // declare hide kyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(signUpVC.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
        // declare select image tap
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(signUpVC.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)
		
		bioTxt.isHidden = true
		webTxt.isHidden = true
		
		
        // alignment
        avaImg.frame = CGRect(x: self.view.frame.size.width / 2 - 40, y: 40, width: 80, height: 80)
        usernameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y + 90, width: self.view.frame.size.width - 20, height: 45)
		
		fullnameTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 50, width: self.view.frame.size.width - 20, height: 45)
        emailTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 50, width: self.view.frame.size.width - 20, height: 45)
		passwordTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 50, width: self.view.frame.size.width - 20, height: 45)
        repeatPassword.frame = CGRect(x: 10, y: passwordTxt.frame.origin.y + 50, width: self.view.frame.size.width - 20, height: 45)
        bioTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 50, width: self.view.frame.size.width - 20, height: 30)
        webTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 50, width: self.view.frame.size.width - 20, height: 30)
		
		
        signUpBtn.frame = CGRect(x: self.view.frame.size.width / 10, y: repeatPassword.frame.origin.y + 100, width: self.view.frame.size.width / 1.2, height: 50)
       
		
		rulesLabel.text = "By signing up, you agree to the terms and conditions and privacy policy."
		rulesLabel.textAlignment = .center
		rulesLabel.numberOfLines = 0
		rulesLabel.frame = CGRect(x: self.view.frame.size.width / 10, y: signUpBtn.frame.origin.y + 55, width: self.view.frame.size.width / 1.2, height: 50)
		
        //signUpBtn.layer.cornerRadius = signUpBtn.frame.size.width / 20
        
        cancelBtn.frame = CGRect(x: 10, y: 20, width: self.view.frame.size.width / 4, height: 30)
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.width / 20
        
        // background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        //self.view.addSubview(bg)
		
        var spacer1 = UIButton(frame: CGRect(x: usernameTxt.frame.origin.x, y: usernameTxt.center.y + 20, width: usernameTxt.frame.size.width, height: 2))
		spacer1.backgroundColor = UIColor.lightGray
		self.view.addSubview(spacer1)
		
		var spacer2 = UIButton(frame: CGRect(x: fullnameTxt.frame.origin.x, y: fullnameTxt.center.y + 20, width: fullnameTxt.frame.size.width, height: 2))
		spacer2.backgroundColor = UIColor.lightGray
		self.view.addSubview(spacer2)
		
		var spacer3 = UIButton(frame: CGRect(x: emailTxt.frame.origin.x, y: emailTxt.center.y + 20, width: emailTxt.frame.size.width, height: 2))
		spacer3.backgroundColor = UIColor.lightGray
		self.view.addSubview(spacer3)
		
		var spacer4 = UIButton(frame: CGRect(x: passwordTxt.frame.origin.x, y: passwordTxt.center.y + 20, width: passwordTxt.frame.size.width, height: 2))
		spacer4.backgroundColor = UIColor.lightGray
		self.view.addSubview(spacer4)
		
		var spacer5 = UIButton(frame: CGRect(x: repeatPassword.frame.origin.x, y: repeatPassword.center.y + 20, width: repeatPassword.frame.size.width, height: 2))
		spacer5.backgroundColor = UIColor.lightGray
		self.view.addSubview(spacer5)
		
		
    }
    
    
    // call picker to select image
    @objc func loadImg(_ recognizer:UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    // connect selected image to our ImageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // hide keyboard if tapped
    @objc func hideKeyboardTap(_ recoginizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    // show keyboard
    @objc func showKeyboard(_ notification:Notification) {
        
        // define keyboard size
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // move up UI
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.height
        }) 
    }
    
    
    // hide keyboard func
    @objc func hideKeybard(_ notification:Notification) {
        
        // move down UI
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.frame.size.height = self.view.frame.height
        }) 
    }
    
    
    
    // clicked sign up
    @IBAction func signUpBtn_click(_ sender: AnyObject) {
        print("sign up pressed")
        
        // dismiss keyboard
        self.view.endEditing(true)
        
        // if fields are empty
        if (usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPassword.text!.isEmpty || emailTxt.text!.isEmpty || fullnameTxt.text!.isEmpty) {
            
            // alert message
            self.showPopupWithStyle(.centered, titleText: "Error", bodyText: "Please fill in all fields.")
            
            return
        }
        
        // if different passwords
        if passwordTxt.text != repeatPassword.text {
            
            self.showPopupWithStyle(.centered, titleText: "Error", bodyText: "Passwords do not match.")
            return
        }
        
        
        // send data to server to related collumns
        let user = PFUser()
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user.password = passwordTxt.text
        user["fullname"] = fullnameTxt.text?.lowercased()
        user["bio"] = bioTxt.text
        user["web"] = webTxt.text?.lowercased()

        // in Edit Profile it's gonna be assigned
        user["tel"] = ""
        user["gender"] = ""
        user["blockedUsers"] = []
        
        // convert our image for sending to server
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        
        // save data in server
        user.signUpInBackground { (success, error) -> Void in
            if success {
                print("registered")
                
                // remember looged user
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // call login func from AppDelegate.swift class
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
            } else {

                // show alert message
				self.showPopupWithStyle(.centered, titleText: "Error", bodyText: (error?.localizedDescription)!)
            }
        }
    }
    
    
    // clicked cancel
    @IBAction func cancelBtn_click(_ sender: AnyObject) {
        
        // hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
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

extension signUpVC : CNPPopupControllerDelegate {
	
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        //print("Popup controller will be dismissed")
    }
	
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        //print("Popup controller presented")
    }
}
