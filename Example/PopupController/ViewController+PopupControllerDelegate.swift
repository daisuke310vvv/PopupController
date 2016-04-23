//
//  ViewController+PopupControllerDelegate.swift
//  PopupController
//
//  Created by Tito on 23/04/16.
//  Copyright © 2016 Daisuke Sato. All rights reserved.
//

import UIKit

extension ViewController: PopupControllerDelegate {

    func popupControllerDidClose() -> Void {
        print("Popup controller did close")
    }

    func popupControllerDidShow() -> Void {
        print("Popup controller did show")
    }

}

