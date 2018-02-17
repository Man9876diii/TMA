//
//  ContactSupportViewController.swift
//  Instragram
//
//  Created by Landon Ferrier on 11/30/17.
//  Copyright © 2017 Akhmed Idigov. All rights reserved.
//

import UIKit

class supportVC: UIViewController, ENSideMenuDelegate {

	
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
		
		self.navigationItem.title = "Support"
		
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

    }

	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
