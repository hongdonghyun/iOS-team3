//
//  AddProductCartViewController.swift
//  MarketBroccoli
//
//  Created by Soohan Lee on 2020/04/15.
//  Copyright © 2020 Team3. All rights reserved.
//

import UIKit
import Alamofire

class AddProductCartViewController: UIViewController {
  // MARK: - Properties
  
  private let cartManager = CartManager.shared
  
  private var productList: ProductList? {
    didSet {
      addProductCartView.reloadProductTableViewData()
    }
  }
  
  private lazy var addProductCartView = AddProductCartView().then {
    $0.dataSource = self
    $0.delegate = self
  }
  
  // MARK: - Life Cycle
  
  override func loadView() {
    view = addProductCartView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigation()
  }
  
  // MARK: - Setup Navigation
  
  private func setupNavigation() {
    title = "상품 선택"
    
    guard let navigationController = self.navigationController else { return }
    navigationController.do {
      $0.navigationBar.barTintColor = .white
      $0.navigationBar.isTranslucent = false
      $0.navigationBar.barStyle = .black
      $0.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    let closeCartbutton = UIButton(type: .system).then {
      $0.tintColor = .black
      $0.setImage(UIImage(systemName: "xmark"), for: .normal)
      
      $0.addTarget(self, action: #selector(closeCart), for: .touchUpInside)
    }
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeCartbutton)
  }
  
  @objc
  private func closeCart() {
    dismiss(animated: true)
  }
}

extension AddProductCartViewController: AddProductCartViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let productList = productList else { return 0 }
    
    return productList.productOptions.count == 0 ? 1 : productList.productOptions.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let productList = productList else { return UITableViewCell() }
    let product = productList.productOptions[indexPath.row]
    
    let cell = tableView.dequeue(SelectingProductCell.self).then {
      $0.delegate = self
      
      $0.configure(
        name: product.product.name,
        price: product.product.price,
        discount: productList.discountRate,
        quantity: product.quantity,
        productIndexPath: indexPath
      )
    }
    
    return cell
  }
}

// MARK: - Action Handler

extension AddProductCartViewController: AddProductCartViewDelegate {
  func addProductInCartButtonTouched(_ button: UIButton) {
    guard let productList = productList else { return }
    let selectedProducts = productList.productOptions.filter({ $0.quantity > 0 })
    
    guard !selectedProducts.isEmpty else {
      KurlyNotification.shared.show(text: "수량을 선택해주세요.", type: .warning)
      
      return
    }
    
    var orderProducts = [UpdatedProduct]()
    
    for selectedProduct in selectedProducts {
      let optionID = selectedProduct.product.id
      let quantity = selectedProduct.quantity
      let orderProduct: UpdatedProduct
      
      if let productIDForHasOption = productList.id {
        orderProduct = UpdatedProduct(product: productIDForHasOption, option: optionID, quantity: quantity)
      } else {
        orderProduct = UpdatedProduct(product: selectedProduct.product.id, option: nil, quantity: quantity)
      }
      
      orderProducts.append(orderProduct)
    }
    
    orderProducts.forEach {
      cartManager.addProductIntoCart($0) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .success(let data):
          print(data)
        case .failure(let error):
          print(error.localizedDescription)
        }
        
        guard
          let broccoliTabBarController = self.presentingViewController as? MartketBroccoliTabBarController,
          let viewControllers = broccoliTabBarController.viewControllers
        else { return }
        
        viewControllers.forEach {
          guard
            let navigationController = $0 as? UINavigationController,
            let viewController = navigationController.viewControllers.first
          else { return }
          
          viewController.addNavigationBarCartButton()
        }
      }
    }
    
    dismiss(animated: true) {
      KurlyNotification.shared.show(text: "장바구니에 상품이 담겼습니다.", type: .notice)
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let productList = productList, productList.productOptions.count != 1 else { return nil }
    
    return tableView.dequeue(ProductCategoryHeader.self).then {
      $0.configure(productCategoryName: productList.name)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard let productList = productList, productList.productOptions.count != 1 else { return 0 }
    
    return 38
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard let productList = productList else { return nil }
    var totalPrice = 0
    
    for product in productList.productOptions {
      totalPrice += product.product.price * product.quantity
    }
    
    return tableView.dequeue(SelectingProductFooter.self).then {
      $0.configure(totalPrice: totalPrice)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    38
  }
}

extension AddProductCartViewController: SelectingProductCellDelegate {
  func productQuantityStepperValueChanged(_ value: Int, _ productIndexPath: IndexPath) {
    guard var productList = productList else { return }
    productList.productOptions[productIndexPath.row].quantity = value
    
    self.productList = productList
  }
}

extension AddProductCartViewController {
  func deliver(id: Int, name: String, price: Int, discountRate: Double) {
    fetchOptions(id) { result in
      switch result {
      case .success(let beOptions):
        let options = beOptions.options
        var productList: ProductList
        
        if !options.isEmpty {
          productList = ProductList(id: id, name: name, discountRate: discountRate, productOptions: [])
          
          for option in options {
            productList.productOptions.append(
              SelectableProduct(
                product: ProductOption(id: option.id, name: option.name, price: option.price),
                quantity: 0
              )
            )
          }
        } else {
          productList = ProductList(id: nil, name: nil, discountRate: discountRate, productOptions: [
            SelectableProduct(product: ProductOption(id: id, name: name, price: price), quantity: 1)
          ])
        }
        
        self.productList = productList
        self.addProductCartView.removeDimView()
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
}

extension AddProductCartViewController {
  private func fetchOptions(_ id: Int, completionHandler: @escaping (Result<BEOptions, Error>) -> Void) {
    AF.request(
      "http://15.164.49.32/kurly/product/\(id)/option/"
    )
      .validate()
      .responseDecodable(of: BEOptions.self) { response in
        switch response.result {
        case .success(let data):
          completionHandler(.success(data))
        case .failure(let error):
          completionHandler(.failure(error))
        }
    }
  }
}
