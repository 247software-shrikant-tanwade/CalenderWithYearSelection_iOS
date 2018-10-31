//
//  ViewController.swift
//  CalenderWithYearSelection
//
//  Created by Shrikant Tanwade on 27/03/18.
//  Copyright © 2018 qlx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var lblDate : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func btnCalenderAction() {
        STCalenderVC.presentCalenderView(delegate: self, minimum: -100, maximum: -18, selectedDate: nil, onSourceViewController: self)
    }
}

extension ViewController : STCalenderVCDelegate {
    
    func selectedCalendar(dateStr: String, date: Date) {
        self.lblDate.text = dateStr
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
    }
}

