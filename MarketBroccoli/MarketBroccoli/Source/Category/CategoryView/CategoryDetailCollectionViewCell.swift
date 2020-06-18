//
//  CategoryDetailCollectionViewCell.swift
//  MarketBroccoli
//
//  Created by Hailey Lee on 2020/04/17.
//  Copyright © 2020 Team3. All rights reserved.
//

import UIKit
import Alamofire

class CategoryDetailCollectionViewCell: UICollectionViewCell {
  // MARK: - Properties
  private lazy var collectionViewFlowLayout = UICollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: collectionViewFlowLayout)
    .then {
      $0.register(cell: ProductCollectionCell.self)
  }
  var categoryProductList: CategoryProudcutList? {
    didSet {
      setupFlowLayout()
      collectionView.reloadData()
    }
  }
//  var itemSizeWidthTest: CGFloat = 0 {
//    didSet {
//     print("아이템 가로는 담겼을까", itemSizeWidthTest)
//    }
//  }
  
  // MARK: - Life Cycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  override func layoutSubviews() {
//    setupUI()
//    setupFlowLayout()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - Setup Attribute
  private func setupUI() {
    collectionView.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
    collectionView.dataSource = self
    collectionView.delegate = self
    [collectionView] .forEach {
      self.addSubview($0)
    }
    
    collectionView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  private func setupFlowLayout() {
    let minimumLineSpacing: CGFloat = 20.0
    let minimumInteritemSpacing: CGFloat = 14.0
    let insets = UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14)
    let itemsForLine: CGFloat = 2
    let itemSizeWidth = (
      (
        collectionView.frame.width - (
          insets.left + insets.right + minimumInteritemSpacing * (itemsForLine - 1))
        ) / itemsForLine
      ).rounded(.down)
    let itemSize = CGSize(width: itemSizeWidth, height: itemSizeWidth * 1.8)
    collectionViewFlowLayout.sectionInset = insets
    collectionViewFlowLayout.minimumLineSpacing = minimumLineSpacing
    collectionViewFlowLayout.minimumInteritemSpacing = minimumInteritemSpacing
    collectionViewFlowLayout.itemSize = itemSize
    collectionViewFlowLayout.scrollDirection = .vertical
  }
}

// MARK: - UICollectionViewDataSource
extension CategoryDetailCollectionViewCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let categoryProductList = categoryProductList else { return 0 }
    return categoryProductList.count
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let categoryProductList = categoryProductList else { return UICollectionViewCell() }
    let cell = collectionView.dequeue(ProductCollectionCell.self, indexPath: indexPath)
    let categoryProduct = categoryProductList[indexPath.row]
    
    cell.delegate = self
    
    cell.configure(
      productId: categoryProduct.id,
      productName: categoryProduct.name,
      productImage: categoryProduct.image,
      price: categoryProduct.price,
      discount: categoryProduct.discount,
      additionalInfo: ["Kurly Only"],
      isSoldOut: false,
      productIndexPath: indexPath
    )
//    cell.backgroundColor = .systemPink
    return cell
  }
}
// MARK: - UICollectionViewDelegate
extension CategoryDetailCollectionViewCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print(indexPath.row, "이 셀을 눌렀어요")
    let detailVC = DetailViewController()
    detailVC.hidesBottomBarWhenPushed = true
    guard let categoryProductList = categoryProductList else { return }
    let productId = categoryProductList[indexPath.row].id
    detailVC.configure(productId: productId)
    (self.viewController as? CategoryDetailViewController)?
      .navigationController?.pushViewController(detailVC, animated: true)
  }
}

// MARK: - Alamofire
extension CategoryDetailCollectionViewCell {
  func fetchCategory(id: Int, completionHandler: @escaping (Result<Data, Error>) -> Void) {
    AF.request("http://15.164.49.32/kurly/category/\(id)/all")
      .validate(statusCode: [200])
      .responseData { (response) in
      switch response.result {
      case .success(let data):
        completionHandler(.success(data))
      case .failure(let error):
        print("fail")
        completionHandler(.failure(error))
      }
    }
  }
  
  func configure(id: Int) {
    // [weak self] 순환 참조를 막기 위해 써야 한다.
    fetchCategory(id: id) { [weak self] (result) in
      guard let self = self else { return } // self가 옵셔널인지 체크
      switch result {
      case .success(let data):
        guard let list = try? JSONDecoder().decode(CategoryProudcutList.self, from: data)
        else { return } // 디코딩이 잘되는 지 체크
        self.categoryProductList = list
      case .failure(let error):
        print(error)
        print(error.localizedDescription)
      }
    }
  }
  
  func fetchSubCategory(subId: Int, completionHandler: @escaping (Result<Data, Error>) -> Void) {
    AF.request("http://15.164.49.32/kurly/subcategory/\(subId)/")
      .validate(statusCode: [200])
      .responseData { (response) in
      switch response.result {
      case .success(let data):
        completionHandler(.success(data))
      case .failure(let error):
        completionHandler(.failure(error))
      }
    }
  }
  func subConfigure(subID: Int) {
    fetchSubCategory(subId: subID) { [weak self] (result) in
      switch result {
      case .success(let data):
        guard
          let self = self, // self가 옵셔널인지 체크
          let list = try? JSONDecoder().decode(CategoryProudcutList.self, from: data)
          // 디코딩이 잘되는 지 체크
          else { return }
        self.categoryProductList = list
      case .failure:
        KurlyNotification.shared.show(text: "잠시후 다시 시도해주세요.", type: .warning)
      }
    }
  }
}

extension CategoryDetailCollectionViewCell: ProductCollectionCellDelegate {  
  func cartOrAlarmButtonTouched(_ collectionView: UICollectionView, _ button: UIButton, _ productIndexPath: IndexPath) {
    guard let categoryProductList = categoryProductList else { return }
       let categoryProduct = categoryProductList[productIndexPath.row]
    
    let navigationController = UINavigationController(rootViewController: AddProductCartViewController())
    
    (self.viewController as? CategoryDetailViewController)?.present(navigationController, animated: true) {
      navigationController.do {
        guard let firstViewController = $0.viewControllers.first as? AddProductCartViewController else { return }
        
        firstViewController.deliver(
          id: categoryProduct.id,
          name: categoryProduct.name,
          price: categoryProduct.price,
          discountRate: categoryProduct.discount
        )
      }
    }
  }
}
