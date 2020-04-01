//
//  SearchView.swift
//  MarketBroccoli
//
//  Created by Soohan Lee on 2020/03/30.
//  Copyright © 2020 Team3. All rights reserved.
//

import UIKit

protocol SearchViewDelegate: class {
  func searchProductTextFieldEditingDidBegin(_ textField: UITextField, _ button: UIButton)
  
  func searchProductTextFieldEditingChanged(_ textField: UITextField, _ text: String)
  
  func cancelSearchButtonTouched(_ button: UIButton, _ textField: UITextField)
}

class SearchView: UIView {
  // MARK: - Properties
  
  weak var delegate: SearchViewDelegate?
  
  private lazy var searchView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  private lazy var searchProductTextField = UITextField().then {
    let containerView = UIView().then {
      $0.frame = CGRect(x: 0, y: 0, width: 36, height: 32)
    }
    
    let magnifyingglassImageView = UIImageView().then {
      let magnifyingglassImage = UIImage(systemName: "magnifyingglass")
      
      $0.contentMode = .scaleAspectFit
      $0.image = magnifyingglassImage
      $0.tintColor = .gray
      $0.frame = CGRect(x: 5, y: 0, width: 26, height: 32)
    }
    containerView.addSubview(magnifyingglassImageView)
    
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 6
    $0.leftViewMode = .always
    $0.leftView = containerView
    $0.returnKeyType = .search
    $0.placeholder = "검색어를 입력해 주세요"
    
    $0.addTarget(self, action: #selector(searchProductTextFieldEditingDidBegin(_:)), for: .editingDidBegin)
    $0.addTarget(self, action: #selector(searchProductTextFieldEditingChanged(_:)), for: .editingChanged)
  }
  
  private lazy var cancelSearchButton = UIButton(type: .system).then {
    $0.setTitle("취소", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.setTitleColor(.gray, for: .disabled)
    $0.isEnabled = false
    
    $0.addTarget(self, action: #selector(cancelSearchButtonTouched(_:)), for: .touchUpInside)
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
      searchView
    ])
    
    searchView.addSubviews([
      searchProductTextField,
      cancelSearchButton
    ])
  }
  
  private func setupAutoLayout() {
    searchView.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
      $0.height.equalTo(50)
    }
    
    searchProductTextField.snp.makeConstraints {
      $0.top.leading.bottom.equalToSuperview().inset(6)
      $0.trailing.equalTo(cancelSearchButton.snp.leading).inset(-8)
    }
    
    cancelSearchButton.snp.makeConstraints {
      $0.top.bottom.equalTo(searchProductTextField)
      $0.trailing.equalToSuperview().inset(8)
    }
  }
}

// MARK: - Action Handler

extension SearchView {
  @objc
  private func searchProductTextFieldEditingChanged(_ textField: UITextField) {
    delegate?.searchProductTextFieldEditingChanged(textField, textField.text ?? "")
  }
  
  @objc
  private func searchProductTextFieldEditingDidBegin(_ textField: UITextField) {
    delegate?.searchProductTextFieldEditingDidBegin(textField, cancelSearchButton)
  }
  
  @objc
  private func cancelSearchButtonTouched(_ button: UIButton) {
    delegate?.cancelSearchButtonTouched(button, searchProductTextField)
  }
}

// MARK: - Element Control

extension SearchView {
}