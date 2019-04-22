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
        self.view.backgroundColor = UIColor.white
    }
    
    @IBAction func didTapButton(_ sender: AnyObject) {
        PopupController
            .create(self)
            .show(DemoPopupViewController1.instance())
    }
    
    @IBAction func didTapButton2(_ sender: AnyObject) {
        PopupController
            .create(self)
            .customize(
                [
                    .animation(.slideUp),
                    .scrollable(false),
                    .backgroundStyle(.blackFilter(alpha: 0.7))
                ]
            )
            .didShowHandler { popup in
                print("showed popup!")
            }
            .didCloseHandler { _ in
                print("closed popup!")
            }
            .show(DemoPopupViewController2.instance())
    }
    
    @IBAction func didTapButton3(_ sender: AnyObject) {
        let popup = PopupController
            .create(self)
            .customize(
                [
                    .layout(.center),
                    .animation(.fadeIn),
                    .backgroundStyle(.blackFilter(alpha: 0.8)),
                    .dismissWhenTaps(true),
                    .scrollable(true)
                ]
            )
            .didShowHandler { popup in
                print("showed popup!")
            }
            .didCloseHandler { popup in
                print("closed popup!")
        }
        
        let container = DemoPopupViewController3.instance()
        container.closeHandler = {
            popup.dismiss()
        }
        
        popup.show(container)
    }

    @IBAction func didTapButton4(_ sender: AnyObject) {
        let popup = PopupController
            .create(self)
            .customize(
                [
                    .layout(.top),
                    .animation(.slideDown),
                    .scrollable(false),
                    .dismissWhenTaps(false),
                    .backgroundStyle(.blackFilter(alpha: 0))
                ]
            )
            .didShowHandler { popup in
                print("showed popup!")
            }
            .didCloseHandler { _ in
                print("closed popup!")
        }

        let container = DemoPopupViewController4.instance()
        container.closeHandler = {
            popup.dismiss()
        }

        popup.show(container)
    }
}

