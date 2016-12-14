//
//  DemoPopupViewController4.swift
//  PopupController
//
//  Created by omatty198 on 2016/12/14.
//  Copyright © 2016年 Daisuke Sato. All rights reserved.
//

import UIKit

final class DemoPopupViewController4: UIViewController {

    var closeHandler: (() -> Void)?

    class func instance() -> DemoPopupViewController4 {
        let storyboard = UIStoryboard(name: "DemoPopupViewController4", bundle: nil)
        return storyboard.instantiateInitialViewController() as! DemoPopupViewController4
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layer.cornerRadius = 4
    }

    // MARK: - Button Action

    @IBAction func tapped() {
        closeHandler?()
    }
}

extension DemoPopupViewController4: PopupContentViewController {

    func sizeForPopup(popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().bounds.width, 64)
    }
}
