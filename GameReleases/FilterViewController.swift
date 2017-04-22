//
//  FilterViewController.swift
//  GameReleases
//
//  Created by Corey McCourt on 10/12/16.
//  Copyright © 2016 Corey McCourt. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: FilterViewControllerDelegate?
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.target = self
        self.navigationItem.rightBarButtonItem?.action = #selector(searchBtnAction)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        datePicker.setDate(date, animated: true)
    }
    
    // MARK: - Actions
    func searchBtnAction() {
        delegate?.setFilterDate(date: datePicker.date)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Protocol
protocol FilterViewControllerDelegate {
    func setFilterDate(date: Date)
}
