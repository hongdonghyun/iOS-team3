//
//  UICollectionViewExtension.swift
//  MarketBroccoli
//
//  Created by Hongdonghyun on 2020/03/23.
//  Copyright © 2020 Team3. All rights reserved.
//

import UIKit

extension UICollectionView {
  func register<Cell>(cell: Cell.Type,
                      forCellReuseIdentifier reuseIdentifier: String = Cell.identifier) where Cell: UICollectionViewCell {
    register(cell, forCellWithReuseIdentifier: reuseIdentifier)
  }
  
  func dequeue<Cell>(_ reusableCell: Cell.Type, indexPath: IndexPath) -> Cell where Cell: UICollectionViewCell {
    if let cell = dequeueReusableCell(withReuseIdentifier: reusableCell.identifier, for: indexPath) as? Cell {
      return cell
    } else {
      fatalError("Identifier required")
    }
  }
}