//
//  signInVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 07.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse


class signInVC: UIViewController {
    
    // textfield
    @IBOutlet weak var label: UILabel!
	@IBOutlet weak var signInLabel: UILabel!
	
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var passwordLabel: UILabel!
	
    // buttons
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
	
    var popupController: CNPPopupController?
    
	
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
			
			self.usernameTxt.alpha = 1
			self.passwordTxt.alpha = 1
			self.label.alpha = 1
			self.signInBtn.alpha = 1
			self.signUpBtn.alpha = 1
			self.forgotBtn.alpha = 1
			
			UIView.animate(withDuration: 0.8, animations: {

				
				self.usernameTxt.alpha = 0
				self.passwordTxt.alpha = 0
				self.label.alpha = 0
				self.signInBtn.alpha = 0
				self.signUpBtn.alpha = 0
				self.forgotBtn.alpha = 0
			})
			
		} else {
		
			self.usernameTxt.alpha = 0
			self.passwordTxt.alpha = 0
			self.label.alpha = 0
			self.signInBtn.alpha = 0
			self.signUpBtn.alpha = 0
			self.forgotBtn.alpha = 0
			
			UIView.animate(withDuration: 0.8, animations: {

				
				self.usernameTxt.alpha = 1
				self.passwordTxt.alpha = 1
				self.label.alpha = 1
				self.signInBtn.alpha = 1
				self.signUpBtn.alpha = 1
				self.forgotBtn.alpha = 1
			})
			
		}
	}
	
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pacifico font of label
        label.font = UIFont(name: "Pacifico", size: 25)
		
		
		
		usernameTxt.textAlignment = .center
		passwordTxt.textAlignment = .center
		usernameTxt.placeholder = ""
		passwordTxt.placeholder = ""
		
		signInLabel.frame.origin.y = self.signUpBtn.frame.origin.y + 20
		
		
        // alignment
        label.frame = CGRect(x: 10, y: 80, width: self.view.frame.size.width - 20, height: 50)
		
		usernameLabel.frame = CGRect(x: 10, y: label.frame.origin.y + 200, width: self.view.frame.size.width - 20, height: 45)
		usernameTxt.frame = CGRect(x: 10, y: usernameLabel.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 45)
		
		var spacer1 = UIButton(frame: CGRect(x: usernameTxt.frame.origin.x, y: usernameTxt.center.y + 20, width: usernameTxt.frame.size.width, height: 2))
		spacer1.backgroundColor = UIColor.lightGray
		self.view.addSubview(spacer1)
		
		
		passwordLabel.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 45)
        passwordTxt.frame = CGRect(x: 10, y: passwordLabel.frame.origin.y + 40, width: self.view.frame.size.width - 140, height: 45)
       	forgotBtn.frame = CGRect(x: self.view.frame.size.width - 120, y: passwordTxt.frame.origin.y, width: 120, height: 30)
		
		var spacer2 = UIButton(frame: CGRect(x: passwordTxt.frame.origin.x, y: passwordTxt.center.y + 20, width: self.view.frame.size.width - 20, height: 2))
		spacer2.backgroundColor = UIColor.lightGray
		self.view.addSubview(spacer2)
		
        signInBtn.frame = CGRect(x: self.view.frame.size.width / 6, y: forgotBtn.frame.origin.y + 60, width: self.view.frame.size.width / 1.5, height: 50)
		signInBtn.titleLabel?.textAlignment = .center
		
		signUpBtn.backgroundColor = UIColor.clear
		
        signUpBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: signInLabel.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        //signUpBtn.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
		
		
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(signInVC.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // background
        let bg = UIImageView(frame: CGRect(x: (self.view.frame.size.width / 2) - 75, y: self.view.frame.size.height / 7, width: 150, height: 150))
        bg.image = UIImage(named: "") //ADD LOGO IMAGE HERE
        bg.backgroundColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
		bg.layer.cornerRadius = bg.frame.size.width / 2;
		bg.clipsToBounds = true;
        self.view.addSubview(bg)
		
        let bgImage = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.height / 3))
        bgImage.image = UIImage(named: "bgImage.jpg")
        self.view.addSubview(bgImage)
        self.view.sendSubview(toBack: bgImage)
    }
    
    
    // hide keyboard func
    @objc func hideKeyboard(_ recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    // clicked sign in button
    @IBAction func signInBtn_click(_ sender: AnyObject) {
        print("sign in pressed")
        
        // hide keyboard
        self.view.endEditing(true)
        
        // if textfields are empty
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
            
            // show alert message
			
            self.showPopupWithStyle(.centered, titleText: "Invalid Input", bodyText: "Please fill in a username and password.")
        }
        
        // login functions
        PFUser.logInWithUsername(inBackground: usernameTxt.text!, password: passwordTxt.text!) { (user, error) -> Void in
            if error == nil {
                
                // remember user or save in App Memeory did the user login or not
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // call login function from AppDelegate.swift class
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            
            } else {
                
                // show alert message
				self.showPopupWithStyle(.centered, titleText: "Error", bodyText: (error?.localizedDescription)!)
            }
        }
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

extension signInVC : CNPPopupControllerDelegate {
	
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        //print("Popup controller will be dismissed")
    }
	
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        //print("Popup controller presented")
    }
	
}
