import XCTest
@testable import CSV

final class ReaderTests: XCTestCase {
    
    static var allTests = [
        ("testReadString", testReadString),
        ("testReadNumber", testReadNumber),
        ("testReadDate", testReadDate)
    ]
    
    func testReadString() {
        
        let string1 = "Hello World".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readText(ptr.suffix(from: 0), .utf8)
        })
        
        XCTAssertEqual(string1, "Hello World")
        
        let string2 = "Hello, World".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readText(ptr.suffix(from: 0), .utf8)
        })
        
        XCTAssertEqual(string2, "Hello, World")
    }
    
    func testReadNumber() {
        
        let integer = "42".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readNumber(ptr.suffix(from: 0), nil)
        })
        
        XCTAssertEqual(integer, 42)
     
        
        let float_dot = "23.23".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readNumber(ptr.suffix(from: 0), nil)
        })
        
        XCTAssertEqual(float_dot, 23.23)
        
        let float_comma = "23,23".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readNumber(ptr.suffix(from: 0), NumberFormatter(","))
        })
        
        XCTAssertEqual(float_comma, 23.23)
        
        let formatter = NumberFormatter()
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        let accounting = "-100.000,00".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readNumber(ptr.suffix(from: 0), formatter)
        })
        
        XCTAssertEqual(accounting, -100000)
    }
    
    func testReadValue() {
        
        let config = CSVConfig()
        var context = ReaderContext(config: config)
        
        let test1 = "Hello World".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readValue(ptr.suffix(from: 0), nil, &context)
        })
        
        XCTAssertSame(test1, "Hello World")
        
        let test2 = "\"Hello World\"".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readValue(ptr.suffix(from: 0), nil, &context)
        })
        
        XCTAssertSame(test2, "Hello World")
        
        let formatter = NumberFormatter()
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        let test3 = "\"-100.000,00\"".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readValue(ptr.suffix(from: 0), FormatSpecifier.Number(format: formatter), &context)
        })
        
        XCTAssertSame(test3, -100000.0)
        
        let test4 = "\"43,43\"".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readValue(ptr.suffix(from: 0), FormatSpecifier.Number(format: NumberFormatter(",")), &context)
        })
        
        XCTAssertSame(test4, 43.43)
    }
    
    func testReadDate() {
        
        let date1 = "01.11.2020".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readDate(ptr.suffix(from: 0), DateFormatter("dd.MM.yyyy"))
        })
        
        XCTAssertEqual(date1, DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 01, hour: 0, minute: 0, second: 0).date!)
        
        
        let date2 = "2020/11/02".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readDate(ptr.suffix(from: 0), DateFormatter("yyyy/MM/dd"))
        })
        
        XCTAssertEqual(date2, DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 02, hour: 0, minute: 0, second: 0).date!)
        
        let date3 = "2020-11-03".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readDate(ptr.suffix(from: 0), DateFormatter("yyyy-MM-dd"))
        })
        
        XCTAssertEqual(date3, DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 03, hour: 0, minute: 0, second: 0).date!)
        
        let date4 = "2020-11-04T10:45:00+0000".data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readDate(ptr.suffix(from: 0), DateFormatter("yyyy-MM-dd'T'HH:mm:ssZZZ"))
        })
        
        XCTAssertEqual(date4, DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 04, hour: 10, minute: 45, second: 0).date!)
    }
    
    func testReadLines() {
        
        var config = CSVConfig()
        config.eol = .LF
        
        XCTAssertSame("One\nTwo\nThree\nFour\n", config, [["One"],["Two"],["Three"],["Four"]])
        
        XCTAssertSame("One\nTwo\nThree\nFour", config, [["One"],["Two"],["Three"],["Four"]])
        
        XCTAssertSame("One\nTwo\n\rThree\nFour\n", config, [["One"],["Two"],["\rThree"],["Four"]])
        
        config.eol = .CR_LF
        XCTAssertSame("One\r\nTwo\r\nThree\r\nFour\r\n", config,  [["One"],["Two"],["Three"],["Four"]])
        
        config.eol = .LF
        XCTAssertSame("\"One\"\n\"Two\"\n\"Three\"\n\"Four\"\n", config, [["One"],["Two"],["Three"],["Four"]])
        
        config.format = [.Number(),.Number()]
        XCTAssertSame("11,12\n21,22\n31,32\n41,42\n", config,  [[11,12],[21,22],[31,32],[41,42]])
        
        XCTAssertSame("11,12\n21,22\n31,32\n41,42", config, [[11,12],[21,22],[31,32],[41,42]])

        XCTAssertSame("\n", config, [[nil]])
        
        XCTAssertSame(",\n,", config, [[nil,nil],[nil,nil]])
    }
    
    func testReadValues() {
        
        let line1 = "Test,42,23.43,\"-100.000,00\",\"31.12.2020\""
        
        let formatter = NumberFormatter()
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        var config = CSVConfig()
        config.format = [
            FormatSpecifier.Text(encoding: .utf8),
            FormatSpecifier.Number(format: nil),
            FormatSpecifier.Number(format: nil),
            FormatSpecifier.Number(format: formatter),
            FormatSpecifier.Date(format: DateFormatter("dd.MM.yyyy"))
        ]
        
        
        var context = ReaderContext(config: config)
        
        let result1 = line1.data(using: .utf8)?.withUnsafeBytes({ ptr in
            CSVReader.readLine(ptr, context: &context)
        })
        
        
        
        XCTAssertEqual(result1?.count, 5)
        XCTAssertSame(result1?[0], "Test")
        XCTAssertSame(result1?[1], 42.0)
        XCTAssertSame(result1?[2], 23.43)
        XCTAssertSame(result1?[3], -100000.0)
        XCTAssertSame(result1?[4], DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 12, day: 31, hour: 0, minute: 0, second: 0).date!)
        
        
    }
}
