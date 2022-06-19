//
//  Photo.swift
//  BindingWithBond
//
//  Created by Lam Nguyen on 6/16/22.
//

import Foundation

typealias PhotoArray = [Photo]

// Represents a single photo as returned by the 500px API
struct Photo {
  let title: String
  let url: URL
  let date: Date
}


