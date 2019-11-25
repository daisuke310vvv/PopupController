//
//  DemoPopupViewController1.swift
//  PopupController
//
//  Created by 佐藤 大輔 on 2/4/16.
//  Copyright © 2016 Daisuke Sato. All rights reserved.
//

import UIKit

class DemoPopupViewController1: UIViewController, PopupContentViewController {

    var closeHandler: (() -> Void)?

    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.borderColor = UIColor(red: 242/255, green: 105/255, blue: 100/255, alpha: 1.0).cgColor
            button.layer.borderWidth = 1.5
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame.size = CGSize(width: 300, height: 300)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    class func instance() -> DemoPopupViewController1 {
        let storyboard = UIStoryboard(name: "DemoPopupViewController1", bundle: nil)
        if let popupVC = storyboard.instantiateInitialViewController() as? DemoPopupViewController1 {
            return popupVC
        } else {
            fatalError("Unable to get storyboard")
        }
    }

    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 300, height: 300)
    }

    @IBAction func tappedCloseButton(_ sender: AnyObject) {
        closeHandler?()
    }

}
