//
//  ViewController.swift
//  PopupController
//
//  Created by 佐藤 大輔 on 2/4/16.
//  Copyright © 2016 Daisuke Sato. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func didTapButton(sender: AnyObject) {
        let popup = PopupController.create(self)
        popup.animation = .FadeIn
        
        let container = DemoPopupViewController1.instance()
        container.closeHandler = { _ in
            popup.closePopup(nil)
        }
        popup.presentPopupController(container, completion: nil)
    }

    @IBAction func didTapButton2(sender: AnyObject) {
        let popup = PopupController.create(self)
        popup.animation = .SlideUp
        popup.scrollable = false
        popup.backgroundStyle = .BlackFilter(alpha: 0.6)
        
        let container = DemoPopupViewController2.instance()
        popup.presentPopupController(container, completion: nil)
    }
    
    @IBAction func didTapButton3(sender: AnyObject) {
        let popup = PopupController.create(self)
        popup.animation = .FadeIn
        
        let container = DemoPopupViewController3.instance()
        container.closeHandler = { _ in
            popup.closePopup(nil)
        }
        popup.presentPopupController(container, completion: nil)
    }
}

