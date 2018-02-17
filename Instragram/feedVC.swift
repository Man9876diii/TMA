//
//  feedVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 22.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import AVFoundation


class feedVC: UITableViewController, UITabBarControllerDelegate {

    // UI objects
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    // arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var videoArray = [PFFile]()
    var mediaArray = [PFFile]()
    var typeArray = [String]()
    var posts = [PFObject]()
    var titleArray = [String]()
    var uuidArray = [String]()
	
    var canLoop = true
    var hasScrolled = false
	
    var videoIndex = 0
    var picIndex = 0
    var indexPostTypes = [String]()
    
    var followArray = [String]()
    var currentVideoPlayer: AVPlayer?
	var currentType = ""
	
    var popupController: CNPPopupController?
    
    // page size
    var page : Int = 10
	
    var tapBar: HMSegmentedControl!
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
		
        //self.tableView.contentInset = UIEdgeInsets(top: 50.0, left: 0.0, bottom: 0.0, right: 0.0)
		
//        //Create the switch bar.
//		tapBar = HMSegmentedControl(sectionTitles: ["TMA", "VINE"])
//		tapBar?.selectionIndicatorColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
//		tapBar?.selectionStyle = .fullWidthStripe
//		tapBar?.selectionIndicatorLocation = .down
//
//		tapBar?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 60)
//		tapBar?.addTarget(self, action: #selector(feedVC.barTapped), for: .valueChanged)
//		tapBar?.selectedSegmentIndex = 0
//		tapBar?.backgroundColor = UIColor.white
//		tapBar?.tintColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
//		self.view.addSubview(tapBar!)
		
		
        let defaults = UserDefaults.standard
		let hasSeenWelcome = defaults.bool(forKey: "hasSeenWelcome")
		if !hasSeenWelcome || hasSeenWelcome == false {
			
			showPopupWithStyle(.centered, titleText: "Welcome", bodyText: "Welcome text.")
			
			defaults.set(true, forKey: "hasSeenWelcome")
		} 
		
        self.tabBarController?.delegate = self 
        
        // title at the top
        self.navigationItem.title = "FEED"
        
        // automatic row height - dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        // pull to refresh
        refresher.addTarget(self, action: #selector(feedVC.loadPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        // receive notification from postsCell if picture is liked, to update tableView
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        // indicator's x(horizontal) center
        indicator.center.x = tableView.center.x
        
        // receive notification from uploadVC
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
		
        self.currentType = "tma"
        // calling function to load posts
		loadPosts(type: self.currentType)
    }
	
    @objc func barTapped(_ segmentedControl: UISegmentedControl) {
		
		
    	switch segmentedControl.selectedSegmentIndex {
			case 0:
				
				//Images
				
				self.currentType = "tma"
				self.mediaArray = []
				self.tableView.reloadData()
				loadPosts(type: "tma")
				
				let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
				let underlineAttributedString = NSAttributedString(string: "TMA", attributes: underlineAttribute)
				
			
				
			    break
			case 1:
				
				//Videos
				self.currentType = "vine"
				self.mediaArray = []
				self.tableView.reloadData()
				loadPosts(type: "vine")
				
				let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
				let underlineAttributedString = NSAttributedString(string: "VINE", attributes: underlineAttribute)
				
				
				break
			default:
				
				break
		}
	}
	
    override func viewDidDisappear(_ animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		self.canLoop = false
		self.hasScrolled = true
	}
    
    
    // refreshign function after like to update degit
    @objc func refresh() {
        tableView.reloadData()
    }
    
    
    // reloading func with posts  after received notification
    @objc func uploaded(_ notification:Notification) {
		loadPosts(type: self.currentType)
    }
    
    
    // load posts
	@objc func loadPosts(type type: String) {
		
    	print("load posts")
		
        if PFUser.current() == nil {
			
        	return 
		}
        // STEP 1. Find posts realted to people who we are following
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
		
        followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.followArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.followArray.append(object.object(forKey: "following") as! String)
                }
                
                // append current user to see own posts in feed
                self.followArray.append(PFUser.current()!.username!)
                
                // STEP 2. Find posts made by people appended to followArray
                let query = PFQuery(className: "posts")
                query.whereKey("username", containedIn: self.followArray)
                query.limit = self.page
                query.whereKey("contentType", equalTo: type)
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
						
						
                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        //self.picArray.removeAll(keepingCapacity: false)
                        self.typeArray = []
						self.mediaArray = []
                        self.titleArray.removeAll(keepingCapacity: false)
                        self.uuidArray.removeAll(keepingCapacity: false)
						self.posts.removeAll(keepingCapacity: false)
						
                        
                        // find related objects
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.dateArray.append(object.createdAt)
							self.posts.append(object)
							self.typeArray.append(object.object(forKey: "type") as! String)
							
							self.mediaArray.append(object.object(forKey: "media") as! PFFile)
						
							
                            self.titleArray.append(object.object(forKey: "title") as! String)
                            self.uuidArray.append(object.object(forKey: "uuid") as! String)
						
                        }
						
						print(self.typeArray)
                        
                        // reload tableView & end spinning of refresher
                        self.tableView.reloadData()
                        self.refresher.endRefreshing()
					
						
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    
    // scrolled down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		//self.tableView.reloadData()
		
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadMore()
        }
    }
    
    
    // pagination
    func loadMore() {
        // if posts on the server are more than shown
        if page <= uuidArray.count {
			
			
			
			
            // start animating indicator
            indicator.startAnimating()
            
            // increase page size to load +10 posts
            page = page + 10
            
            // STEP 1. Find posts realted to people who we are following
            let followQuery = PFQuery(className: "follow")
            followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
            followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.followArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
						
                        self.followArray.append(object.object(forKey: "following") as! String)
                    }
                    
                    // append current user to see own posts in feed
                    self.followArray.append(PFUser.current()!.username!)
                    
                    // STEP 2. Find posts made by people appended to followArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            self.picArray.removeAll(keepingCapacity: false)
                            self.titleArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
							self.mediaArray = []
							self.typeArray = []
							
                            // find related objects
                            for object in objects! {
								
								self.posts.append(object)
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                                self.dateArray.append(object.createdAt)
                                //self.picArray.append(object.object(forKey: "pic") as! PFFile)
                                self.mediaArray.append(object.object(forKey: "media") as! PFFile)
                                self.titleArray.append(object.object(forKey: "title") as! String)
                                self.uuidArray.append(object.object(forKey: "uuid") as! String)
								self.typeArray.append(object.object(forKey: "type") as! String)
                            }
							
                            print(self.typeArray)
                            
                            // reload tableView & stop animating indicator
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                            
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        }
        
    }


    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return uuidArray.count
    }
	
    func loopVideo(videoPlayer: AVPlayer, cell: UITableViewCell, indexPath: IndexPath) {
	
		//if self.hasScrolled == false {
		
		
			NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
			
				let cellRect = self.tableView.rectForRow(at: indexPath)
				let completelyVisible = self.tableView.bounds.contains(cellRect)
				
				if completelyVisible {
					
					videoPlayer.seek(to: kCMTimeZero)
					videoPlayer.play()
				}
			}
	   // }
    }
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		guard let postCell = (cell as? postCell) else { return };
		

		
		if postCell.player != nil {
		
			postCell.player?.play()
			
			loopVideo(videoPlayer: postCell.player!, cell: cell, indexPath: indexPath)
		}
	}
	
	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

		guard let postCell = (cell as? postCell) else { return };

	
		
	
		if postCell.player != nil {
		
			postCell.player?.pause()
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
		
		if cell.picImg.image == nil && cell.player == nil {
		
			mediaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
				
				let type = self.typeArray[indexPath.row]
				
				
				if type == "image" {
				
					
					cell.picImg.image = UIImage(data: data!)
					cell.picImg.isHidden = false
					cell.isImage = true
					
				} else if type == "video" {
					
					cell.picImg.image = nil
					let videoURL = URL(string: self.mediaArray[indexPath.row].url!)
			
					let player = AVPlayer(url: videoURL!)
				
					let layer: AVPlayerLayer = AVPlayerLayer(player: player)
					layer.backgroundColor = UIColor.white.cgColor
					layer.frame = cell.picImg.frame
					layer.videoGravity = .resizeAspect
			
					let r = CGRect(x: 0.0, y: 0.0, width: cell.picImg.frame.size.width, height: cell.picImg.frame.size.height)
					let videoView = UIView(frame: r)
					videoView.layer.addSublayer(layer)
					videoView.tag = 123
			
					cell.addSubview(videoView)
					cell.player = player
					cell.isImage = false
					
					if indexPath.row == 0 {
					
						cell.player?.play()
					}
					
					self.hasScrolled = false
				
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
                    self.alert("Flagged successfully", message: "Thank You! We will consider your complaint.")
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
        
        // show menu
        self.present(menu, animated: true, completion: nil)
    }
    
    
    // alert action
    func alert (_ title: String, message : String) {
        
        self.showPopupWithStyle(.centered, titleText: title, bodyText: message)
    }
	

	
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {


		let cells = self.tableView.visibleCells
		
		for cell in cells {
		
			print(cell)
			
			let pCell = cell as! postCell
			if pCell.player != nil {
				
				pCell.player?.pause()
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

extension feedVC : CNPPopupControllerDelegate {
	
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        //print("Popup controller will be dismissed")
    }
	
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        //print("Popup controller presented")
    }
}
