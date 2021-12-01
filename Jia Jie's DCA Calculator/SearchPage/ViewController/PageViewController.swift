//
//  PageViewController.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 6/11/21.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var collection: [UIViewController]?
    var coordinator: PageCoordinator?
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = collection?.firstIndex(of: viewController), index > 0 else { return nil }
        
        print("swipe right")
        return collection![index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = collection?.firstIndex(of: viewController), index < collection!.count - 1 else { return nil }
        print("swipe left")
        return collection![index + 1]
    }
    
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 5
        pageControl.backgroundColor = .systemBlue
        return pageControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pageControl)
        pageControl.frame = view.frame
        pageControl.activateConstraints(reference: view, constraints: [.bottom(), .leading()], identifier: "pageControl")
        delegate = self
        dataSource = self
        
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
