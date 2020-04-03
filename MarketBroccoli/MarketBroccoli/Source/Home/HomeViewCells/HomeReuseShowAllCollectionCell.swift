//
//  HomeReuseShowAllCollectionCell.swift
//  MarketBroccoli
//
//  Created by Hongdonghyun on 2020/04/01.
//  Copyright © 2020 Team3. All rights reserved.
//

import UIKit

class HomeReuseShowAllCollectionCell: UICollectionViewCell {
  private lazy var moreBtn = UIButton().then {
    $0.setTitle(">", for: .normal)
    $0.layer.borderColor = UIColor.kurlyGray2.cgColor
    $0.layer.borderWidth = 1
    $0.setTitleColor(.kurlyMainPurple, for: .normal)
    $0.addTarget(self, action: #selector(moreBtnTouched(_:)), for: .touchUpInside)
  }
  
  private let btnLabel = UILabel().then {
    $0.text = "전체 보기"
    $0.textAlignment = .center
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    moreBtn.layer.cornerRadius = moreBtn.bounds.size.width / 2
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - ACTIONS
extension HomeReuseShowAllCollectionCell {
  @objc private func moreBtnTouched(_ sender: UIButton) {
    print("moreBtn Click")
  }
}

// MARK: - UI
extension HomeReuseShowAllCollectionCell {
  private func setupUI() {
    self.contentView.addSubviews([moreBtn, btnLabel])
    moreBtn.snp.makeConstraints {
      $0.bottom.equalTo(self.contentView.snp.centerY)
      $0.centerX.equalTo(self.contentView.snp.centerX)
      $0.width.height.equalTo(50)
    }
    btnLabel.snp.makeConstraints {
      $0.top.equalTo(self.contentView.snp.centerY).offset(4)
      $0.centerX.equalTo(self.contentView.snp.centerX)
      $0.width.equalTo(80)
    }
  }
}