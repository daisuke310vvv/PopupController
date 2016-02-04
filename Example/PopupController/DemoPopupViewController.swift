//
//  DemoPopupViewController.swift
//  PopupController
//
//  Created by 佐藤 大輔 on 2/4/16.
//  Copyright © 2016 Daisuke Sato. All rights reserved.
//

import UIKit

class DemoPopupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blueColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    class func instance() -> DemoPopupViewController {
        let storyboard = UIStoryboard(name: "DemoPopupViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! DemoPopupViewController
    }

}

extension DemoPopupViewController: PopupContentViewController {
    func sizeForPopup(popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSizeMake(300,400)
    }
}