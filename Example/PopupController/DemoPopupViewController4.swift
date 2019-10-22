//
//  DemoPopupViewController4.swift
//  PopupController
//
//  Created by omatty198 on 2017/01/12.
//  Copyright © 2017年 Daisuke Sato. All rights reserved.
//

import UIKit

final class DemoPopupViewController4: UIViewController {

    var closeHandler: (() -> Void)?

    class func instance() -> DemoPopupViewController4 {
        let storyboard = UIStoryboard(name: "DemoPopupViewController4", bundle: nil)
        if let popupVC = storyboard.instantiateInitialViewController() as? DemoPopupViewController4 {
            return popupVC
        } else {
            fatalError("Unable to get storyboard")
        }
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layer.cornerRadius = 4
    }

    // MARK: - Button Action
    @IBAction func closeTapped() {
        closeHandler?()
    }
}

extension DemoPopupViewController4: PopupContentViewController {

    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 80)
    }

}
