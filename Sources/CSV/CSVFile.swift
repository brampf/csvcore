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

struct CSVFile {
    
    var header : [String] = []
    var rows : [[CSVValue]] = []
    
}

extension CSVFile {
    
    public static func read(contentsOf url: URL, options: Data.ReadingOptions = []) throws -> CSVFile? {
        
        let data = try Data(contentsOf: url, options: options)
        return self.read(data)
        
    }
    
    public static func read(_ data: Data,_ spec: [FormatSpecifier?] = []) -> CSVFile? {
        
        var context = ReaderContext()
        context.format = spec
        
        return data.withUnsafeBytes { bytes in
            CSVFile.read(bytes, context: &context)
        }
        
    }
    
    static func read(_ data: UnsafeRawBufferPointer, context: inout ReaderContext) -> Self? {
        
        var new = CSVFile()

        
        // read head
        if !context.skipHead {
            if let head = self.readLine(data, context: &context){
                new.header = self.readHead(head, context: &context)
                context.offset = head.endIndex + 1
            }
        }
            
        
        // read the file line by line until there is no more to read
        while let record = self.readLine(data, context: &context){
            // parse values
            let row = readValues(record, context: &context)
            new.rows.append(row)
            // move offset to read the next recored
            context.offset = record.endIndex + 1
        }
        
        return new
    }
    
    static func readLine(_ data: UnsafeRawBufferPointer, context: inout ReaderContext) -> Slice<UnsafeRawBufferPointer>? {
        
        let start = context.offset
        var stop : Int? = nil
        
        switch context.eol {
        case .CR:
            stop = data.suffix(from: start).firstIndex { char in
                var closed = true
                if char == context.enclose { closed.toggle() }
                if char == 0x0D && closed { return true }
                return false
            }
        case .LF:
            stop = data.suffix(from: start).firstIndex { char in
                var closed = true
                if char == context.enclose { closed.toggle() }
                if char == 0x0A && closed { return true }
                return false
            }
        case .CR_LF:
            var closed = true
            var cr = false
            stop = data.suffix(from: start).firstIndex { char in
                if char == context.enclose { closed.toggle() }
                if char == 0x0D { cr = true }
                if char == 0x0A && closed && cr { return true }
                return false
            }
        case .NL:
            stop = data.suffix(from: start).firstIndex { char in
                var closed = true
                if char == context.enclose { closed.toggle() }
                if char == 0x15 && closed { return true }
                return false
            }
        }
        
        if let stop = stop {
            return Slice(base: data, bounds: start..<stop)
        } else {
            return nil
        }
    }
    
    static func readHead(_ record: Slice<UnsafeRawBufferPointer>, context: inout ReaderContext) -> [String] {
        
        return record.split(separator: context.delimiter).map { data in
            return String(data: Data(data), encoding: .utf8) ?? ""
        }
        
    }
    
    static func readValues(_ record: Slice<UnsafeRawBufferPointer>, context: inout ReaderContext) -> [CSVValue] {
    
        var row : [CSVValue] = .init()
            
        var column = 0
        var enclosed = false
        
        while let nextOffset = record.suffix(from: context.offset).firstIndex(where: { char in
            if char == context.enclose { enclosed.toggle() }
            if char == context.delimiter && !enclosed { return true }
            return false
        }){
            let spec : FormatSpecifier? = context.format.count > column ? context.format[column] : nil
            
            if let val = readValue(record[context.offset...nextOffset-1], spec, context){
                row.append(val)
            }
            
            context.offset = nextOffset+1
            column += 1
            
        }        
        
        return row
    }
    
    static func readValue(_ record: Slice<UnsafeRawBufferPointer>, _ spec: FormatSpecifier?, _ context: ReaderContext) -> CSVValue? {
        
        var start = record.startIndex
        var end = record.endIndex
        
        if let escaped = context.enclose {
            if record.first == escaped { start += 1 }
            if record.last == escaped { end -= 1 }
        }
    
        switch spec {
        case .Text(let encoding):
            return self.readText(record[start..<end], encoding)
        case .Number(let decimal):
            return self.readNumber(record[start..<end], decimal)
        case .Date(let format):
            return self.readDate(record[start..<end], format)
        default:
            return self.readText(record[start..<end], .utf8)
        }
    }
    
    static func readText(_ record: Slice<UnsafeRawBufferPointer>, _ encoding: String.Encoding) -> String? {
        
        return String(data: Data(record), encoding: encoding)
    }
 
    static func readNumber(_ record: Slice<UnsafeRawBufferPointer>, _ seperator: String?) -> Double? {
        
        guard let string = String(data: Data(record), encoding: .ascii) else {
            return nil
        }
        
        let format = NumberFormatter()
        format.decimalSeparator = seperator
        return format.number(from: string)?.doubleValue
    }
    
    static func readDate(_ record: Slice<UnsafeRawBufferPointer>, _ template: String?) -> Date? {
        
        guard let string = String(data: Data(record), encoding: .ascii) else {
            return nil
        }
        
        let format = DateFormatter()
        format.locale = Locale.current
        if let template = template {
            format.setLocalizedDateFormatFromTemplate(template)
            format.timeZone = TimeZone(secondsFromGMT: 0)
        }
        
        return format.date(from: string)
    }
}

