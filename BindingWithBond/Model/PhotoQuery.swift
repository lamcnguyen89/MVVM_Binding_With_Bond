//
//  PhotoQuery.swift
//  BindingWithBond
//
//  Created by Lam Nguyen on 6/16/22.
//

import Foundation

// Represents a query that can be used to retrieve photos from the 500px API
struct PhotoQuery {
  var text = ""
  var creativeCommonsLicence = false
  var dateFilter = false
  var maxDate = Date()
  var minDate = Date()
}
