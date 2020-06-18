//
//  RecommendationView.swift
//  MarketBroccoli
//
//  Created by Hongdonghyun on 2020/03/20.
//  Copyright © 2020 Team3. All rights reserved.
//

import UIKit
import Then
import SnapKit

// MARK: - 컬리추천
class RecommendationView: UITableView {
  private var offsetArray: [Int: CGFloat] = [:]
  private var homeImageModel: HomeImages? {
    didSet {
      self.reloadSections(IndexSet(integer: 0), with: .none)
    }
    willSet {
      ObserverManager.shared.post(observerName: .bannerShared, object: newValue)
    }
  }
  private var recommendModel: [RequestHome: HomeItems]? = [RequestHome.recommendation: HomeItems()] {
    didSet {
      self.reloadSections(IndexSet(integer: 1), with: .none)
    }
  }
  private var discountModel: [RequestHome: HomeItems]? = [RequestHome.discount: HomeItems()] {
    didSet {
      self.reloadSections(IndexSet(integer: 3), with: .none)
    }
  }
  private var MDModel: MDItems? {
    didSet {
      self.reloadSections(IndexSet(integer: 4), with: .none)
    }
  }
  private var newModel: [RequestHome: HomeItems]? = [RequestHome.new: HomeItems()] {
    didSet {
      self.reloadSections(IndexSet(integer: 5), with: .none)
    }
  }
  private var bestModel: [RequestHome: HomeItems]? = [RequestHome.best: HomeItems()] {
    didSet {
      self.reloadSections(IndexSet(integer: 6), with: .none)
    }
  }
  
  override init(frame: CGRect, style: UITableView.Style) {
    super.init(frame: frame, style: style)
    setupAttr()
    setupUI()
    dataRequest() {}
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - ACTIONS
extension RecommendationView {
  @objc private func scrollToTop(_ sender: UIButton) {
    self.setContentOffset(.zero, animated: true)
  }
  
  private func dataRequest(_ success: @escaping () -> ()) {
    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }
      [RequestHome.recommendation, RequestHome.new, RequestHome.best, RequestHome.discount].forEach { endPoint in
        RequestManager.shared.homeRequest(url: endPoint, method: .get, count: 8) { res in
          switch res {
          case .success(let data):
            switch endPoint {
            case .recommendation: self.recommendModel?[endPoint] = data
            case .new: self.newModel?[endPoint] = data
            case .best: self.bestModel?[endPoint] = data
            case .discount: self.discountModel?[endPoint] = data
            default:
              print("Error")
            }
          case .failure(let error):
            print("error :", error.localizedDescription)
          }
        }
      }
    }
    RequestManager.shared.MDRequest {
      switch $0 {
      case .success(let data):
        self.MDModel = data
      case .failure(let error):
        print("MD error :", error.localizedDescription)
      }
    }
    RequestManager.shared.homeImageRequest {
      switch $0 {
      case .success(let data):
        self.homeImageModel = data
      case .failure:
        KurlyNotification.shared.show(text: "잠시후 다시시도하세요.", type: .warning)
      }
    }
    success()
  }
  
  @objc private func refresh() {
    dataRequest() {
      self.refreshControl?.endRefreshing()
    }
  }
}

// MARK: - UI
extension RecommendationView {
  private func setupAttr() {
    let refreshControl = UIRefreshControl().then {
      $0.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    self.refreshControl = refreshControl
    self.separatorStyle = .none
    self.dataSource = self
    self.delegate = self
    self.allowsSelection = false
    self.register(cell: HomeBannerTableCell.self)
    self.register(cell: HomeOfferTableCell.self)
    self.register(cell: HomeEventTableCell.self)
    self.register(cell: HomeMDTableCell.self)
    self.register(cell: EasterEggTableCell.self)
  }
  
  private func setupUI() {
    let safeArea = self.safeAreaLayoutGuide
    let scrollToTopBtn = UIButton(type: .system).then {
      $0.addTarget(self, action: #selector(scrollToTop(_:)), for: .touchUpInside)
      $0.backgroundColor = .white
      $0.tintColor = .black
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.kurlyGray2.cgColor
      $0.layer.cornerRadius = 25
      $0.setImage(UIImage(systemName: "arrow.up"), for: .normal)
    }
    self.addSubview(scrollToTopBtn)
    scrollToTopBtn.snp.makeConstraints {
      $0.bottom.trailing.equalTo(safeArea).offset(-20)
      $0.width.height.equalTo(50)
    }
  }
}

// MARK: - Delegate
extension RecommendationView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let tableViewCell = cell as? HomeOfferTableCell else { return }
    tableViewCell.offset = offsetArray[indexPath.section] ?? 0
  }
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let tableViewCell = cell as? HomeOfferTableCell else { return }
    offsetArray[indexPath.section] = tableViewCell.offset
  }
}

// MARK: - DataSource
extension RecommendationView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int { 8 }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      guard let model = homeImageModel else { return UITableViewCell() }
      let cell = tableView.dequeue(HomeBannerTableCell.self)
      cell.configure(items: model)
      return cell
    case 1:
      guard let model = recommendModel else { return UITableViewCell() }
      let cell = tableView.dequeue(HomeOfferTableCell.self)
      cell.configure(cellTitle: "이 상품 어때요? >", items: model)
      return cell
    case 2:
      return tableView.dequeue(HomeEventTableCell.self)
    case 3:
      guard let model = discountModel else { return UITableViewCell() }
      let cell = tableView.dequeue(HomeOfferTableCell.self)
      cell.configure(cellTitle: "알뜰 상품 >", items: model)
      return cell
    case 4:
      guard let model = MDModel else { return UITableViewCell() }
      let cell = tableView.dequeue(HomeMDTableCell.self)
      cell.configure(items: model)
      return cell
    case 5:
      guard let model = newModel else { return UITableViewCell() }
      let cell = tableView.dequeue(HomeOfferTableCell.self)
      cell.configure(cellTitle: "오늘의 신상품 >", subtitle: "매일 정오, 컬리의 새로운 상품을 만나보세요", items: model)
      return cell
    case 6:
      guard let model = bestModel else { return UITableViewCell() }
      let cell = tableView.dequeue(HomeOfferTableCell.self)
      cell.configure(cellTitle: "지금 가장 핫한 상품 >", items: model)
      return cell
    case 7:
      let cell = tableView.dequeue(EasterEggTableCell.self)
      return cell
    default:
      return UITableViewCell()
    }
  }
}
