//
//  ViewController.swift
//  NotesWithFirebaseDatabase
//
//  Created by David Chin on 05/08/2016.
//  Copyright © 2016 Dakerr Consulting. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        post()
    }
    
    func post() {
        let title = "Title"
        let message = "Message"
        
        let post: [String: AnyObject] = ["title": title,
                                         "message": message]
        
        let databaseRef = FIRDatabase.database().reference()
        
        databaseRef.child("Posts").childByAutoId().setValue(post)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

