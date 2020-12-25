/*
 
 Copyright (c) <2020>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import Foundation

/**
 Configuration of a CSV File
 */
public struct CSVConfig {

    public init() {
        //
    }
    
    /// In theory this should be a comma for obvious reasons but then there is excel...
    public var delimiter : UInt8 = 0x2C
    /// Default line feed is Unix, but can be set manually
    public var eol : EOL = .LF
    public var enclose : Optional<UInt8> = 0x22
    
    public var format : [FormatSpecifier?] = []
    
    mutating func setDelimiter(to: Character){
        self.delimiter = to.asciiValue ?? 0x2C
    }
}


/// Format specifier for parsing and serilalizing `CSVValue`
public enum FormatSpecifier {
    
    case Date(format: DateFormatter? = nil)
    
    case Number(format: NumberFormatter? = nil)
    
    case Text(encoding: String.Encoding = .utf8)
}

/// Newline
public enum EOL : CaseIterable, CustomStringConvertible {

    /// *nix
    case LF

    /// Win
    case CR_LF

    /// Mac (oldschool)
    case CR
    
    /// IBM
    case NL
    
    public var description: String {
        
        switch self {
        case .LF:
            return "LF"
        case .CR:
            return "CR"
        case .CR_LF:
            return "CR LF"
        case .NL:
            return "NL"
        }
        
    }
}

extension DateFormatter {
    
    public convenience init(_ dateFormat: StringLiteralType) {
        self.init()
        
        self.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        self.timeZone = TimeZone(secondsFromGMT: 0)
        self.dateFormat = dateFormat
    }
}

extension NumberFormatter {
    
    public convenience init(_ decimalSeperator : StringLiteralType) {
        self.init()
        
        self.allowsFloats = true
        self.decimalSeparator = decimalSeparator
        
    }
    
}
