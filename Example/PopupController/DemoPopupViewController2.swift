//
//  DemoPopupViewController2.swift
//  PopupController
//
//  Created by 佐藤 大輔 on 2/4/16.
//  Copyright © 2016 Daisuke Sato. All rights reserved.
//

import UIKit

class DemoPopupViewController2: UIViewController, PopupContentViewController, UITableViewDataSource {

    var fruits = [
        ("Apple", UIColor.red),
        ("Banana", UIColor.yellow),
        ("Grape", UIColor.purple),
        ("Orange", UIColor.orange)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layer.cornerRadius = 4
    }

    class func instance() -> DemoPopupViewController2 {
        let storyboard = UIStoryboard(name: "DemoPopupViewController2", bundle: nil)
        if let popupVC = storyboard.instantiateInitialViewController() as? DemoPopupViewController2 {
            return popupVC
        } else {
            fatalError("Unable to get storyboard")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 300, height: 500)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fruits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DemoPopup2Cell {
            let (text, color) = fruits[(indexPath as NSIndexPath).row]
            cell.colorView.backgroundColor = color
            cell.titleLabel.text = text
            return cell
        } else {
            return DemoPopup2Cell(style: .default, reuseIdentifier: "cell")
        }
    }

}

class DemoPopup2Cell: UITableViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
}
