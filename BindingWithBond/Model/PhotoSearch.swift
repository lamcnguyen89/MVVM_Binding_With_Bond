//
//  PhotoSearch.swift
//  BindingWithBond
//
//  Created by Lam Nguyen on 6/16/22.
//

import Foundation

// Provides an interface for querying the 500px search API
class PhotoSearch {
  
  let host = "api.500px.com"
  let apiMethod = "/v1/photos/search"
  let key: String
  
  fileprivate static var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
  
  init(key: String) {
    self.key = key
  }
  
  // Find photos that match the supplied query, results are returned asynchronously
  // via the supplied callback
  func findPhotos(_ query: PhotoQuery, callback: @escaping (Result<PhotoArray>) -> ())  {
    
    // convert the PhotoQuery into querystring parameters
    let params = [
      "consumer_key": key,
      "image_size": "4",
      "term": query.text,
      "license_type": query.creativeCommonsLicence ? "1,2,3,4,5,6" : "0"
    ];
    
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = host
    urlComponents.path = apiMethod
    urlComponents.queryItems = params.map { key, value in URLQueryItem(name: key, value: value) }
    
    // construct the query URL
    guard let url = urlComponents.url else {
      callback(.error(PhotoSearchError.malformedRequest))
      return
    }
    
    // perform the request
    let task = URLSession.shared.dataTask(with: url, completionHandler: {
      (data, response, error) in
      
      // dispatch onto the main thread
      DispatchQueue.main.async {
        do {
          // parse the results, then filter based on date
          let result = try self.parseSearchResults(data!)
            .filter {
              photo in
              if query.dateFilter {
                return photo.date.timeIntervalSince(query.minDate as Date) > 0 &&
                  photo.date.timeIntervalSince(query.maxDate as Date) < 0
              } else {
                return true
              }
          }
          callback(Result.success(result))
        } catch {
          callback(Result.error(PhotoSearchError.parseError))
        }
      }
    })
    
    task.resume()
  }
  
  // parses the JSON data returned by the 50px API
  fileprivate func parseSearchResults(_ data: Data) throws -> PhotoArray {
    
    // convert the JSON response into a dictionary
    guard
      let jsonDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary,
      let photos = jsonDict["photos"] as? [NSDictionary] else {
        throw PhotoSearchError.parseError
    }
    
    let parsedPhotos = photos.map {
      photoDict -> Photo? in
      // parse each photo instance - if an error occurs, return nil
      guard let imageUrl = photoDict["image_url"] as? String,
        let name = photoDict["name"] as? String,
        let dateString = photoDict["created_at"] as? String,
        let date = PhotoSearch.formatter.date(from: dateString),
        let url = URL(string: imageUrl) else {
          return nil
      }
      
      return Photo(title: name, url: url, date: date)
      }
      // flatMap to unwrap optionals and remove nils
          .compactMap { $0 }
    
    return parsedPhotos;
  }
  
}
