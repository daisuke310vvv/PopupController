//
//  DemoPopupViewController3.swift
//  PopupController
//
//  Created by 佐藤 大輔 on 2/9/16.
//  Copyright © 2016 Daisuke Sato. All rights reserved.
//

import UIKit

class DemoPopupViewController3: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var closeHandler: (() -> Void)?
    
    class func instance() -> DemoPopupViewController3 {
        let storyboard = UIStoryboard(name: "DemoPopupViewController3", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "DemoPopupViewController3") as! DemoPopupViewController3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let storyboard = UIStoryboard(name: "DemoPopupViewController3", bundle: nil)
        let container1 = storyboard.instantiateViewController(withIdentifier: "DemoPopupContainer1")
        let container2 = storyboard.instantiateViewController(withIdentifier: "DemoPopupContainer2")
        let container3 = storyboard.instantiateViewController(withIdentifier: "DemoPopupContainer3")
        
        container1.view.frame = UIScreen.main.bounds
        container2.view.frame = UIScreen.main.bounds
        container2.view.frame.origin.x = UIScreen.main.bounds.width
        container3.view.frame = UIScreen.main.bounds
        container3.view.frame.origin.x = UIScreen.main.bounds.width * 2
        
        self.addChild(container1)
        scrollView.addSubview(container1.view)
        container1.didMove(toParent: self)
        
        self.addChild(container2)
        scrollView.addSubview(container2.view)
        container2.didMove(toParent: self)
        
        self.addChild(container3)
        scrollView.addSubview(container3.view)
        container3.didMove(toParent: self)
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 3, height: UIScreen.main.bounds.height)
        
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
    }
    
    @IBAction func didTapCloseButton(_ sender: AnyObject) {
        closeHandler?()
    }
}

extension DemoPopupViewController3: PopupContentViewController {
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return UIScreen.main.bounds.size
    }
}

extension DemoPopupViewController3: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floor((scrollView.contentOffset.x / scrollView.frame.width)))
    }
}
