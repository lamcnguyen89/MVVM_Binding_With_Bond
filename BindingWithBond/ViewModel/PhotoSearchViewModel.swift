//
//  PhotoSearchViewModel.swift
//  BindingWithBond
//
//  Created by Lam Nguyen on 6/17/22.
//

import Foundation
import Bond
import ReactiveKit

class PhotoSearchViewModel {
    
    let searchMetadataViewModel = PhotoSearchMetadataViewModel()
    
  let searchString = Observable<String?>("")
  
// This boolean property will indicate whether the searchString value is valid of not
  let validSearchText = Observable<Bool>(false)
    
// Web API call to 500px
  private let searchService: PhotoSearch = {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "apiKey") as! String
        return PhotoSearch(key: apiKey)
    }()
    
// Allows you to see the photos. This is a special type of observable that supports arrays
let searchResults = MutableObservableArray<Photo>([])
    
    // Observable that will be used to indicate when a search is in progress.
    let searchInProgress = Observable<Bool>(false)
  
// For handling errors
    let errorMessages = PassthroughSubject<String, Never>()
  
  init() {
      
      // Code that gives a boolean value of true if the number of characters in the search is greater then 3, and false if less then 3
      searchString
          .map { $0!.count > 3}
          .bind(to:validSearchText)
      
    // The test value
      // searchString.value = "Bond"
    
      
//    _ = searchString.observeNext {
//      text in
//      if let text = text {
//        print(text)
//      }
//    }
      
      // Filters the searchString to exclude strings with less then 3 characters, and throttles notification changes to 0.5 seconds. When the event fires, the executesearch() function is called
      _ = searchString
          .filter { $0!.count > 3}
          .throttle(for: 3.0)
          .observeNext {
              [unowned self] text in
              if let text = text {
                  self.executeSearch(text)
              }
          }
      
      // The Combine Latest function combines any number of observables, allowing you to treat them as one. The below code combines, throttles, then executes the quert.
      _ = combineLatest(searchMetadataViewModel.dateFilter, searchMetadataViewModel.maxUploadDate, searchMetadataViewModel.minUploadDate, searchMetadataViewModel.creativeCommons)
          .throttle(for: 0.5)
          .observeNext {
              [unowned self] _ in
              self.executeSearch(self.searchString.value!)
          }
  }
    
    // Method for searching for photos
    func executeSearch(_ text: String) {
        
        var query = PhotoQuery()
        query.text = searchString.value ?? ""
        
        // The following query lines below simply copies the view model state to the PhotoQuery object
        query.creativeCommonsLicence = searchMetadataViewModel.creativeCommons.value
        query.dateFilter = searchMetadataViewModel.dateFilter.value
        query.minDate = searchMetadataViewModel.minUploadDate.value
        query.maxDate = searchMetadataViewModel.maxUploadDate.value
        
        searchService.findPhotos(query) {
            [unowned self] result in
            self.searchInProgress.value = false
            switch result {
            case .success(let photos):
                self.searchResults.removeAll()
                self.searchResults.insert(contentsOf: photos, at: 0) // clears the array, adding new results
            case .error:
                self.errorMessages.next("There was an API request issue of some sort.")
            }
        }
    }
    
}


