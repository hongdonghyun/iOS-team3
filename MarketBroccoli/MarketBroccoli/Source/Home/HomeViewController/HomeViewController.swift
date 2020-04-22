//
//  HomeViewController.swift
//  MarketBroccoli
//
//  Created by Hongdonghyun on 2020/03/20.
//  Copyright © 2020 Team3. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
  let rootView = HomeRootView()
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tabBarController?.delegate = self
    self.addNavigationBarCartButton()
    self.setupBroccoliNavigationBar(title: "마켓브로콜리")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    ObserverManager.shared.registerObserver(
      target: self, selector: #selector(receiveNotification(_:)), observerName: .productTouched, object: nil)
    ObserverManager.shared.registerObserver(
      target: self, selector: #selector(receiveNotificationShowAll(_:)), observerName: .showAllBtnTouched, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    ObserverManager.shared.resignObserver(
      target: self,
      observerName: .productTouched,
      object: nil)
    ObserverManager.shared.resignObserver(
      target: self,
      observerName: .showAllBtnTouched,
      object: nil)
  }
}

// MARK: - ACTIONS
extension HomeViewController {
  @objc private func receiveNotification(_ notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: Int],
      let ID = userInfo["productId"] else { return }
    
    let detailVC = DetailViewController()
    detailVC.configure(productId: ID)
    let barBtnItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    
    detailVC.hidesBottomBarWhenPushed = true
    navigationItem.backBarButtonItem = barBtnItem
    navigationController?.pushViewController(detailVC, animated: true)
  }
  
  @objc private func receiveNotificationShowAll(_ notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: Any],
      let requestKey = userInfo["requestKey"] as? RequestHome
      else { return }
    let showAllVC = ShowAllProductViewController()
    
    showAllVC.hidesBottomBarWhenPushed = true
    showAllVC.configure(requestKey: requestKey)
    navigationController?.pushViewController(showAllVC, animated: true)
  }
}

extension HomeViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    if tabBarController.selectedIndex == 0 {
      guard let navi = viewController as? UINavigationController,
        let VC = navi.viewControllers[0] as? HomeViewController else { return }
      
      let scrollView = VC.rootView.scrollView
      
      if scrollView.contentOffset.x != 0 {
        scrollView.setContentOffset(.zero, animated: true)
      } else {
        guard let recommendationView = scrollView.subviews.first(
          where: { $0 as? RecommendationView != nil }) as? RecommendationView
          else { return }
        if recommendationView.contentOffset.y != 0 {
          recommendationView.setContentOffset(.zero, animated: true)
        }
      }
    }
  }
}
