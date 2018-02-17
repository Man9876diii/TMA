//
//  homeVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 10.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import AVFoundation


class homeVC: UICollectionViewController, ENSideMenuDelegate {

	
	
	var currentType = String()

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
	

    // refresher variable
    var refresher : UIRefreshControl!
    
    // size of page
    var page : Int = 12
    
    // arrays to hold server information
    var uuidArray = [String]()
    var picArray = [PFFile]()
	
    var mediaArray = [PFFile]()
	
	var typeArray = [String]()
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		
		
        
		
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 65, height: 20))
		button.addTarget(self, action: #selector(MyNavigationController.toggleSideMenuView), for: .touchUpInside)
		
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 65, height: 20))
		label.text = "Settings"
		label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	
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
		//toggleSideMenuView()
        
        // always vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        // background color
        collectionView?.backgroundColor = .white

        // title at the top
        self.navigationItem.title = PFUser.current()?.username?.uppercased()
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(homeVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // receive notification from editVC
        NotificationCenter.default.addObserver(self, selector: #selector(homeVC.reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
		self.currentType = "tma"
		
        // load posts func
		loadPosts(type: self.currentType)
    }
    
    
    // refreshing func
    @objc func refresh() {
        
        // reload posts
		loadPosts(type: self.currentType)
        
        // stop refresher animating
        refresher.endRefreshing()
    }
    
    
    // reloading func after received notification
    @objc func reload(_ notification:Notification) {
        collectionView?.reloadData()
    }
    
        
    // load posts func
    func loadPosts(type: String) {
        
        // request infomration from server
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.current()!.username!)
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
                
                // find objects related to our request
                for object in objects! {
                    
                    // add found data to arrays (holders)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.mediaArray.append(object.value(forKey: "media") as! PFFile)
                    self.typeArray.append(object.value(forKey: "type") as! String)
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
			loadMore(type: self.currentType)
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
            query.whereKey("username", equalTo: PFUser.current()!.username!)
            query.limit = page
            query.whereKey("contentType", equalTo: type)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
					self.mediaArray = []
					self.typeArray = []
					
                    // find related objects
                    for object in objects! {
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.mediaArray.append(object.value(forKey: "media") as! PFFile)
                        self.typeArray.append(object.value(forKey: "type") as! String)
                    }
                    
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
        
        
        // STEP 1. Get user data
        // get users data with connections to collumns of PFuser class
        header.fullnameLbl.text = (PFUser.current()?.object(forKey: "fullname") as? String)?.uppercased()
        header.webTxt.text = PFUser.current()?.object(forKey: "web") as? String
        header.webTxt.sizeToFit()
        header.bioLbl.text = PFUser.current()?.object(forKey: "bio") as? String
        let avaQuery = PFUser.current()?.object(forKey: "ava") as! PFFile
        avaQuery.getDataInBackground { (data, error) -> Void in
            header.avaImg.image = UIImage(data: data!)
        }
        header.button.isHidden = true 
		
        /*
        
        // STEP 2. Count statistics
        // count total posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.posts.text = "\(count)"
            }
        })

        */
        
        // count total followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.current()!.username!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followers.text = "\(count)"
            }
        })
        
        // count total followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: PFUser.current()!.username!)
        followings.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followings.text = "\(count)"
            }
        })
        
		
        /*
        // STEP 3. Implement tap gestures
        // tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        */
        
        // tap followers
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        // tap followings
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
    }
    
    
    // taped posts label
    @objc func postsTap() {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    // tapped followers label
    @objc func followersTap() {
        
        user = PFUser.current()!.username!
        category = "followers"
        
        // make references to followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    // tapped followings label
    @objc func followingsTap() {
        
        user = PFUser.current()!.username!
        category = "followings"
        
        // make reference to followersVC
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC

        // present
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    
    // clicked log out
    @IBAction func logout(_ sender: AnyObject) {
    
        // implement log out
        PFUser.logOutInBackground { (error) -> Void in
            if error == nil {
                
                // remove logged in user from App memory
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                
                let signin = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as! signInVC
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signin
                
            }
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
    
	@IBAction func barTapped(_ sender: Any) {
	
		let segmentedControl = sender as! UISegmentedControl
	
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
