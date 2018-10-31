//
//  ViewController.swift
//  FSCalenderWithYearSelection
//
//  Created by Shrikant Tanwade on 26/03/18.
//  Copyright © 2018 qlx. All rights reserved.
//

import UIKit

protocol STCalenderVCDelegate {
    func selectedCalendar(dateStr:String, date : Date)
}

class STCalenderVC: UIViewController {
    
    // MARK: -  @IBOutlet
    @IBOutlet var viewYearSelection: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var btnDateSelection: UIButton!
    @IBOutlet var btnYearMonthSelection: UIButton!
    @IBOutlet var lblSelectedDay: UILabel!
    @IBOutlet var lblSelectedWeekDay: UILabel!
    @IBOutlet var lblSelectedMonth: UILabel!
    @IBOutlet var lblSelectedYear: UILabel!
    
    @IBOutlet var fsCalender: FSCalendar!
    var fsMinDateWithFirstDayOfYear : Date!
    var fsMinYearDateWithCurrentDayMonth : Date!
    var fsMaxYearDateWithCurrentDayMonth : Date!
    var fsMaxiDateWithLastDayOfYear : Date!
    
    var yearMonthIndex = 0
    
    let reuseIdentifier = "YearMonthCollectionCell" // also enter this string as the cell identifier in the storyboard
    var items : [String] = []
    
    // MARK: - variables
    var delegate:STCalenderVCDelegate?
    var arrActiveDates = [String]()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    var previousVCSelectedDate : Date!
    var previousSelectedDate : Date!
    var selectedDate : Date!
    
    class func presentCalenderView(delegate:STCalenderVCDelegate,minimum:Int,maximum:Int,selectedDate:Date?,onSourceViewController:UIViewController) {
        let objSTCalenderVC = UIStoryboard(name: "Calender", bundle: nil).instantiateViewController(withIdentifier: "STCalenderVC") as! STCalenderVC
        objSTCalenderVC.providesPresentationContextTransitionStyle = true
        objSTCalenderVC.definesPresentationContext = true
        objSTCalenderVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        objSTCalenderVC.previousVCSelectedDate = selectedDate
        
        objSTCalenderVC.fsMinYearDateWithCurrentDayMonth = Calendar.current.date(byAdding: .year, value: minimum, to: Date())!
        let minYear = Calendar.current.component(.year, from: objSTCalenderVC.fsMinYearDateWithCurrentDayMonth)
        if let lastOfPreviousYear = Calendar.current.date(from: DateComponents(year: minYear - 1, month: 1, day: 1)) {
            // Get the First day of the year
            objSTCalenderVC.fsMinDateWithFirstDayOfYear = Calendar.current.date(byAdding: .day, value: 1, to: lastOfPreviousYear)
        }
        
        objSTCalenderVC.fsMaxYearDateWithCurrentDayMonth = Calendar.current.date(byAdding: .year, value: maximum, to: Date())!
        let maxYearyear = Calendar.current.component(.year, from: objSTCalenderVC.fsMaxYearDateWithCurrentDayMonth)
        if let firstOfNextYear = Calendar.current.date(from: DateComponents(year: maxYearyear + 1, month: 1, day: 1)) {
            // Get the last day of the year
            objSTCalenderVC.fsMaxiDateWithLastDayOfYear = Calendar.current.date(byAdding: .day, value: -1, to: firstOfNextYear)
        }
        
        objSTCalenderVC.delegate = delegate
        onSourceViewController.navigationController?.present(objSTCalenderVC, animated: true, completion: nil)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnYearMonthSelection.layer.cornerRadius = btnYearMonthSelection.frame.height/2
        btnYearMonthSelection.layer.borderWidth = 1.0
        btnYearMonthSelection.layer.borderColor = UIColor.white.cgColor
        
        fsCalender.scrollDirection = .horizontal
        fsCalender.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]
        fsCalender.allowsMultipleSelection = false
        fsCalender.placeholderType = .none
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //calendarForDate.setCurrentPage(Date(), animated: true)
        if previousVCSelectedDate != nil {
            self.set(slectedDate: previousVCSelectedDate)
            fsCalender.setCurrentPage(previousVCSelectedDate!, animated: true)
        } else {
            fsCalender.setCurrentPage(fsMaxYearDateWithCurrentDayMonth, animated: false)
            fsCalender.select(fsMaxYearDateWithCurrentDayMonth)
            self.set(slectedDate: fsMaxYearDateWithCurrentDayMonth)
        }
    }
    
    func set(slectedDate:Date) {
        self.selectedDate  = slectedDate
        dateFormatter.dateFormat = "yyyy"
        lblSelectedYear.text = dateFormatter.string(from: slectedDate)
        dateFormatter.dateFormat = "dd"
        lblSelectedDay.text = dateFormatter.string(from: slectedDate)
        dateFormatter.dateFormat = "EEEE"
        lblSelectedWeekDay.text = dateFormatter.string(from: slectedDate)
        dateFormatter.dateFormat = "MMMM"
        lblSelectedMonth.text = dateFormatter.string(from: slectedDate)
    }
    
    @IBAction func btnYearMonthSelectionAction(_ sender: UIButton) {
        
        if !sender.isSelected {
            sender.isSelected = true
            self.viewYearSelection.isHidden = false
            dateFormatter.dateFormat = "yyyy"
            var date = fsCalender.maximumDate
            items.removeAll()
            while date > fsCalender.minimumDate {
                items.append("\(dateFormatter.string(from: date))")
                date = Calendar.current.date(byAdding: .year, value: -1, to: date)!
            }
            
            collectionView.reloadData()
        } else {
            sender.isSelected = false
            self.btnDateSelectionAction(nil)
        }
        
    }
    
    @IBAction func btnDateSelectionAction(_ sender: AnyObject?) {
        self.viewYearSelection.isHidden = true
    }
    
    @IBAction func cancelCalender(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okCalender(_ sender: AnyObject) {
        dateFormatter.dateFormat = "EEEE, dd MMM, yyyy"
        delegate?.selectedCalendar(dateStr: "\(dateFormatter.string(from:selectedDate))", date: selectedDate)
        self.dismiss(animated: true, completion: nil)
    }
    
    var previousMonth: Int {
        let cal = Calendar.autoupdatingCurrent
        return (cal as NSCalendar).component(.year, from: (cal as NSCalendar).date(byAdding: .year, value: -1, to: Date(), options: [])!)
    }
    
    //MARK: - Calender Left Right  Button
    @IBAction func LeftSideAction(_ sender: AnyObject){
        let currentMonth = self.fsCalender.currentPage as Date
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
        self.fsCalender.setCurrentPage(previousMonth, animated: true)
    }
    
    @IBAction func RightSideAction(_ sender: AnyObject){
        let currentMonth = self.fsCalender.currentPage as Date
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
        self.fsCalender.setCurrentPage(nextMonth, animated: true)
    }
}

//MARK: - FSCalendarDelegateAppearance
extension STCalenderVC : FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        let dateString : String = dateFormatter.string(from:date)
        
        var titleColor = UIColor()
        (arrActiveDates.contains(dateString)) ? (titleColor =  #colorLiteral(red: 0, green: 0.2684682608, blue: 0.4762560725, alpha: 1)) : (titleColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
        (date < fsCalender.minimumDate || date > fsCalender.maximumDate) ? (titleColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)) : (titleColor = titleColor)
        
        //        let datesCalender = dateFormatter.string(from: date)
        //        let dateLocalTimeZone = dateFormatter.string(from: Date())
        //        (datesCalender == dateLocalTimeZone) ? (titleColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)) : (titleColor = titleColor)
        
        return titleColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        let dateString : String = dateFormatter.string(from:date)
        
        var titleColor = UIColor()
        (arrActiveDates.contains(dateString)) ? (titleColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) : (titleColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
        (date < fsCalender.minimumDate || date > fsCalender.maximumDate) ? (titleColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)) : (titleColor = titleColor)
        
        //        let datesCalender = dateFormatter.string(from: date)
        //        let dateLocalTimeZone = dateFormatter.string(from: Date())
        //        (datesCalender == dateLocalTimeZone) ? (titleColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)) : (titleColor = titleColor)
        
        return titleColor
    }
}

//MARK: - FSCalendarDelegate
extension STCalenderVC: FSCalendarDataSource, FSCalendarDelegate {
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return fsMinDateWithFirstDayOfYear
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return fsMaxiDateWithLastDayOfYear
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    //MARK: - Date Selection here
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let selectedDateString : String = dateFormatter.string(from:date)
        dateFormatter.dateFormat = "HH:mm:ss"
        let currentDateString = dateFormatter.string(from: Date())
        let newDateStr = selectedDateString + " \(currentDateString)" + " +0000"
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss +zzzz"
        let newDate = dateFormatter.date(from: newDateStr)
        
        self.set(slectedDate: newDate!)
    }
}

// MARK: - UICollectionViewDataSource protocol
extension STCalenderVC : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! YearMonthCollectionCell
        cell.lblYearMonth.text = self.items[indexPath.item]
        cell.lblYearMonth.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch yearMonthIndex {
        case 1:
            yearMonthIndex = 0
            self.viewYearSelection.isHidden = true
            dateFormatter.dateFormat = "dd"
            let currentDay = dateFormatter.string(from: Date())
            let selectedYearMonthString = "\(currentDay)-\(indexPath.row+1)-\(String(describing: lblSelectedYear.text!))"
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let selectedYearMonthDate = dateFormatter.date(from: selectedYearMonthString)!
            fsCalender.setCurrentPage(selectedYearMonthDate, animated: false)
            fsCalender.select(selectedYearMonthDate)
            self.set(slectedDate: selectedYearMonthDate)
            break
        default:
            yearMonthIndex = 1
            lblSelectedYear.text = items[indexPath.row]
            btnYearMonthSelection.isSelected = false
            items = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"]
            //items = ["January","February","March","April","May","June","July","August","September","October","November","December"]
            collectionView.reloadData()
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/4-5, height: (collectionView.frame.size.height/5))
    }
}

