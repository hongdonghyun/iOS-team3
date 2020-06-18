//
//  AlarmManager.swift
//  MarketBroccoli
//
//  Created by macbook on 2020/04/17.
//  Copyright © 2020 Team3. All rights reserved.
//

import UIKit

class KurlyNotification {
  static let shared = KurlyNotification()
  
  enum NotiType {
    case warning
    case notice
  }
  
  private let warningLabel = UILabel().then {
    $0.backgroundColor = .systemPink
    $0.textColor = .white
    $0.layer.cornerRadius = 5
    $0.layer.masksToBounds = true
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 20, weight: .bold)
  }
  
  private let notificationLabel = UILabel().then {
    $0.backgroundColor = .white
    $0.textColor = .kurlyPurple1
    $0.layer.cornerRadius = 5
    $0.layer.masksToBounds = true
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 20, weight: .bold)
  }
  
  private let shadowView = UIView().then {
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.6
    $0.layer.shadowOffset = .zero
    $0.layer.shadowRadius = 5
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.masksToBounds = false
  }
  
  private var activityIndicatorView = UIActivityIndicatorView()
  
  func show(text: String, type: NotiType) {
    let beforeShowLabel: UILabel?
    switch type {
    case .notice:
      beforeShowLabel = notificationLabel
    case .warning:
      beforeShowLabel = warningLabel
    }
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    guard let window = appDelegate.window,
    let showLabel = beforeShowLabel
    else { return }
    
    showLabel.text = text
    window.addSubview(showLabel)
    
    showLabel.snp.makeConstraints {
      $0.bottom.equalTo(window.snp.top)
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.88)
      $0.height.equalTo(54)
    }
    
    activityIndicatorView.isHidden = false
    activityIndicatorView.startAnimating()

    UIView.animate(withDuration: 0.4) {
      showLabel.transform = .init(translationX: 0, y: 100)
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
      UIView.animateKeyframes(withDuration: 0.4, delay: 0, animations: {
        showLabel.transform = .identity
      }, completion: { _ in
        showLabel.removeFromSuperview()
      })
    }
  }
  private init() { }
}
