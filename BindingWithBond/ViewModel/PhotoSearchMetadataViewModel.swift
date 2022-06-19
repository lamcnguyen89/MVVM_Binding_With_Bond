//
//  PhotoSearchMetadataViewModel.swift
//  BindingWithBond
//
//  Created by Lam Nguyen on 6/19/22.
//

import Foundation
import Bond

// this class is meant to add functionality to the settings screen.
class PhotoSearchMetadataViewModel {
    let creativeCommons = Observable<Bool>(false)
    let dateFilter = Observable<Bool>(false)
    let minUploadDate = Observable<Date>(Date())
    let maxUploadDate = Observable<Date>(Date())
    
    // Creates constraints so that the user can't make a minimum date that comes after the max date
    init() {
        _ = maxUploadDate.observeNext {
            [unowned self]
            maxDate in
            if maxDate.timeIntervalSince(self.minUploadDate.value) < 0 {
                self.minUploadDate.value = maxDate
            }
        }
        
        _ = minUploadDate.observeNext {
            [unowned self]
            minDate in
            if minDate.timeIntervalSince( self.maxUploadDate.value) > 0 {
                self.maxUploadDate.value = minDate
            }
        }
    }
}
