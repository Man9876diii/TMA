//
//  navVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 18.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit

class navVC: UINavigationController {
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // color of title at the top in nav controller
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        // color of buttons in nav controller
        self.navigationBar.tintColor = .white
        
        // color of background of nav controller
        self.navigationBar.barTintColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
        
        // disable translucent
        self.navigationBar.isTranslucent = false
    }
    
    
    // white status bar function
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

}
