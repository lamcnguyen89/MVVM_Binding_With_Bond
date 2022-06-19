//
//  SettingsTableViewController.swift
//  BindingWithBond
//
//  Created by Lam Nguyen on 6/16/22.
//

import UIKit
import Foundation
import Bond
import DatePickerCell

class SettingsTableViewController: UITableViewController {

    fileprivate let rowHeight: CGFloat = 44
    
    @IBOutlet weak var maxPickerCell: DatePickerCell!
    @IBOutlet weak var minPickerCell: DatePickerCell!
    @IBOutlet weak var filterDatesSwitch: UISwitch!
    @IBOutlet weak var creativeCommonsSwitch: UISwitch!
    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    var viewModel: PhotoSearchMetadataViewModel?
        
    override func viewDidLoad() {
      tableView.estimatedRowHeight = rowHeight
      
      maxPickerCell.leftLabel.text = "Max Date"
      minPickerCell.leftLabel.text = "Min Date"
        
      bindViewModel()
    }
    
    // This helper method accepts a Date and a DatePickerCell and creates bindings between the two. The modelDate is bound to the picker.date and vice versa
    fileprivate func bind(_ modelDate: Observable<Date>, picker: DatePickerCell) {
        _ = modelDate.observeNext {
            event in
            picker.date = event
        }
    }
    
    // This code binds viewModel to the creativeCommonsSwitch
    func bindViewModel() {
        
        guard let viewModel = viewModel else {
            return
        }
        
        // THe two lines below bind the upload dates to the picker cells using the new bind helper method
        bind(viewModel.minUploadDate, picker: minPickerCell)
        bind(viewModel.maxUploadDate, picker: maxPickerCell)
        
        viewModel.creativeCommons.bidirectionalBind(to: creativeCommonsSwitch.reactive.isOn)
        
        // Binds the date filter switch to the view model, and also reduces the opacity of the date picker cells when they are not in use
        viewModel.dateFilter.bidirectionalBind(to: filterDatesSwitch.reactive.isOn)
        
        let opacity = viewModel.dateFilter.map { $0 ? CGFloat(1.0) : CGFloat(0.5) }
        opacity.bind(to: minPickerCell.leftLabel.reactive.alpha)
        opacity.bind(to: maxPickerCell.leftLabel.reactive.alpha)
        opacity.bind(to: minPickerCell.rightLabel.reactive.alpha)
        opacity.bind(to: maxPickerCell.rightLabel.reactive.alpha)
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let cell = tableView.cellForRow(at: indexPath)
      guard let datePickerCell = cell as? DatePickerCell else {
        return
      }
      datePickerCell.selectedInTableView(tableView)
      tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      let cell = tableView.cellForRow(at: indexPath)
      guard let datePickerCell = cell as? DatePickerCell else {
        return rowHeight
      }
      return datePickerCell.datePickerHeight()
    }
    
    

}
