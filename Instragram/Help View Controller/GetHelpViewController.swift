//
//  GetHelpViewController.swift
//  Construction Plus
//
//  Created by Landon Ferrier on 11/3/17.
//  Copyright © 2017 Landon Ferrier. All rights reserved.
//

import UIKit
import Parse

class GetHelpViewController: UIViewController, UITextViewDelegate, ENSideMenuDelegate {

	//@IBOutlet weak var titleLabel: UILabel!
	//@IBOutlet weak var textView: UITextView!
	
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var textView: UITextView!
	
	var popupController: CNPPopupController?
	
	var createLabel: UILabel?
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
		
		self.navigationItem.title = "Get Help"
		
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
		
        self.navigationItem.title = "Get Help"
		
        self.textView.becomeFirstResponder()
        self.textView.delegate = self

    }
	
	@IBAction func createTapped(_ sender: Any) {
	
		createRequestButtonTapped()
	}
	@objc func pop() {
		
		self.navigationController?.popViewController(animated: true)
	}
	
	@objc func createRequestButtonTapped() {
	
		if textView.text.count == 0 {
		
			return
		}
	
		//Create the loading indicator.
		let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		indicator.backgroundColor = #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)
		indicator.startAnimating()
		indicator.frame = self.view.frame
		self.view.addSubview(indicator)
		
		
		
		//Get the right bar button item because it may be added again.
		let item = self.navigationItem.rightBarButtonItem
		
		//Empty the nav bar.
		self.navigationItem.rightBarButtonItem = nil
		
		//Change the nav bar title.
		self.navigationItem.title = "Saving..."
		
		//Get the text from the text view.
		let text = self.textView.text!
		
		//Get the current user object.
		let currentUser = PFUser.current()
		
		//Create the request object.
		let hRequest = PFObject(className: "HelpRequest")
		hRequest.setObject(text, forKey: "requestText")
		hRequest.setObject(currentUser!, forKey: "user")
		
		//Save the object, then go back to the projects view.
		hRequest.saveInBackground { (success, error) in
	
			if error == nil {
			
			
				//Pop
				self.navigationItem.title = "Get Help"
				indicator.removeFromSuperview()
				self.textView.text = ""
				
				self.view.endEditing(true)
				
				self.showPopupWithStyle(.centered, titleText: "Success", bodyText: "Your request has been sent sucessfully.")
				
				
			} else {
			
				indicator.removeFromSuperview()
				self.navigationItem.rightBarButtonItem = item
				print(error!)
			}
		}
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
	
	
		let stext = textView.text! as NSString
		let newText = stext.replacingCharacters(in: range, with: text)
    	let length = newText.count
    	if length == 0 {
			
			if self.createLabel != nil {
			
				//Fade out.
				
				UIView.animate(withDuration: 0.7, animations: {
	
		
					self.createLabel?.alpha = 0
					self.navigationItem.rightBarButtonItem = nil
				})
			}
			
		} else {
		
			if self.navigationItem.rightBarButtonItem == nil {
			
			
			
				//Create button.
				let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
				button.addTarget(self, action: #selector(GetHelpViewController.createRequestButtonTapped), for: .touchUpInside)
				
				let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
				label.font = UIFont(name: "AvenirNext-Bold", size: 16)
				label.text = "Submit"
				label.textColor = UIColor.white
				label.textAlignment = .right
				
				button.addSubview(label)
				
				let newTaskItem = UIBarButtonItem(customView: button)
				newTaskItem.target = self
				newTaskItem.action = #selector(GetHelpViewController.createRequestButtonTapped)
				
				
				let labelConstraint = button.heightAnchor.constraint(equalToConstant: 20)
				labelConstraint.isActive = true
				let labelConstraint2 = button.widthAnchor.constraint(equalToConstant: 60)
				labelConstraint2.isActive = true
				
				label.alpha = 0
				
	
				self.createLabel = label
				
				UIView.animate(withDuration: 0.7, animations: {
		
					label.alpha = 1
				})
			}
		}
		
		return true
	}
	
	
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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

extension GetHelpViewController : CNPPopupControllerDelegate {
	
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        //print("Popup controller will be dismissed")
    }
	
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        //print("Popup controller presented")
    }
	
}

