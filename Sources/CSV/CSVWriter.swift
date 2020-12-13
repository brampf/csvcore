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

extension CSVFile {
    
    public func write(to url: URL, config: CSVConfig) {
        
        do {
            var data = Data()
            try self.write(to: &data, config: config)
            
            try data.write(to: url)
            
        } catch {
            print(error)
        }
        
    }
    
    public func write(to: inout Data, config: CSVConfig) throws {
        
        try self.writeHead(to: &to, config: config)
        try self.writeLines(to: &to, config: config)
        
    }
    
    public func writeHead(to: inout Data, config: CSVConfig) throws {
        
        for idx in 0..<header.count {
            self.writeValue(CSVText(stringLiteral: header[idx]), to: &to, config: config, spec: FormatSpecifier.Text(encoding: .utf8))
            
            if idx < header.count-1 {
                to.append(config.delimiter)
            }
        }
        if !header.isEmpty{
            self.writeEOL(to: &to, config: config)
        }
    }
    
    public func writeLines(to: inout Data, config: CSVConfig) throws {
        
        for ridx in 0..<rows.count {
            let row = self.rows[ridx]
            for idx in 0..<row.count {
                
                let spec : FormatSpecifier? = idx < config.format.count ? config.format[idx] : nil
                
                self.writeValue(row[idx], to: &to, config: config, spec: spec)
                
                if idx < row.count-1 {
                    to.append(config.delimiter)
                }
            }
            
            if ridx < rows.count-1 {
                self.writeEOL(to: &to, config: config)
            }
        }
        
    }
    
    public func writeEOL(to: inout Data, config: CSVConfig) {
        
        switch config.eol {
        case .LF:
            to.append(0x0A)
        case .CR_LF:
            to.append(0x0D)
            to.append(0x0A)
        case .CR:
            to.append(0xD)
        case .NL:
            to.append(0x15)
        }
    }
    
    public func writeValue(_ val: CSVValue?, to: inout Data, config: CSVConfig, spec: FormatSpecifier?) {
        
        // we escape every value no questions asked
        if let encloser = config.enclose {
            to.append(encloser)
        }
        
        switch spec {
        case .Date(let format):
            if let date = val as? CSVDate {
                self.writeDate(date, to: &to, format: format)
            }
            
        case .Number(let format):
            if let number = val as? CSVNumber {
                self.writeNumber(number, to: &to, format: format)
            }
            
        case .Text(let encoding):
            if let text = val as? CSVText {
                self.writeText(text, to: &to, encoding: encoding)
            }
            
        case .none:
            to.append(val?.description ?? "")
        }
        
        // we escape every value no questions asked
        if let encloser = config.enclose {
            to.append(encloser)
        }
    }
    
    public func writeNumber(_ number: CSVNumber, to: inout Data, format: NumberFormatter?) {
        
        var string : String? = nil
        if let formatter = format {
            string = formatter.string(for: number.val) ?? ""
        } else {
            string = number.description
        }
        
        string?.withUTF8({ ptr in
            to.append(ptr)
        })
    }
    
    public func writeDate(_ date: CSVDate, to: inout Data, format: DateFormatter?) {
        
        var string : String? = nil
        if let formatter = format {
            string = formatter.string(for: date.val) ?? ""
        } else {
            string = date.description
        }
        
        string?.withUTF8({ ptr in
            to.append(ptr)
        })
    }
    
    public func writeText(_ text: CSVText, to: inout Data, encoding: String.Encoding?) {
        
        if let dat = text.val.data(using: encoding ?? .utf8) {
            to.append( dat)
        }
    }
    
}

extension Data {
    
    mutating func append(_ ascii : String){
        if let data = ascii.data(using: .ascii) {
            self.append(contentsOf: data)
        }
    }
    
}
