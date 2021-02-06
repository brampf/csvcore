import XCTest
@testable import CSV

final class ReaderTests: XCTestCase {
    
    static var allTests = [
        ("testReadString", testReadString),
        ("testReadNumber", testReadNumber),
        ("testReadDate", testReadDate),
        ("testReadLines", testReadLines),
        ("testReadLines2", testReadLines2),
        ("testReadLines3", testReadLines3),
        ("testReadLines4", testReadLines4),
        ("testReadLines5", testReadLines5),
        ("testReadValues", testReadValues)
    ]
    
    func testReadString() {
        
        let string1 = "Hello World".data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVText(ptr.suffix(from: 0), with: .utf8)
        })
        
        XCTAssertEqual(string1, "Hello World")
        
        let string2 = "Hello, World".data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVText(ptr.suffix(from: 0), with: .utf8)
        })
        
        XCTAssertEqual(string2, "Hello, World")
    }
    
    func testReadNumber() {
        
        let integer = "42".data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVNumber(ptr.suffix(from: 0), with: nil)
        })
        
        XCTAssertEqual(integer, 42)
     
        
        let float_dot = "32.32".data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVNumber(ptr.suffix(from: 0), with: nil)
        })
        
        XCTAssertEqual(float_dot, 32.32)
        
        let float_comma = "23,23".data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVNumber(ptr.suffix(from: 0), with: NumberFormatter(","))
        })
        
        XCTAssertEqual(float_comma, 23.23)
        
        let formatter = NumberFormatter()
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        let accounting = "-100.000,00".data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVNumber(ptr.suffix(from: 0), with: formatter)
        })
        
        XCTAssertEqual(accounting, -100000)
    }
    
    func testReadDate() {
        
        let date1 = "01.11.2020".data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVDate(ptr.suffix(from: 0), with: DateFormatter("dd.MM.yyyy"))
        })
        
        XCTAssertEqual(date1, CSVDate(DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 01, hour: 0, minute: 0, second: 0)))
        
        
        let date2 = "2020/11/02".data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVDate(ptr.suffix(from: 0), with: DateFormatter("yyyy/MM/dd"))
        })
        
        XCTAssertEqual(date2, CSVDate(DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 02, hour: 0, minute: 0, second: 0)))
        
        let date3 = "2020-11-03".data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVDate( ptr.suffix(from: 0), with: DateFormatter("yyyy-MM-dd"))
        })
        
        XCTAssertEqual(date3, CSVDate(DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 03, hour: 0, minute: 0, second: 0)))
        
        let date4 = "2020-11-04T10:45:00+0000".data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVDate(ptr.suffix(from: 0), with: DateFormatter("yyyy-MM-dd'T'HH:mm:ssZZZ"))
        })
        
        XCTAssertEqual(date4, CSVDate(DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 04, hour: 10, minute: 45, second: 0)))
    }
    
    func testReadRow() throws {
        
        let data = "One,Two,Three".data(using: .utf8)!
        
        var context = CSVReaderContext()
        let row = try data.withUnsafeBytes { ptr in
            try CSVRow.readElement(ptr, with: &context, nil)
        }
        
        XCTAssertNotNil(row)
        XCTAssertEqual(row?.count, 3)
        XCTAssertEqual(row, ["One","Two","Three"])
        
        XCTAssertEqual(context.offset, 13)
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
    }
    
    func testReadLines2() {
        
        let config = CSVConfig()
        
        XCTAssertSame("\n", config, [])
        
        XCTAssertSame(",\n,", config, [])
        
        XCTAssertSame("\"\",\n,", config, [])
        
        XCTAssertSame("\",\"\n,", config, [[","]])
        
    }
    
    func testReadLines3() {
        
        let config = CSVConfig()
        
        XCTAssertSame("Hello\nWorld", config, [["Hello"],["World"]])
        
        XCTAssertSame("Hello,World", config, [["Hello","World"]])
        
        XCTAssertSame("\"Hello\"\n\"World\"", config, [["Hello"],["World"]])
        
        XCTAssertSame("Hello\n\"World\"", config, [["Hello"],["World"]])
        
        XCTAssertSame("\"Hello\"\nWorld", config, [["Hello"],["World"]])
        
        XCTAssertSame("\"Hello\",\"World\"", config, [["Hello","World"]])
        
        XCTAssertSame("\"Hello\",World", config, [["Hello","World"]])
        
        XCTAssertSame("Hello,\"World\"", config, [["Hello","World"]])
        
        XCTAssertSame("\"Hello\",\"World\"\nHallo,Welt", config, [["Hello","World"],["Hallo","Welt"]])
        
        XCTAssertSame("Hello,\"World\"\nHallo,Welt", config, [["Hello","World"],["Hallo","Welt"]])
        
        XCTAssertSame("Hello,\"World\"\n\"Hallo\",Welt", config, [["Hello","World"],["Hallo","Welt"]])
    }
    
    func testReadLines4() {
        
        var config = CSVConfig()
        config.eol = .LF
        config.format = .init(arrayLiteral:
                                nil, // FormatSpecifier.Text(encoding: .utf8),
                              FormatSpecifier.Number(),
                              FormatSpecifier.Number(format: NumberFormatter(",")),
                              FormatSpecifier.Number(),
                              FormatSpecifier.Date(format: DateFormatter("dd.MM.yyyy")),
                              FormatSpecifier.Date(format: DateFormatter("yyyy/MM/dd")),
                              FormatSpecifier.Date(format: DateFormatter("yyyy-MM-dd")))
        
        
        XCTAssertSame("\"One\",\"42\",\"23,32\",\"32.32\",\"21.12.2012\",\"2020/11/02\",\"2020-11-03\"", config,
                      [["One",42.0,23.32,32.32,
                        DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2012, month: 12, day: 21, hour: 0, minute: 0, second: 0).date!,
                        DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 02, hour: 0, minute: 0, second: 0).date!,
                        DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 03, hour: 0, minute: 0, second: 0).date!]])
        
    }
    
    func testReadLines5() {
        
        let config = CSVConfig()
        
        XCTAssertSame("2019,Level 1,AA,\"Agriculture, Forestry and Fishing\",Dollars (millions),H10,Indirect taxes,Financial performance,475,ANZSIC06 division A", config,  [["2019","Level 1","AA","Agriculture, Forestry and Fishing","Dollars (millions)","H10","Indirect taxes","Financial performance","475","ANZSIC06 division A"]])
        
    }
    
    func testReadValues() {
        
        let line1 = "Test,42,23.43,\"-100.000,00\",\"Hello, World\",\"31.12.2020\""
        
        let formatter = NumberFormatter()
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        var config = CSVConfig()
        config.format = [
            FormatSpecifier.Text(encoding: .utf8),
            FormatSpecifier.Text(),
            FormatSpecifier.Number(format: nil),
            FormatSpecifier.Number(format: formatter),
            FormatSpecifier.Text(),
            FormatSpecifier.Date(format: DateFormatter("dd.MM.yyyy"))
        ]
        
        
        var context = CSVReaderContext(using: config, out: nil)
        
        let result1 = line1.data(using: .utf8)?.withUnsafeBytes({ ptr in
            try? CSVRow.readElement(ptr, with: &context, nil)
        })
        
        XCTAssertEqual(result1?.count, 6)
        XCTAssertEqual(result1?[0], CSVText("Test"))
        XCTAssertEqual(result1?[1], CSVText("42"))
        XCTAssertEqual(result1?[2], CSVNumber(23.43))
        XCTAssertEqual(result1?[3], CSVNumber(-100000.0))
        XCTAssertEqual(result1?[4], CSVText("Hello, World"))
        XCTAssertEqual(result1?[5], CSVDate(DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 12, day: 31, hour: 0, minute: 0, second: 0)))
        
        
    }
}
