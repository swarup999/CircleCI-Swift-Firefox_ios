//
//  CredentialWelcomeViewController.swift
//  CredentialProvider
//
//  Created by raluca.iordan on 6/16/21.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import UIKit

class CredentialWelcomeViewController: UIViewController {

    @IBOutlet weak var taglineLabel: UILabel! {
        didSet {
            taglineLabel.text = .WelcomeViewTitle
        }
    }
    
}
