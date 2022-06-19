//
//  PhotoSearchError.swift
//  BindingWithBond
//
//  Created by Lam Nguyen on 6/16/22.
//

import Foundation

// Describes the various errors that can occur when querying the 500px API
enum PhotoSearchError: Error {
  case requestError
  case parseError
  case malformedRequest
}


