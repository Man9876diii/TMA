//
//  resetPasswordVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 07.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse


class resetPasswordVC: UIViewController {

    // textfield
    @IBOutlet weak var emailTxt: UITextField!
    
    // buttons
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
	
	
	@IBOutlet weak var emailLabel: UILabel!
	
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
			
			self.resetBtn.alpha = 1
			self.emailTxt.alpha = 1
			self.cancelBtn.alpha = 1
			self.emailLabel.alpha = 1
			
			UIView.animate(withDuration: 0.8, animations: {

				
				self.resetBtn.alpha = 0
				self.emailTxt.alpha = 0
				self.cancelBtn.alpha = 0
				self.emailLabel.alpha = 0
			})
			
		} else {
		
			self.resetBtn.alpha = 0
			self.emailTxt.alpha = 0
			self.cancelBtn.alpha = 0
			self.emailLabel.alpha = 0
		
			UIView.animate(withDuration: 0.8, animations: {

				
				self.resetBtn.alpha = 1
				self.emailTxt.alpha = 1
				self.cancelBtn.alpha = 1
				self.emailLabel.alpha = 1
			})
			
		}
	}
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
        emailLabel.frame = CGRect(x: 10, y: 200, width: self.view.frame.size.width - 20, height: 30)
        // alignment
        emailTxt.frame = CGRect(x: 10, y: emailLabel.frame.origin.y + 35, width: self.view.frame.size.width - 20, height: 45)
		
		
		resetBtn.frame = CGRect(x: self.view.frame.size.width / 6, y: emailTxt.frame.origin.y + 60, width: self.view.frame.size.width / 1.5, height: 50)
		resetBtn.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
		resetBtn.titleLabel?.textAlignment = .center
		
        cancelBtn.frame = CGRect(x: 10, y: 20, width: self.view.frame.size.width / 4, height: 30)
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.width / 20
        // background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }
    
    
    // clicked reset button
    @IBAction func resetBtn_click(_ sender: AnyObject) {
        
        // hide keyboard
        self.view.endEditing(true)
        
        // email textfield is empty
        if emailTxt.text!.isEmpty {
            
            // show alert message
            self.showPopupWithStyle(.centered, titleText: "Error", bodyText: "Please enter an email.")
        }
        
        // request for reseting password
        PFUser.requestPasswordResetForEmail(inBackground: emailTxt.text!) { (success, error) -> Void in
            if success {
                
				self.showPopupWithStyle(.centered, titleText: "Success", bodyText: "An email has been sent to the texted email.")
				
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
    
    
    // clicked cancel button
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

extension resetPasswordVC : CNPPopupControllerDelegate {
	
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        //print("Popup controller will be dismissed")
    }
	
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        //print("Popup controller presented")
    }
}
