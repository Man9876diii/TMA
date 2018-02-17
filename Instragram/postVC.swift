//
//  postVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 17.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import AVFoundation


var postuuid = [String]()

class postVC: UITableViewController, UITabBarControllerDelegate {

    // arrays to hold information from server
    var avaArray = [PFFile]()
    var usernameArray = [String]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var mediaArray = [PFFile]()
    var uuidArray = [String]()
    var titleArray = [String]()
    var type: String!
	
    var mPlayer: AVPlayer?
    var canLoop = false
	
    var popupController: CNPPopupController?
    
	
	override func viewWillDisappear(_ animated: Bool) {
	
		super.viewWillDisappear(animated)
		
		self.canLoop = false
	}
	
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.tabBarController?.delegate = self
        
        // title label at the top
        self.navigationItem.title = "PHOTO"
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(postVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(postVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
                
        // dynamic cell heigth
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        // find post
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.avaArray.removeAll(keepingCapacity: false)
                self.usernameArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                //self.picArray.removeAll(keepingCapacity: false)
                self.mediaArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.titleArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.dateArray.append(object.createdAt)
                 //   self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.titleArray.append(object.value(forKey: "title") as! String)
                    self.mediaArray.append(object.value(forKey: "media") as! PFFile)
                }
				
				let obj = objects![0]
				self.type = obj.object(forKey: "type") as! String
                
                self.tableView.reloadData()
            }
        })
        
    }
    
    
    // refreshing function
    @objc func refresh() {
        self.tableView.reloadData()
    }

    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
	
	func loopVideo(videoPlayer: AVPlayer) {
	
		NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
		
			if self.canLoop {
				
				videoPlayer.seek(to: kCMTimeZero)
				videoPlayer.play()
			}
		}
    }

    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! postCell
        
        // connect objects with our information from arrays
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState())
        cell.usernameBtn.sizeToFit()
        cell.uuidLbl.text = uuidArray[indexPath.row]
        cell.titleLbl.text = titleArray[indexPath.row]
        cell.titleLbl.sizeToFit()
        
        // place profile picture
        avaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            cell.avaImg.image = UIImage(data: data!)
        }
        
        // place post picture
//        picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
//            cell.picImg.image = UIImage(data: data!)
//        }
//

		DispatchQueue.main.async {
 
			self.mediaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
				
				print("done")
				
				let type = self.type
				
				if type == "image" {
				
					cell.picImg.image = UIImage(data: data!)
					
				} else if type == "video" {
					
					
					let videoURL = URL(string: self.mediaArray[indexPath.row].url!)
					
					let player = AVPlayer(url: videoURL!)
					
					let layer: AVPlayerLayer = AVPlayerLayer(player: player)
					layer.backgroundColor = UIColor.gray.cgColor
					layer.frame = cell.picImg.frame
					layer.videoGravity = .resizeAspectFill
				
					let r = CGRect(x: 0.0, y: 0.0, width: cell.picImg.frame.size.width, height: cell.picImg.frame.size.height)
					let videoView = UIView(frame: r)
					videoView.layer.addSublayer(layer)
				
					cell.addSubview(videoView)
				
					player.play()
					
					self.loopVideo(videoPlayer: player)
					self.mPlayer = player
					self.canLoop = true
				}
			}
		}
		
		
        
        // calculate post date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
		
        // logic what to show: seconds, minuts, hours, days or weeks
        if difference.second! <= 0 {
            cell.dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLbl.text = "\(difference.second!)s."
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLbl.text = "\(difference.minute!)m."
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(difference.hour!)h."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.dateLbl.text = "\(difference.day!)d."
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(difference.weekOfMonth!)w."
        }
        
        
        // manipulate like button depending on did user like it or not
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.current()!.username!)
        didLike.whereKey("to", equalTo: cell.uuidLbl.text!)
        didLike.countObjectsInBackground { (count, error) -> Void in
            // if no any likes are found, else found likes
            if count == 0 {
                cell.likeBtn.setTitle("unlike", for: UIControlState())
                cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState())
            } else {
                cell.likeBtn.setTitle("like", for: UIControlState())
                cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState())
            }
        }
        
        // count total likes of shown post
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackground { (count, error) -> Void in
            cell.likeLbl.text = "\(count)"
        }
        
        
        // asign index
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        
        
        // @mention is tapped
        cell.titleLbl.userHandleLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            
            // if tapped on @currentUser go home, else go guest
            if mention.lowercased() == PFUser.current()?.username {
                let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                guestname.append(mention.lowercased())
                let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
                self.navigationController?.pushViewController(guest, animated: true)
            }
        }
        
        // #hashtag is tapped
        cell.titleLbl.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "hashtagsVC") as! hashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
        }
        
        return cell
    }
    
    
    // clicked username button
    @IBAction func usernameBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! postCell
        
        // if user tapped on himself go home, else go guest
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }
    
    
    // clicked comment button
    @IBAction func commentBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! postCell
        
        // send related data to global variables
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        
        // go to comments. present vc
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    
    // clicked more button
    @IBAction func moreBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell date
        let cell = tableView.cellForRow(at: i) as! postCell
        
        
        // DELET ACTION
        let delete = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) -> Void in
            
            // STEP 1. Delete row from tableView
            self.usernameArray.remove(at: i.row)
            self.avaArray.remove(at: i.row)
            self.dateArray.remove(at: i.row)
            self.picArray.remove(at: i.row)
            self.titleArray.remove(at: i.row)
            self.uuidArray.remove(at: i.row)
            
            // STEP 2. Delete post from server
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: cell.uuidLbl.text!)
            postQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                
                                // send notification to rootViewController to update shown posts
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                                
                                // push back
                                _ = self.navigationController?.popViewController(animated: true)
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
            // STEP 2. Delete likes of post from server
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            likeQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            // STEP 3. Delete comments of post from server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            commentQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            // STEP 4. Delete hashtags of post from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            hashtagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
        }
        
        
        // COMPLAIN ACTION
        let complain = UIAlertAction(title: "Flag", style: .default) { (UIAlertAction) -> Void in
            
            // send complain to server
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.current()?.username
            complainObj["to"] = cell.uuidLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            complainObj.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.alert("Flagged successfully", message: "Thank You! We will consider your complaint")
                } else {
                    self.alert("ERROR", message: error!.localizedDescription)
                }
            })
        }
        
        // CANCEL ACTION
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        // create menu controller
        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
        
        
        // if post belongs to user, he can delete post, else he can't
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
            menu.addAction(delete)
            menu.addAction(cancel)
        } else {
            menu.addAction(complain)
            menu.addAction(cancel)
        }
		
        menu.view.tintColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
        
        // show menu
        self.present(menu, animated: true, completion: nil)
    }
    
    
    // alert action
    func alert (_ title: String, message : String) {
		
		
        self.showPopupWithStyle(.centered, titleText: title, bodyText: message)
    }
    
    
    // go back function
    @objc func back(_ sender: UIBarButtonItem) {
		
		if (self.mPlayer != nil) {
		
			self.mPlayer?.pause()
			self.canLoop = false
			
		}
		
        // push back
        _ = self.navigationController?.popViewController(animated: true)
        
        // clean post uuid from last hold
        if !postuuid.isEmpty {
           postuuid.removeLast()
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

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

		if viewController != self.navigationController || self.mPlayer != nil {
			
			self.canLoop = false
			self.mPlayer?.pause()
			self.navigationController?.popViewController(animated: false)
		}
	}

}

extension postVC : CNPPopupControllerDelegate {
	
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        //print("Popup controller will be dismissed")
    }
	
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        //print("Popup controller presented")
    }
}

