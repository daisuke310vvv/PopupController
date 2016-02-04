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
        return storyboard.instantiateViewControllerWithIdentifier("DemoPopupViewController3") as! DemoPopupViewController3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let storyboard = UIStoryboard(name: "DemoPopupViewController3", bundle: nil)
        let container1 = storyboard.instantiateViewControllerWithIdentifier("DemoPopupContainer1")
        let container2 = storyboard.instantiateViewControllerWithIdentifier("DemoPopupContainer2")
        let container3 = storyboard.instantiateViewControllerWithIdentifier("DemoPopupContainer3")
        
        container1.view.frame = UIScreen.mainScreen().bounds
        container2.view.frame = UIScreen.mainScreen().bounds
        container2.view.frame.origin.x = UIScreen.mainScreen().bounds.width
        container3.view.frame = UIScreen.mainScreen().bounds
        container3.view.frame.origin.x = UIScreen.mainScreen().bounds.width * 2
        
        self.addChildViewController(container1)
        scrollView.addSubview(container1.view)
        container1.didMoveToParentViewController(self)
        
        self.addChildViewController(container2)
        scrollView.addSubview(container2.view)
        container2.didMoveToParentViewController(self)
        
        self.addChildViewController(container3)
        scrollView.addSubview(container3.view)
        container3.didMoveToParentViewController(self)
        
        scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width * 3, UIScreen.mainScreen().bounds.height)
        
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.pagingEnabled = true
    }
    
    @IBAction func didTapCloseButton(sender: AnyObject) {
        closeHandler?()
    }
}

extension DemoPopupViewController3: PopupContentViewController {
    func sizeForPopup(popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return UIScreen.mainScreen().bounds.size
    }
}

extension DemoPopupViewController3: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(floor((scrollView.contentOffset.x / scrollView.frame.width)))
    }
}