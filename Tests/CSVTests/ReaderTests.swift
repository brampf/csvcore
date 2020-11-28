import XCTest
@testable import CSV

final class ReaderTests: XCTestCase {
    
    static var allTests = [
        ("testReadString",testReadString)
    ]
    
    func testReadString() {
        
        let string = "Hello World".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVFile.readText(ptr.suffix(from: 0), .utf8)
        })
        
        XCTAssertEqual(string, "Hello World")
        
    }
    
    func testReadNumber() {
        
        let integer = "42".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVFile.readNumber(ptr.suffix(from: 0), nil)
        })
        
        XCTAssertEqual(integer, 42)
     
        
        let float_dot = "23.23".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVFile.readNumber(ptr.suffix(from: 0), nil)
        })
        
        XCTAssertEqual(float_dot, 23.23)
        
        let float_comma = "23,23".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVFile.readNumber(ptr.suffix(from: 0), ",")
        })
        
        XCTAssertEqual(float_comma, 23.23)
    }
    
    func testReadDate() {
        
        let date1 = "01.11.2020".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVFile.readDate(ptr.suffix(from: 0), "dd.MM.yyyy")
        })
        
        XCTAssertEqual(date1, DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 01, hour: 0, minute: 0, second: 0).date!)
        
        
        let date2 = "2020/11/02".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVFile.readDate(ptr.suffix(from: 0), "yyyy/MM/dd")
        })
        
        XCTAssertEqual(date2, DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 02, hour: 0, minute: 0, second: 0).date!)
        
        let date3 = "2020-11-03".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVFile.readDate(ptr.suffix(from: 0), "yyyy-MM-dd")
        })
        
        XCTAssertEqual(date3, DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 03, hour: 0, minute: 0, second: 0).date!)
    }
}
