//
//  usersVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 22.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class usersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // declare search bar
    var searchBar = UISearchBar()
    var tapBar: HMSegmentedControl?
    
    // tableView arrays to hold information from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    
    // collectionView UI
    var collectionView : UICollectionView!
    
    // collectionView arrays to hold infromation from server
    var picArray = [PFFile]()
    var mediaArray = [PFFile]()
	
	var typeArray = [String]()
	
    var uuidArray = [String]()
    var page : Int = 15
	
    var currentType = String()
	
    var isShowingUsers = false
    var showingFeatured = false
	var showingPopular = false
	
    var featuredButton: UIButton!
    var popularButton: UIButton!

    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // implement search bar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
		
        
        // call collectionView
        collectionViewLaunch()
    }
    
    
    
    // SEARCHING CODE
    // load users function
    func loadUsers() {
		
		self.usernameArray = []
		self.avaArray = []
		self.tableView.reloadData()
		
        if showingFeatured {
			
			let usersQuery = PFQuery(className: "_User")
			usersQuery.addDescendingOrder("followers")
			usersQuery.limit = 20
			usersQuery.findObjectsInBackground (block: { (objects, error) -> Void in
				if error == nil {
					
					// clean up
					self.usernameArray.removeAll(keepingCapacity: false)
					self.avaArray.removeAll(keepingCapacity: false)
					
					// found related objects
					for object in objects! {
						self.usernameArray.append(object.value(forKey: "username") as! String)
						self.avaArray.append(object.value(forKey: "ava") as! PFFile)
					}
					
					// reload
					self.tableView.reloadData()
					
				} else {
					print(error!.localizedDescription)
				}
			})
			
		} else if showingPopular {
			
			let usersQuery = PFQuery(className: "_User")
			usersQuery.addDescendingOrder("followers")
			usersQuery.limit = 20
			usersQuery.findObjectsInBackground (block: { (objects, error) -> Void in
				if error == nil {
					
					// clean up
					self.usernameArray.removeAll(keepingCapacity: false)
					self.avaArray.removeAll(keepingCapacity: false)
					
					// found related objects
					for object in objects! {
						self.usernameArray.append(object.value(forKey: "username") as! String)
						self.avaArray.append(object.value(forKey: "ava") as! PFFile)
					}
					
					// reload
					self.tableView.reloadData()
					
				} else {
					print(error!.localizedDescription)
				}
			})
		
		} else {
		
			let usersQuery = PFQuery(className: "_User")
			usersQuery.addDescendingOrder("createdAt")
			usersQuery.limit = 20
			usersQuery.findObjectsInBackground (block: { (objects, error) -> Void in
				if error == nil {
					
					// clean up
					self.usernameArray.removeAll(keepingCapacity: false)
					self.avaArray.removeAll(keepingCapacity: false)
					
					// found related objects
					for object in objects! {
						self.usernameArray.append(object.value(forKey: "username") as! String)
						self.avaArray.append(object.value(forKey: "ava") as! PFFile)
					}
					
					// reload
					self.tableView.reloadData()
					
				} else {
					print(error!.localizedDescription)
				}
			})
        }
        
    }
    
    
    // search updated
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // find by username
        let usernameQuery = PFQuery(className: "_User")
        usernameQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        usernameQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // if no objects are found according to entered text in usernaem colomn, find by fullname
                if objects!.isEmpty {

                    let fullnameQuery = PFUser.query()
                    fullnameQuery?.whereKey("fullname", matchesRegex: "(?i)" + self.searchBar.text!)
                    fullnameQuery?.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            
                            // found related objects
                            for object in objects! {
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            }
                            
                            // reload
                            self.tableView.reloadData()
                            
                        }
                    })
                }
                
                // clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.usernameArray.append(object.object(forKey: "username") as! String)
                    self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                }
                
                // reload
                self.tableView.reloadData()
                
            }
        })
        
        return true
    }
    
    
    // tapped on the searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // hide collectionView when started search
        collectionView.isHidden = true
        tapBar?.isHidden = true
		featuredButton.isHidden = true
		popularButton.isHidden = true
		
        
        // show cancel button
        searchBar.showsCancelButton = true
	
		isShowingUsers = true
		
        // call functions
        loadUsers()
    }
    
    
    // clicked cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		
		
		isShowingUsers = false
		
        // unhide collectionView when tapped cancel button
        collectionView.isHidden = false
        tapBar?.isHidden = false
        featuredButton.isHidden = false
        popularButton.isHidden = false
		
        showingFeatured = false
        
        // dismiss keyboard
        searchBar.resignFirstResponder()
        
        // hide cancel button
        searchBar.showsCancelButton = false
        
        // reset text
        searchBar.text = ""
        
        // reset shown users
        loadUsers()
    }
    
    
    
    // TABLEVIEW CODE
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    // cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }

    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! followersCell

        // hide follow button
        cell.followBtn.isHidden = true
        
        // connect cell's objects with received infromation from server
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            }
        }

        return cell
    }

    
    // selected tableView cell - selected user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // calling cell again to call cell data
        let cell = tableView.cellForRow(at: indexPath) as! followersCell
        
        // if user tapped on his name go home, else go guest
        if cell.usernameLbl.text! == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameLbl.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
	
	/*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	
		if isShowingUsers {
		
			
			//Show the button.
			let button = UIButton(type: .system)
			button.setTitle("Featured Users", for: .normal)
			button.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 80)
			button.addTarget(self, action: #selector(usersVC.profilesButtonTapped), for: .touchUpInside)
			
			return button
		}
	
		return nil
	}
	*/
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
	
		if isShowingUsers {
			
			return 0
		}
	
		return 0
	}
	
	@objc func profilesButtonTapped() {
	
		
		showingFeatured = true
		self.searchBar.becomeFirstResponder()
	}
	
	@objc func popularButtonTapped() {
		
		showingPopular = true
		self.searchBar.becomeFirstResponder()
	}
    
    // COLLECTION VIEW CODE
    func collectionViewLaunch() {
     
        // layout of collectionView
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        // item size
        layout.itemSize = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        
        // direction of scrolling
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        // define frame of collectionView
        let frame = CGRect(x: 0, y: 120, width: self.view.frame.size.width, height: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - 60)
        
        // declare collectionView
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
		
		
		
        //Create the switch bar.
		tapBar = HMSegmentedControl(sectionTitles: ["TMA", "VINE"])
		tapBar?.selectionIndicatorColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
		tapBar?.selectionStyle = .fullWidthStripe
		tapBar?.selectionIndicatorLocation = .down
	
		tapBar?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 60)
		tapBar?.addTarget(self, action: #selector(usersVC.barTapped), for: .valueChanged)
		tapBar?.selectedSegmentIndex = 0
		tapBar?.backgroundColor = UIColor.white
		tapBar?.tintColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
		self.view.addSubview(tapBar!)
		self.view.bringSubview(toFront: tapBar!)
		
		//Show the button.
		featuredButton = UIButton(type: .system)
		featuredButton.setTitle("FEATURED USERS", for: .normal)
		featuredButton.frame = CGRect(x: 0.0, y: (tapBar?.frame.size.height)!, width: self.view.frame.size.width / 2, height: 60)
		featuredButton.addTarget(self, action: #selector(usersVC.profilesButtonTapped), for: .touchUpInside)
		featuredButton.tintColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
		featuredButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		
		self.view.addSubview(featuredButton)
		self.view.bringSubview(toFront: featuredButton)
		
		//Show the button.
		popularButton = UIButton(type: .system)
		popularButton.setTitle("POPULAR", for: .normal)
		popularButton.frame = CGRect(x: self.view.frame.size.width / 2, y: (tapBar?.frame.size.height)!, width: self.view.frame.size.width / 2, height: 60)
		popularButton.addTarget(self, action: #selector(usersVC.profilesButtonTapped), for: .touchUpInside)
		popularButton.tintColor = #colorLiteral(red: 0.8393908514, green: 0.2403571044, blue: 0.1491680062, alpha: 1)
		popularButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		self.view.addSubview(popularButton)
		self.view.bringSubview(toFront: popularButton)
		
        // define cell for collectionView
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
		
		self.currentType = "tma"
		self.tableView.reloadData()
		
        // call function to load posts
		loadPosts(type: "tma")
    }
	
	@objc func barTapped(_ segmentedControl: UISegmentedControl) {
		
		
    	switch segmentedControl.selectedSegmentIndex {
			case 0:
				
				//Images
				
				self.currentType = "tma"
				self.mediaArray = []
				self.collectionView.setContentOffset(CGPoint.zero, animated: false)
				self.collectionView.reloadData()
				loadPosts(type: "tma")
				
				let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
				let underlineAttributedString = NSAttributedString(string: "TMA", attributes: underlineAttribute)
				
			
				
			    break
			case 1:
				
				//Videos
				self.currentType = "vine"
				self.collectionView.setContentOffset(CGPoint.zero, animated: false)
				self.mediaArray = []
				self.collectionView.reloadData()
				loadPosts(type: "vine")
				
				let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
				let underlineAttributedString = NSAttributedString(string: "VINE", attributes: underlineAttribute)
				
				
				break
			default:
				
				break
		}
	}
    
    
    // cell line spasing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // cell inter spasing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // cell numb
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaArray.count
    }
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
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
    
    // cell's selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // take relevant unique id of post to load post in postVC
        postuuid.append(uuidArray[indexPath.row])
        
        // present postVC programmaticaly
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
	

    
    // load posts
    func loadPosts(type: String) {
		
		self.mediaArray = []
		self.tableView.reloadData()
		
		
        let query = PFQuery(className: "posts")
        query.limit = page
		
		if type == "tma" {
		
        	query.whereKey("type", containedIn: ["image", "video"])
			
        } else {
			
			//Only vine videos.
			
			
			query.whereKey("duration", lessThan: 8)
			query.whereKey("type", equalTo: "video")
		}
		
	
		
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
				
				
                // clean up
                self.picArray.removeAll(keepingCapacity: false)
                self.mediaArray = []
                self.uuidArray = []
                self.typeArray = []
                
                // found related objects
                for object in objects! {
					
                	self.typeArray.append(object.object(forKey: "type") as! String)
                    self.mediaArray.append(object.object(forKey: "media") as! PFFile)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                }
				
                print(self.mediaArray.count)
                
                // reload collectionView to present images
                self.collectionView.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    // scrolled down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // scroll down for paging
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
			self.loadMore(type: self.currentType)
        }
    }
    
    // pagination
    func loadMore(type: String) {
        
        // if more posts are unloaded, we wanna load them
        if page <= picArray.count {
            
            // increase page size
            page = page + 15
            
            // load additional posts
            let query = PFQuery(className: "posts")
            query.limit = page
            query.whereKey("contentType", equalTo: type)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.picArray.removeAll(keepingCapacity: false)
                    self.uuidArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.picArray.append(object.object(forKey: "media") as! PFFile)
                        self.uuidArray.append(object.object(forKey: "uuid") as! String)
						
                    }
                    
                    // reload collectionView to present loaded images
                    self.collectionView.reloadData()
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        }
        
    }
    
}
