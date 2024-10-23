//
//  UITableViewExtension.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/13.
//

import UIKit


extension UITableView {
    /// Dequeues a UICollectionView Cell with a generic type and indexPath
    /// - Parameters:
    ///   - type: A generic cell type
    ///   - indexPath: The indexPath of the row in the UICollectionView
    /// - Returns: A Cell from the type passed through
    func dequeueReusableCell<Cell: UITableViewCell>(with type: Cell.Type, reuseIdentifier: String) -> Cell? {
        dequeueReusableCell(withIdentifier: reuseIdentifier) as? Cell
    }
    
    @objc public func reloadDataSafe() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}

extension UICollectionView {
    /// Dequeues a UICollectionView Cell with a generic type and indexPath
    /// - Parameters:
    ///   - type: A generic cell type
    ///   - indexPath: The indexPath of the row in the UICollectionView
    /// - Returns: A Cell from the type passed through
    func dequeueReusableCell<Cell: UICollectionViewCell>(with type: Cell.Type, reuseIdentifier: String,indexPath: IndexPath) -> Cell? {
        dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? Cell
    }
    
    @objc public func reloadDataSafe() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
