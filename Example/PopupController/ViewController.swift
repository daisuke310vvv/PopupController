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
        PopupController
            .create(self)
            .show(DemoPopupViewController1.instance())
    }
    
    @IBAction func didTapButton2(sender: AnyObject) {
        PopupController
            .create(self)
            .customize(
                [
                    .Animation(.SlideUp),
                    .Scrollable(false),
                    .BackgroundStyle(.BlackFilter(alpha: 0.7))
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
    
    @IBAction func didTapButton3(sender: AnyObject) {
        let popup = PopupController
            .create(self)
            .customize(
                [
                    .Layout(.Center),
                    .Animation(.FadeIn),
                    .BackgroundStyle(.BlackFilter(alpha: 0.8)),
                    .DismissWhenTaps(true),
                    .Scrollable(true)
                ]
            )
            .didShowHandler { popup in
                print("showed popup!")
            }
            .didCloseHandler { popup in
                print("closed popup!")
        }
        
        let container = DemoPopupViewController3.instance()
        container.closeHandler = { _ in
            popup.dismiss()
        }
        
        popup.show(container)
    }

    @IBAction func didTapButton4(sender: AnyObject) {
        let popup = PopupController
            .create(self)
            .customize(
                [
                    .Layout(.Top),
                    .Animation(.SlideDown),
                    .Scrollable(false),
                    .DismissWhenTaps(false),
                    .BackgroundStyle(.BlackFilter(alpha: 0))
                ]
            )
            .didShowHandler { popup in
                print("showed popup!")
            }
            .didCloseHandler { _ in
                print("closed popup!")
            }

        let container = DemoPopupViewController4.instance()
        container.closeHandler = { _ in
            popup.dismiss()
        }

        popup.show(container)
    }
}

