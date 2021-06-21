/*
 * Developement Part, SOLTER INC., SEOUL, KOREA
 * Copyright(c) 2014 by Solter Inc.
 *
 * All rights reserved. No part of this work may be reproduced, stored in a
 * retrieval system, or transmitted by any means without prior written
 * Permission of Solter Inc.
 */

import Foundation


open class ModiDate : NSObject {
    
    public static func getSimpleTimestamp() -> String {
        
        let date:Date = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
    
    public static func getTimestamp() -> String {
        
        let date:Date = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        //dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: date)
    }
    
    public static func getUTCTimestamp() -> String {
        
        let date:Date = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: date)
    }
    
    public static func getUTCFormattedDate(_ date: Date, format: String?) -> String {
        
        let dateFormatter:DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format ?? "yyyyMMddHHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: date)
    }
    
    public static func getFormattedDate(_ date: Date, format: String?, timezone: String?) -> String {
        
        let dateFormatter:DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format ?? "yyyyMMddHHmmss"
        if timezone != nil {
            dateFormatter.timeZone = TimeZone(abbreviation: timezone!)
        }
        
        return dateFormatter.string(from: date)
    }
    
    static func getDate(year: UInt16, month: UInt8, day: UInt8, hour: UInt8, minute: UInt8, second: UInt8, timeOffset: Int8) -> Date {
        
        let timezone: TimeZone = TimeZone(secondsFromGMT: (Int(timeOffset)/4)*(60*60))!
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(year)
        dateComponents.month = Int(month)
        dateComponents.day = Int(day)
        dateComponents.hour = Int(hour)
        dateComponents.minute = Int(minute)
        dateComponents.second = Int(second)
        dateComponents.timeZone = timezone
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = calendar.date(from: dateComponents)
        
        return date!
    }
    
    static func getDate(year: UInt16, month: UInt8, day: UInt8, hour: UInt8, minute: UInt8, second: UInt8) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(year)
        dateComponents.month = Int(month)
        dateComponents.day = Int(day)
        dateComponents.hour = Int(hour)
        dateComponents.minute = Int(minute)
        dateComponents.second = Int(second)
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = calendar.date(from: dateComponents)
       
        return date!
    }
    
    static func getDate(year: UInt16, month: UInt8, day: UInt8) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(year)
        dateComponents.month = Int(month)
        dateComponents.day = Int(day)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = calendar.date(from: dateComponents)
        return date!
    }
    
    static func getDateByInt(year: Int32, month: Int32, day: Int32, hour: Int32, minute: Int32, second: Int32) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(year)
        dateComponents.month = Int(month)
        dateComponents.day = Int(day)
        dateComponents.hour = Int(hour)
        dateComponents.minute = Int(minute)
        dateComponents.second = Int(second)
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = calendar.date(from: dateComponents)
        return date!
    }
    
    static func getDateByInt(year: Int32, month: Int32, day: Int32) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(year)
        dateComponents.month = Int(month)
        dateComponents.day = Int(day)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = calendar.date(from: dateComponents)
        return date!
    }

    
    public static func getDateString(year: UInt16, month: UInt8, day: UInt8) -> String {
        
        let date = getDate(year: year, month: month, day: day)
        return getFormattedDate(date, format: "yyyy-MM-dd", timezone: nil)
    }
    
    @objc public static func getDateStringWithInt(year: Int32, month: Int32, day: Int32) -> String {
        
        let date = getDateByInt(year: year, month: month, day: day)
        return getFormattedDate(date, format: "yyyy-MM-dd", timezone: nil)
    }

    
    public static func getDateString(year: UInt16, month: UInt8, day: UInt8, hour: UInt8, minute: UInt8, second: UInt8) -> String {
        
        let date = getDate(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        return getFormattedDate(date, format: "yyyy-MM-dd HH:mm:ss", timezone: nil)
    }
    
    @objc public static func getDateStringWithInt(year: Int32, month: Int32, day: Int32, hour: Int32, minute: Int32, second: Int32) -> String {
        
        let date = getDateByInt(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        return getFormattedDate(date, format: "yyyy-MM-dd HH:mm:ss", timezone: nil)
    }
    
    static func getTimeOffsetHour() -> Int {
        
       // let timezone:NSTimeZone? = NSTimeZone(abbreviation: String(NSLocale.currentLocale().objectForKey(NSLocaleCountryCode)))
        let timezone:TimeZone? = TimeZone.autoupdatingCurrent
        
        if timezone == nil {
            return 0
        } else {
            ModiLog.d("getTimeOffsetHour", messages: "\(timezone!.secondsFromGMT())")
            let timeseconds = timezone!.secondsFromGMT()
            
            // 2018 01 29 변경: 15분 단위로 표현되도록 변경
            return timeseconds/(60*60)*4

        }
    }
}
