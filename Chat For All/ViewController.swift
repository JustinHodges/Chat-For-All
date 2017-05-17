//
//  ViewController.swift
//  Chat For All
//
//  Created by Justin Hodges on 5/17/17.
//  Copyright © 2017 Justin Hodges. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var openChat: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        openChat.layer.cornerRadius = 15
        openChat.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
