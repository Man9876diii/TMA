//
//  guestVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 11.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

var guestname = [String]()

class guestVC: UICollectionViewController {
    
    // UI objects
    var refresher : UIRefreshControl!
    var page : Int = 12
    
    // arrays to hold data from server
    var uuidArray = [String]()
    var picArray = [PFFile]()
	
    var mediaArray = [PFFile]()
	
	var typeArray = [String]()
	
	var popupController: CNPPopupController?
	
	var currentType = String()
	
	
	// default func
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		var blocked = false
		
		let query = PFUser.query()
		query?.whereKey("username", equalTo: guestname.last!)
		query?.findObjectsInBackground(block: { (objects, error) in
	
			if error == nil {
			
				if objects?.count != 0 {
					
					let object = objects?.first
					let blockedUsers = object?.object(forKey: "blockedUsers") as! [String]
					
					print(blockedUsers)
					
					if blockedUsers.contains((PFUser.current()?.username!)!) {
					
						blocked = true
						
						//Don't show user data.
						
						
						self.showPopupWithStyle(.centered, titleText: "Blocked", bodyText: "This user has blocked you.")
					}
				}
			}
		})
		
		
		
        // allow vertical scroll
        self.collectionView!.alwaysBounceVertical = true
        
        // backgroung color
        self.collectionView?.backgroundColor = .white
        
        // top title
        self.navigationItem.title = guestname.last?.uppercased()
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(guestVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guestVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(guestVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
		
		
		/*
		let blockBtn = UIButton(frame: CGRect(x: self.view.frame.size.width - 100, y: 200, width: 100, height: 30))
		blockBtn.setTitle("Block", for: .normal)
		blockBtn.addTarget(self, action: #selector(guestVC.blockUser(_:)), for: .touchUpInside)
		self.view.addSubview(blockBtn)
		self.view.bringSubview(toFront: blockBtn)
		
		print(blockBtn)
		*/
		
		//If the current user has blocked the current, exit out here.
		if blocked {
			
			return
		}
		
		let blockedUsers = PFUser.current()?.object(forKey: "blockedUsers") as! [String]
		if blockedUsers.contains(guestname.last!) {
		
			print("Unblock")
			//blockBtn.setTitle("Unblock", for: .normal)
		} else {
			print("Block")
			//blockBtn.setTitle("Block", for: .normal)
		}
		
        // call load posts function
		loadPosts(type: "tma")
    }
    
    
    // back function
    @objc func back(_ sender : UIBarButtonItem) {
        
        // push back
        _ = self.navigationController?.popViewController(animated: true)
        
        // clean guest username or deduct the last guest userame from guestname = Array
        if !guestname.isEmpty {
            guestname.removeLast()
        }
    }
    
    
    // refresh function
    @objc func refresh() {
        refresher.endRefreshing()
		loadPosts(type: self.currentType)
    }
    
    
    // posts loading function
    func loadPosts(type: String) {
        
        // load posts
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestname.last!)
        query.limit = page
        query.whereKey("contentType", equalTo: type)
        query.order(byAscending: "createdAt")
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                self.mediaArray = []
                self.typeArray = []
                
                // find related objects
                for object in objects! {
                    
                    // hold found information in arrays
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.typeArray.append(object.object(forKey: "type") as! String)
                    self.mediaArray.append(object.value(forKey: "media") as! PFFile)
                }
                
                self.collectionView?.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    
    // load more while scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
			self.loadMore(type: self.currentType)
        }
    }
    
    
    // paging
    func loadMore(type: String) {
        
        // if there is more objects
        if page <= picArray.count {
            
            // increase page size
            page = page + 12
            
            // load more posts
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: guestname.last!)
            query.limit = page
            query.whereKey("contentType", equalTo: type)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    }
                    
                    print("loaded +\(self.page)")
                    self.collectionView?.reloadData()
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
        }
        
    }
    
    
    // cell numb
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaArray.count
    }
    
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    
    // cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
         // create picture imageView in cell to show loaded pictures
        let picImg = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
		
		
        // get loaded images from array
//        picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
//            if error == nil {
//                picImg.image = UIImage(data: data!)
//            } else {
//                print(error!.localizedDescription)
//            }
//        }
		
        mediaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
			
			let type = self.typeArray[indexPath.row]
			
			if type == "image" {
			
				
				picImg.image = UIImage(data: data!)
				cell.addSubview(picImg)
				
			} else if type == "video" {
				
				
				let videoURL = URL(string: self.mediaArray[indexPath.row].url!)
		
				let player = AVPlayer(url: videoURL!)
				
				let layer: AVPlayerLayer = AVPlayerLayer(player: player)
				layer.backgroundColor = UIColor.clear.cgColor
				layer.frame = picImg.frame
				layer.videoGravity = .resizeAspectFill
			
				let r = CGRect(x: 0.0, y: 0.0, width: picImg.frame.size.width, height: picImg.frame.size.height)
				let videoView = UIView(frame: r)
				videoView.layer.addSublayer(layer)
			
				cell.addSubview(videoView)
			}
		}
        
        return cell
    }
    
    
    // header config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // define header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerView
        
        
        // STEP 1. Load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestname.last!)
        infoQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // shown wrong user
                if objects!.isEmpty {
                    // call alert
					
                    self.showPopupWithStyle(.centered, titleText: "\(guestname.last!.uppercased())", bodyText: "is not existing")
                }
                
                // find related to user information
                for object in objects! {
                    header.fullnameLbl.text = (object.object(forKey: "fullname") as? String)?.uppercased()
                    header.bioLbl.text = object.object(forKey: "bio") as? String
                    header.webTxt.text = object.object(forKey: "web") as? String
                    header.webTxt.sizeToFit()
                    let avaFile : PFFile = (object.object(forKey: "ava") as? PFFile)!
                    avaFile.getDataInBackground(block: { (data, error) -> Void in
                        header.avaImg.image = UIImage(data: data!)
                    })
                }
                
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        
        // STEP 2. Show do current user follow guest or do not
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.whereKey("following", equalTo: guestname.last!)
        followQuery.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                if count == 0 {
                    header.button.setTitle("FOLLOW", for: UIControlState())
                    header.button.backgroundColor = .lightGray
                } else {
                    header.button.setTitle("FOLLOWING", for: UIControlState())
                    header.button.backgroundColor = .green
                }
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
		
        /*
        // STEP 3. Count statistics
        // count posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestname.last!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.posts.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        */
        
        // count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: guestname.last!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followers.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        // count followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: guestname.last!)
        followings.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followings.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
		
        /*
        // STEP 4. Implement tap gestures
        // tap to posts label
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        */
        
        // tap to followers label
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        // tap to followings label
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        
        return header
    }

    
    // tapped posts label
    @objc func postsTap() {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    // tapped followers label
    @objc func followersTap() {
        user = guestname.last!
        category = "followers"
        
        // defind followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        // navigate to it
        self.navigationController?.pushViewController(followers, animated: true)
        
    }
    
    // tapped followings label
    @objc func followingsTap() {
        user = guestname.last!
        category = "followings"
        
        // define followersVC
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        // navigate to it
        self.navigationController?.pushViewController(followings, animated: true)
        
    }
	
	@IBAction func blockUser(_ sender: Any) {
	
		let title = (sender as! UIButton).titleLabel?.text!
		let shouldBlock = (title == "Block")
		
		print("should block")
		print(shouldBlock)
		
		let username = guestname.last!
		
		//Add to blocked users.
		var blockedUsers = PFUser.current()?.object(forKey: "blockedUsers") as! [String]
		
		if blockedUsers.contains(username) == false {
		
			blockedUsers.append(username)
			PFUser.current()?.setObject(blockedUsers, forKey: "blockedUsers")
			PFUser.current()?.saveInBackground(block: { (success, error) in
				
				if error == nil {
				
					let request: [AnyHashable:Any] = ["displayedUserUsername":guestname.last!, "currentUserUsername":PFUser.current()?.username!]

					PFCloud.callFunction(inBackground: "blockUser", withParameters: request, block: { (obj, error) in
					
						if error == nil {
							
							
							
							 //Pop to projects view controller.
							 self.navigationController?.popViewController(animated: false)
						 } else { print(error!) }
					})
					
				} else {
				
					print(error!)
				}
			})
		} else {
		
			
			let request: [AnyHashable:Any] = ["displayedUserUsername":guestname.last!, "currentUserUsername":PFUser.current()?.username!]

			PFCloud.callFunction(inBackground: "blockUser", withParameters: request, block: { (obj, error) in
			
				if error == nil {
					
					
					
					print("Blocked user: \(guestname)")
				
					 //Pop to projects view controller.
					 self.navigationController?.popViewController(animated: true)
				 } else { print(error!) }
			})
		}
	}
    
    
    // go post
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        // navigate to post view controller
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
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
	
	@IBAction func barTapped(_ segmentedControl: UISegmentedControl) {
		
		print("bar tapped")
		
    	switch segmentedControl.selectedSegmentIndex {
			case 0:
				
				//Images
				
				self.currentType = "tma"
				self.mediaArray = []
				self.collectionView?.setContentOffset(CGPoint.zero, animated: false)
				self.collectionView?.reloadData()
				loadPosts(type: "tma")
				
				
			    break
			case 1:
				
				//Videos
				self.currentType = "vine"
				self.collectionView?.setContentOffset(CGPoint.zero, animated: false)
				self.mediaArray = []
				self.collectionView?.reloadData()
				loadPosts(type: "vine")
				
				
				break
			default:
				
				break
		}
	}
}

extension guestVC : CNPPopupControllerDelegate {
	
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
	
		self.navigationController?.popViewController(animated: true)
    }
	
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        //print("Popup controller presented")
    }
}

