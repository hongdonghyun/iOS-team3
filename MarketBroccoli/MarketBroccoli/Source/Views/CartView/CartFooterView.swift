//
//  CartFooterView.swift
//  MarketBroccoli
//
//  Created by Soohan Lee on 2020/03/26.
//  Copyright © 2020 Team3. All rights reserved.
//

import SnapKit
import Then
import UIKit

protocol CartFooterViewDataSource: class {
}

class CartFooterView: UIView {
  // MARK: - Properties
  
  weak var dataSource: CartFooterViewDataSource?
  
  private let staticTotalProductPriceLabel = UILabel().then {
    $0.text = "상품금액"
  }
  
  private let totalProductPriceLabel = UILabel().then {
    $0.textAlignment = .right
    $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
  }
  
  private let staticDiscountProductPriceLabel = UILabel().then {
    $0.text = "상품할인금액"
  }
  
  private let discountProductPriceLabel = UILabel().then {
    $0.textAlignment = .right
    $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
  }
  
  private let staticShippingFeeLabel = UILabel().then {
    $0.text = "배송비"
  }
  
  private let shippingFeeLabel = UILabel().then {
    $0.textAlignment = .right
    $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
  }
  
  private let separator = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  private let staticExpectedAmountPayment = UILabel().then {
    $0.text = "결제예정금액"
  }
  
  private let expectedAmountPayment = UILabel().then {
    $0.textAlignment = .right
    $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
  }
  
  // MARK: - Life Cycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupAttribute()
    addAllView()
    setupAutoLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup UI
  
  private func setupAttribute() {
    self.backgroundColor = .white
  }
  
  private func addAllView() {
    self.addSubviews([
      staticTotalProductPriceLabel,
      totalProductPriceLabel,
      staticDiscountProductPriceLabel,
      discountProductPriceLabel,
      staticShippingFeeLabel,
      shippingFeeLabel,
      separator,
      staticExpectedAmountPayment,
      expectedAmountPayment
    ])
  }
  
  private func setupAutoLayout() {
    staticTotalProductPriceLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(24)
    }
    
    totalProductPriceLabel.snp.makeConstraints {
      $0.top.bottom.equalTo(staticTotalProductPriceLabel)
      $0.leading.equalTo(staticTotalProductPriceLabel.snp.trailing)
      $0.trailing.equalToSuperview().inset(24)
    }
    
    staticDiscountProductPriceLabel.snp.makeConstraints {
      $0.top.equalTo(staticTotalProductPriceLabel.snp.bottom).offset(16)
      $0.leading.equalTo(staticTotalProductPriceLabel)
    }
    
    discountProductPriceLabel.snp.makeConstraints {
      $0.top.bottom.equalTo(staticDiscountProductPriceLabel)
      $0.leading.equalTo(staticDiscountProductPriceLabel.snp.trailing)
      $0.trailing.equalTo(totalProductPriceLabel)
    }
    
    staticShippingFeeLabel.snp.makeConstraints {
      $0.top.equalTo(staticDiscountProductPriceLabel.snp.bottom).offset(16)
      $0.leading.equalTo(staticDiscountProductPriceLabel)
    }
    
    shippingFeeLabel.snp.makeConstraints {
      $0.top.bottom.equalTo(staticShippingFeeLabel)
      $0.leading.equalTo(staticShippingFeeLabel.snp.trailing)
      $0.trailing.equalTo(discountProductPriceLabel)
    }
    
    separator.snp.makeConstraints {
      $0.top.equalTo(staticShippingFeeLabel.snp.bottom).offset(16)
      $0.leading.equalTo(staticShippingFeeLabel)
      $0.trailing.equalTo(shippingFeeLabel)
      $0.height.equalTo(1)
    }
    
    staticExpectedAmountPayment.snp.makeConstraints {
      $0.top.equalTo(separator.snp.bottom).offset(16)
      $0.leading.equalTo(separator)
      $0.bottom.equalToSuperview().inset(24)
    }
    
    expectedAmountPayment.snp.makeConstraints {
      $0.leading.equalTo(staticExpectedAmountPayment.snp.trailing)
      $0.bottom.equalTo(staticExpectedAmountPayment)
      $0.trailing.equalTo(separator)
    }
  }
}