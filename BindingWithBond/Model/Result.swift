//
//  Result.swift
//  BindingWithBond
//
//  Created by Lam Nguyen on 6/16/22.
//

import Foundation

// Describes the result of an asynchronous query
enum Result<T> {
  case success(T)
  case error(Error)
}
