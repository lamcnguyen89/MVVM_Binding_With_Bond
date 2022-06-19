//
//  PhotoSearchViewController.swift
//  BindingWithBond
//
//  Created by Lam Nguyen on 6/17/22.
//

import UIKit
import Bond
import ReactiveKit


class PhotoSearchViewController: UIViewController {
    
    private let viewModel = PhotoSearchViewModel()
    
    @IBOutlet weak var searchTextField:UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultsTable: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        bindViewModel()
        
//        _ = searchTextField.reactive.text.observeNext {
//            text in
//            if let text = text {
//                print(text)
//            }
//        }
        
//        let uppercase = searchTextField.reactive.text.map{ $0?.uppercased() }
//
//        _ = uppercase.observeNext {
//            text in
//            if let text = text {
//                print(text)
//            }
//        }

        // The activity indicator only animates when typing is occuring
        _ = searchTextField.reactive.text
            .map {$0!.count > 0 }
            .bind (to: activityIndicator.reactive.isAnimating)
    }
    
    // When the settings button is tapped, the storyboard performs a segue. This process can be intercepted in order to pass data to the settings view controller. This ensures that when the showSettings segue is executed, the view model is correctly set on the destination view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSettings" {
            let navVC = segue.destination as! UINavigationController
            let settingsVC = navVC.topViewController as! SettingsTableViewController
            settingsVC.viewModel = viewModel.searchMetadataViewModel
        }
    }
    
    // This function Binds the searchTextField variable to the viewModel structure.
    func bindViewModel() {
        
        // This line of code is only one way so far since it only propogates changes from the viewModel property to the textfield, the reactive.text property
           // viewModel.searchString.bind(to: searchTextField.reactive.text)
        
        // To make the exchange bidirectional from the ViewModel to the TextField and vice versa, use this command:
        viewModel.searchString.bidirectionalBind(to: searchTextField.reactive.text)
        
        // Change color of text based on the validSearchText boolean value in the PhotoSearchViewModel
        viewModel.validSearchText
            .map { $0 ? .black : .red }
            .bind(to: searchTextField.reactive.textColor)
        
        viewModel.searchResults.bind(to: resultsTable) {
            dataSource, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! PhotoTableViewCell
            let photo = dataSource[indexPath.row]
            cell.title.text = photo.title
            
            let backgroundQueue = DispatchQueue(label: "backgroundQueue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
            cell.photo.image = nil
            backgroundQueue.async {
                if let imageData = try? Data(contentsOf: photo.url) {
                    DispatchQueue.main.async() {
                        cell.photo.image = UIImage(data: imageData)
                    }
                }
            }
            return cell
        }
        
        // Shows the activity Indicator
        viewModel.searchInProgress
            .map { !$0 }.bind(to: activityIndicator.reactive.isHidden)
        
        // Reduces the opacity of the resulrsTable when the query is in progress
        viewModel.searchInProgress
            .map { $0 ? CGFloat(0.5) : CGFloat(1.0) }
            .bind (to: resultsTable.reactive.alpha)
        
        // This subscribes to the events emitted by the errorMessages property, displaying the supplied error messages via a UIAlertController
        _ = viewModel.errorMessages.observeNext {
            [unowned self] error in
            
            let alertController = UIAlertController(title: "Something went wrong :-(", message: error, preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            let actionOK = UIAlertAction(title: "OK", style: .default, handler: { action in alertController.dismiss(animated: true, completion: nil) })
            
            alertController.addAction(actionOK)
        }
        
    }
}
