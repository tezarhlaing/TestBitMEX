//
//  ViewController.swift
//  PrestoLabs
//  Created by tzh.
//

import UIKit

class ViewController: AppViewController {
    // MARK: - Properties
       
    // WebSocket connection for communication
    private let webSocketConnection = WebSocketConnection.shared
    
    // List of view controllers to be displayed
    private var viewControllersList: [UIViewController] = []
    
    // Index of the currently displayed view controller
    private var currentIndex: Int = 0
    
    // UIPageViewController to handle page navigation
    // Note: Use lazy loading as it's not immediately required after initialization
    private lazy var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageVC.dataSource = self
        pageVC.delegate = self
        return pageVC
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPageView()
       
    }
    
    // MARK: - Page View Setup

    private func setUpPageView() {
        segmentControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)

        addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        //self.pageViewController.view.frame = view.bounds
        self.pageViewController.didMove(toParent: self)
        
        let oderBookVC = OrderBookViewController(topic: "orderBookL2:XBTUSD", webSocketConnection: self.webSocketConnection)
        let recentTradeVC = RecentTradeViewController(topic: "trade:XBTUSD", webSocketConnection: self.webSocketConnection)
        self.viewControllersList = [oderBookVC, recentTradeVC]
        pageViewController.setViewControllers([oderBookVC], direction: .forward, animated: true, completion: nil)
        
        
        let guide = self.view.safeAreaLayoutGuide
        self.segmentControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentControl)
        NSLayoutConstraint.activate([
            segmentControl.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            segmentControl.topAnchor.constraint(equalTo: guide.topAnchor)
        ])
        
    }
    // MARK: - Segmented Control Action

    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if index < viewControllersList.count {
            self.pageViewController.setViewControllers([viewControllersList[index]], direction:  index > currentIndex ? .forward : .reverse, animated: true, completion: nil)
            self.currentIndex = index
                                                
        }
    }
        
}

// MARK: - UIPageViewControllerDataSource and UIPageViewControllerDelegate

extension ViewController : UIPageViewControllerDelegate , UIPageViewControllerDataSource {
    // Implementation of UIPageViewControllerDataSource and UIPageViewControllerDelegate methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.viewControllersList.firstIndex(of: viewController), index > 0 else {
              return nil
          }
          return viewControllersList[index - 1]
    }

      func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
          guard let index = viewControllersList.firstIndex(of: viewController), index < viewControllersList.count - 1 else {
              return nil
          }
          return viewControllersList[index + 1]
      }

      func presentationCount(for pageViewController: UIPageViewController) -> Int {
          return viewControllersList.count
      }

      func presentationIndex(for pageViewController: UIPageViewController) -> Int {
          return currentIndex
      }

      func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
          if let index = viewControllersList.firstIndex(of: pendingViewControllers.first!) {
              currentIndex = index
              self.segmentControl.selectedSegmentIndex = currentIndex

          }
      }
    
   

}
