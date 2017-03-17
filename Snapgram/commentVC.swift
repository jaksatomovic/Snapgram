//
//  commentVC.swift
//  Snapgram
//
//  Created by Jaksa Tomovic on 28/11/16.
//  Copyright © 2016 Jaksa Tomovic. All rights reserved.
//

import UIKit
import Parse


var commentuuid = [String]()
var commentowner = [String]()

class commentVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // UI objects
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    var refresher = UIRefreshControl()
    
    // values for reseting UI to default
    var tableViewHeight : CGFloat = 0
    var commentY : CGFloat = 0
    var commentHeight : CGFloat = 0
    
    // arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var dateArray = [Date?]()
    
    // variable to hold keybarod frame
    var keyboard = CGRect()
    
    // page size
    var page : Int32 = 15
    

    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title at the top
        self.navigationItem.title = "COMMENTS"
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(commentVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(commentVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // catch notification if the keyboard is shown or hidden
        NotificationCenter.default.addObserver(self, selector: #selector(commentVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // disable button from the beginning
        sendBtn.isEnabled = false
        
        // call functions
        alignment()
        loadComments()
    }
    
    
    // preload func
    override func viewWillAppear(_ animated: Bool) {

        // hide bottom bar
        self.tabBarController?.tabBar.isHidden = true
        
        // hide custom tabbar button
        tabBarPostButton.isHidden = true
        
        // call keyboard
        commentTxt.becomeFirstResponder()
    }
    
    
    // postload func - launches when we about to live current VC
    override func viewWillDisappear(_ animated: Bool) {
        
        // unhide tabbar
        self.tabBarController?.tabBar.isHidden = false
        
        // unhide custom tabbar button
        tabBarPostButton.isHidden = false
    }
    
    
    // func loading when keyboard is shown
    func keyboardWillShow(notification: NSNotification) {
        
        // defnine keyboard frame size
        keyboard = ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue)!
        
        // move UI up
        UIView.animate (withDuration: 0.4) { () -> Void in
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
            self.commentTxt.frame.origin.y = self.commentY - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
            self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y
        }
    }
    
    
    // func loading when keyboard is hidden
    func keyboardWillHide(_ notification : Notification) {
        
        // move UI down
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentTxt.frame.origin.y = self.commentY
            self.sendBtn.frame.origin.y = self.commentY
        }) 
    }
    
    
    // alignment function
    func alignment() {
        
        // alignnment
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.size.height - 20)
        tableView.estimatedRowHeight = width / 5.333
        tableView.rowHeight = UITableViewAutomaticDimension
        
        commentTxt.frame = CGRect(x: 10, y: tableView.frame.size.height + height / 56.8, width: width / 1.306, height: 33)
        commentTxt.layer.cornerRadius = commentTxt.frame.size.width / 50
        
        sendBtn.frame = CGRect(x: commentTxt.frame.origin.x + commentTxt.frame.size.width + width / 32, y: commentTxt.frame.origin.y, width: width - (commentTxt.frame.origin.x + commentTxt.frame.size.width) - (width / 32) * 2, height: commentTxt.frame.size.height)
        
        
        // delegates
        commentTxt.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // assign reseting values
        tableViewHeight = tableView.frame.size.height
        commentHeight = commentTxt.frame.size.height
        commentY = commentTxt.frame.origin.y
    }
    
    
    // while writing something
    func textViewDidChange(_ textView: UITextView) {
        
        // disable button if entered no text
        let spacing = CharacterSet.whitespacesAndNewlines
        if !commentTxt.text.trimmingCharacters(in: spacing).isEmpty {
            sendBtn.isEnabled = true
        } else {
            sendBtn.isEnabled = false
        }
        
        // + paragraph
        if textView.contentSize.height > textView.frame.size.height && textView.frame.height < 130 {
            
            // find difference to add
            let difference = textView.contentSize.height - textView.frame.size.height
            
            // redefine frame of commentTxt
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            // move up tableView
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        }
        
        // - paragraph
        else if textView.contentSize.height < textView.frame.size.height {
            
            // find difference to deduct
            let difference = textView.frame.size.height - textView.contentSize.height
            
            // redefine frame of commentTxt
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            // move donw tableViwe
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
    }
    
    
    // load comments function
    func loadComments() {
        
        // STEP 1. Count total comments in order to skip all except (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground (block: { (count, error) -> Void in
            
            // if comments on the server for current post are more than (page size 15), implement pull to refresh func
            if self.page < count {
                self.refresher.addTarget(self, action: #selector(commentVC.loadMore), for: UIControlEvents.valueChanged)
                self.tableView.addSubview(self.refresher)
            }
            
            // STEP 2. Request last (page size 15) comments
            let query = PFQuery(className: "comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.usernameArray.append(object.object(forKey: "username") as! String)
                        self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                        self.commentArray.append(object.object(forKey: "comment") as! String)
                        self.dateArray.append(object.createdAt)
                        self.tableView.reloadData()
                        
                        // scroll to bottom
                        self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
                    }
                } else {
                    print(error?.localizedDescription)
                }
            })
        })
        
    }
    
    
    // pagination
    func loadMore() {
        
        // STEP 1. Count total comments in order to skip all except (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground (block: { (count, error) -> Void in
            
            // self refresher
            self.refresher.endRefreshing()
            
            // remove refresher if loaded all comments
            if self.page >= count {
                self.refresher.removeFromSuperview()
            }
            
            // STEP 2. Load more comments
            if self.page < count {
                
                // increase page to load 30 as first paging
                self.page = self.page + 15
                
                // request existing comments from the server
                let query = PFQuery(className: "comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        // find related objects
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.commentArray.append(object.object(forKey: "comment") as! String)
                            self.dateArray.append(object.createdAt)
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error?.localizedDescription)
                    }
                })
            }
            
        })
        
    }
    
    
    // clicked send button
    @IBAction func sendBtn_click(_ sender: AnyObject) {
        
        // STEP 1. Add row in tableView
        usernameArray.append(PFUser.current()!.username!)
        avaArray.append(PFUser.current()?.object(forKey: "ava") as! PFFile)
        dateArray.append(Date())
        commentArray.append(commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
        
        // STEP 2. Send comment to server
        let commentObj = PFObject(className: "comments")
        commentObj["to"] = commentuuid.last
        commentObj["username"] = PFUser.current()?.username
        commentObj["ava"] = PFUser.current()?.value(forKey: "ava")
        commentObj["comment"] = commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        commentObj.saveEventually()
        
        // STEP 3. Send #hashtag to server
        let words:[String] = commentTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        // define taged word
        for var word in words {
            
            // save #hasthag in server
            if word.hasPrefix("#") {
                
                // cut symbold
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = commentuuid.last
                hashtagObj["by"] = PFUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = commentTxt.text
                hashtagObj.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        
        // STEP 4. Send notification as @mention
        var mentionCreated = Bool()
        
        for var word in words {
            
            // check @mentions for user
            if word.hasPrefix("@") {
                
                // cut symbols
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let newsObj = PFObject(className: "news")
                newsObj["by"] = PFUser.current()?.username
                newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                newsObj["to"] = word
                newsObj["owner"] = commentowner.last
                newsObj["uuid"] = commentuuid.last
                newsObj["type"] = "mention"
                newsObj["checked"] = "no"
                newsObj.saveEventually()
                mentionCreated = true
            }
        }
        
        // STEP 5. Send notification as comment
        if commentowner.last != PFUser.current()?.username && mentionCreated == false {
            let newsObj = PFObject(className: "news")
            newsObj["by"] = PFUser.current()?.username
            newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
            newsObj["to"] = commentowner.last
            newsObj["owner"] = commentowner.last
            newsObj["uuid"] = commentuuid.last
            newsObj["type"] = "comment"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
        }
        
        
        // scroll to bottom
        self.tableView.scrollToRow(at: IndexPath(item: commentArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
        
        // STAEP 6. Reset UI
        sendBtn.isEnabled = false
        commentTxt.text = ""
        commentTxt.frame.size.height = commentHeight
        commentTxt.frame.origin.y = sendBtn.frame.origin.y
        tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
    }
    
    
    // TABLEVIEW
    // cell numb
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // declare cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! commentCell
        
        cell.usernameBtn.setTitle(usernameArray[(indexPath as NSIndexPath).row], for: UIControlState())
        cell.usernameBtn.sizeToFit()
        cell.commentLbl.text = commentArray[(indexPath as NSIndexPath).row]
        avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            cell.avaImg.image = UIImage(data: data!)
        }
        
        // calculate date
        let from = dateArray[(indexPath as NSIndexPath).row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        if difference.second! <= 0 {
            cell.dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLbl.text = "\(difference.second)s."
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLbl.text = "\(difference.minute)m."
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(difference.hour)h."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.dateLbl.text = "\(difference.day)d."
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(difference.weekOfMonth)w."
        }
        
        
        // @mention is tapped
        cell.commentLbl.userHandleLinkTapHandler = { label, handle, rang in
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
        cell.commentLbl.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "hashtagsVC") as! hashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
        }
        
        
        // assign indexes of buttons
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    
    // clicked username button
    @IBAction func usernameBtn_click(_ sender: AnyObject) {
        
        // call index of current button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! commentCell
        
        // if user tapped on his username go home, else go guest
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    
    // cell editabily
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // swipe cell for actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // call cell for calling further cell data
        let cell = tableView.cellForRow(at: indexPath) as! commentCell
        
        // ACTION 1. Delete
        let delete = UITableViewRowAction(style: .normal, title: "    ") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            // STEP 1. Delete comment from server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentLbl.text!)
            commentQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    // find related objects
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            // STEP 2. Delete #hashtag from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: commentuuid.last!)
            hashtagQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text!)
            hashtagQuery.whereKey("comment", equalTo: cell.commentLbl.text!)
            hashtagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                for object in objects! {
                    object.deleteEventually()
                }
            })
            
            // STEP 3. Delete notification: mention comment
            let newsQuery = PFQuery(className: "news")
            newsQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text!)
            newsQuery.whereKey("to", equalTo: commentowner.last!)
            newsQuery.whereKey("uuid", equalTo: commentuuid.last!)
            newsQuery.whereKey("type", containedIn: ["comment", "mention"])
            newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            
            // close cell
            tableView.setEditing(false, animated: true)
            
            // STEP 3. Delete comment row from tableView
            self.commentArray.remove(at: (indexPath as NSIndexPath).row)
            self.dateArray.remove(at: (indexPath as NSIndexPath).row)
            self.usernameArray.remove(at: (indexPath as NSIndexPath).row)
            self.avaArray.remove(at: (indexPath as NSIndexPath).row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        // ACTION 2. Mention or address message to someone
        let address = UITableViewRowAction(style: .normal, title: "    ") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            // include username in textView
            self.commentTxt.text = "\(self.commentTxt.text + "@" + self.usernameArray[(indexPath as NSIndexPath).row] + " ")"
            
            // enable button
            self.sendBtn.isEnabled = true
            
            // close cell
            tableView.setEditing(false, animated: true)
        }
        
        // ACTION 3. Complain
        let complain = UITableViewRowAction(style: .normal, title: "    ") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            // send complain to server regarding selected comment
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.current()?.username
            complainObj["to"] = cell.commentLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            complainObj.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.alert("Complain has been made successfully", message: "Thank You! We will consider your complain")
                } else {
                    self.alert("ERROR", message: error!.localizedDescription)
                }
            })
            
            // close cell
            tableView.setEditing(false, animated: true)
        }
        
        // buttons background
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete.png")!)
        address.backgroundColor = UIColor(patternImage: UIImage(named: "address.png")!)
        complain.backgroundColor = UIColor(patternImage: UIImage(named: "complain.png")!)
        
        // comment beloogs to user
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
            return [delete, address]
        }
        
        // post belongs to user
        else if commentowner.last == PFUser.current()?.username {
            return [delete, address, complain]
        }
        
        // post belongs to another user
        else  {
            return [address, complain]
        }
        
    }
    
    
    // alert action
    func alert (_ title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    // go back
    func back(_ sender : UIBarButtonItem) {
        
        // push back
        self.navigationController?.popViewController(animated: true)
        
        // clean comment uui from last holding infromation
        if !commentuuid.isEmpty {
            commentuuid.removeLast()
        }
        
        // clean comment owner from last holding infromation
        if !commentowner.isEmpty {
            commentowner.removeLast()
        }
    }

}
