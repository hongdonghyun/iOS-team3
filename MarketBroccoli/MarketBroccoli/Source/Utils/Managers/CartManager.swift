//
//  CartManager.swift
//  MarketBroccoli
//
//  Created by Soohan Lee on 2020/04/20.
//  Copyright © 2020 Team3. All rights reserved.
//

import Foundation
import Alamofire

class CartManager {
  static let shared = CartManager()
  
  private init() { }
  
  func addProductIntoCart(_ product: UpdatedProduct, completionHandler: @escaping (Result<Data, Error>) -> Void) {
    guard let token = UserDefaultManager.shared.get(for: .token) as? String else { return }
    
    AF.request(
      RequestCart.cart.endPoint,
      method: .post,
      parameters: product,
      encoder: JSONParameterEncoder.default,
      headers: [
        "Content-Type": "application/json",
        "Authorization": "Token \(token)"
      ]
    )
      .validate()
      .responseData { response in
        switch response.result {
        case .success(let data):
          completionHandler(.success(data))
        case .failure(let error):
          completionHandler(.failure(error))
        }
    }
  }
  
  func patchProductQuntity(
    id: Int, product: UpdatedProduct,
    completionHandler: @escaping (Result<Data, Error>) -> Void
  ) {
    guard let token = UserDefaultManager.shared.get(for: .token) as? String else { return }
    
    AF.request(
      RequestCart.updateProduct(id).endPoint,
      method: .patch,
      parameters: product,
      encoder: JSONParameterEncoder.default,
      headers: [
        "Content-Type": "application/json",
        "Authorization": "Token \(token)"
      ]
    )
      .validate()
      .responseData { response in
        switch response.result {
        case .success(let data):
          completionHandler(.success(data))
        case .failure(let error):
          completionHandler(.failure(error))
        }
    }
  }
  
  func removeProduct(id: Int, completionHandler: @escaping (Result<Data, Error>) -> Void) {
    guard let token = UserDefaultManager.shared.get(for: .token) as? String else { return }
    
    AF.request(
      RequestCart.removeProduct(id).endPoint,
      method: .delete,
      headers: ["Authorization": "Token \(token)"]
    )
      .validate()
      .responseData { response in
        switch response.result {
        case .success(let data):
          completionHandler(.success(data))
        case .failure(let error):
          completionHandler(.failure(error))
        }
    }
  }
  
  func fetchCart(completionHandler: @escaping (Result<BackendCart, Error>) -> Void) {
    guard let token = UserDefaultManager.shared.get(for: .token) as? String else { return }
    
    AF.request(
      RequestCart.cart.endPoint,
      method: .get,
      headers: ["Authorization": "Token \(token)"]
    )
      .validate()
      .responseDecodable(of: BackendCart.self) { response in
        switch response.result {
        case .success(let data):
          completionHandler(.success(data))
        case .failure(let error):
          completionHandler(.failure(error))
        }
    }
  }
}