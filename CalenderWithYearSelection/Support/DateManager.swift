//
//  DateManager.swift
//  USPA
//
//  Created by Shrikant on 11/28/16.
//  Copyright © 2016 Techteam. All rights reserved.
//

import UIKit

class DateManager: NSObject {
   
    fileprivate var minimumDate = Date()
    fileprivate var maximumDate = Date()
    
    static var sharedInstance = DateManager()
    
    override init() {
        super.init()
        dataCompareator()
    }
    
    //MARK: - Date Compare here
    fileprivate func dataCompareator(){
        let currentDate: NSDate = NSDate()
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
        let components: NSDateComponents = NSDateComponents()
        components.calendar = calendar as Calendar
        components.year = 0
        components.month = 0
        components.day = -1
        let minDate: NSDate = calendar.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        components.year = 0
        components.month = 3
        components.day = 0
        let maxDate: NSDate = calendar.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        print("minDate: \(minDate)")
        print("maxDate: \(maxDate)")
        minimumDate = minDate as Date
        maximumDate = maxDate as Date
    }
    
    private func compareDates(_ currentDate: Date, maxDate :Date) -> Bool{
        let dateComparisionResult:ComparisonResult = currentDate.compare(maxDate as Date)
        
        if dateComparisionResult == ComparisonResult.orderedAscending
        {
            // Current date is smaller than end date. **true
            return true
        }
        else if dateComparisionResult == ComparisonResult.orderedDescending
        {
            // Current date is greater than end date. **false
            return false
        }
        else if dateComparisionResult == ComparisonResult.orderedSame
        {
            // Current date and end date are same.
            return false
        }
        return false
    }
    
    //MARK: - Maximum date for Calander
    func maximumDateForCalander() -> Date{
        return maximumDate
    }
    
    //MARK: - Minimum date for Calander
    func minimumDateForCalander() -> Date{
        return minimumDate
    }

    func resultWithMyDate(currentData: Date) -> Bool{
        let firstDate = compareDates(currentData, maxDate: minimumDate) // Should be false
        let secDate = compareDates(currentData, maxDate: maximumDate) // Should be true
        guard firstDate == false, secDate == true else {
            return false
        }
        return true
    }

}

