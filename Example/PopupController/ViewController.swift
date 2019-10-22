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
    }

    @IBAction func didTapButton(_ sender: AnyObject) {
        PopupController
            .create(self)
            .show(DemoPopupViewController1.instance())
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
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
            .didShowHandler { _ in
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
            .didShowHandler { _ in
                print("showed popup!")
            }
            .didCloseHandler { _ in
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
            .didShowHandler { _ in
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
