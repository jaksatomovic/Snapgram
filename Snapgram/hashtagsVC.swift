//
//  hashtagsVC.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


var hashtag = [String]()

class hashtagsVC: UICollectionViewController {
    
    // UI objects
    var refresher : UIRefreshControl!
    var page : Int = 24
    
    // arrays to hold data from server
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var filterArray = [String]()
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // be able to pull down even if few post
        self.collectionView?.alwaysBounceVertical = true
        
        // title at the top
        self.navigationItem.title = "#" + "\(hashtag.last!.uppercased())"
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(hashtagsVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hashtagsVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(hashtagsVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // call function of loading hashtags
        loadHashtags()
    }
    
    
    // back function
    func back(_ sender : UIBarButtonItem) {
        
        // push back
        self.navigationController?.popViewController(animated: true)
        
        // clean hashtag or deduct the last guest userame from guestname = Array
        if !hashtag.isEmpty {
            hashtag.removeLast()
        }
    }
    
    
    // refreshing func
    func refresh() {
        loadHashtags()
    }

    
    // load hashtags function
    func loadHashtags() {
                
        // STEP 1. Find poss related to hashtags
        let hashtagQuery = PFQuery(className: "hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        hashtagQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.filterArray.removeAll(keepingCapacity: false)
                
                // store related posts in filterArray
                for object in objects! {
                    self.filterArray.append(object.value(forKey: "to") as! String)
                }
                
                //STEP 2. Find posts that have uuid appended to filterArray
                let query = PFQuery(className: "posts")
                query.whereKey("uuid", containedIn: self.filterArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.picArray.removeAll(keepingCapacity: false)
                        self.uuidArray.removeAll(keepingCapacity: false)
                        
                        // find related objects
                        for object in objects! {
                            self.picArray.append(object.value(forKey: "pic") as! PFFile)
                            self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        }
                        
                        // reload
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                        
                    } else {
                        print(error?.localizedDescription)
                    }
                })
            } else {
                print(error?.localizedDescription)
            }
        })
        
    }
    

    // scrolled down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 3 {
            loadMore()
        }
    }
    
    
    // pagination
    func loadMore() {
        
        // if posts on the server are more than shown
        if page <= uuidArray.count {
            
            // increase page size
            page = page + 15
            
            // STEP 1. Find poss related to hashtags
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.filterArray.removeAll(keepingCapacity: false)
                    
                    // store related posts in filterArray
                    for object in objects! {
                        self.filterArray.append(object.value(forKey: "to") as! String)
                    }
                    
                    //STEP 2. Find posts that have uuid appended to filterArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("uuid", containedIn: self.filterArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.picArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            
                            // find related objects
                            for object in objects! {
                                self.picArray.append(object.value(forKey: "pic") as! PFFile)
                                self.uuidArray.append(object.value(forKey: "uuid") as! String)
                            }
                            
                            // reload
                            self.collectionView?.reloadData()
                            
                        } else {
                            print(error?.localizedDescription)
                        }
                    })
                } else {
                    print(error?.localizedDescription)
                }
            })
            
        }
        
    }
    
    
    // cell numb
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
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
        
        // get picture from the picArray
        picArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            }
        }
        
        return cell
    }

    
    // go post
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // send post uuid to "postuuid" variable
        postuuid.append(uuidArray[(indexPath as NSIndexPath).row])
        
        // navigate to post view controller
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }

}
