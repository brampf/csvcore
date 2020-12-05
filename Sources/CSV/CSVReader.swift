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

struct CSVReader {
    
    static func read(_ data: UnsafeRawBufferPointer, context: inout ReaderContext) -> CSVFile? {
        
        var new = CSVFile()
        
        
        // read head
        if !context.skipHead {
            if context.offset < data.endIndex, let head = self.readLine(data, context: &context) as? [String] {
                new.header = head
            }
        }
        
        
        // read the file line by line until there is no more to read
        while context.offset < data.endIndex, let values = self.readLine(data, context: &context){
            // parse values
            new.rows.append(values)
        }
        
        return new
    }
    
    static func readLine(_ data: UnsafeRawBufferPointer, context: inout ReaderContext) -> [CSVValue?]? {
        
        var row : [CSVValue?] = .init()
        // local context
        context.valueIndex = 0
        context.valueStart = context.offset
        context.valueEnd = context.offset
 
        // parser flags
        var enclosed = false
        var firstEOL = false
        var lineEnd = false
        
        var iterator = data.suffix(from: context.offset).makeIterator()
        while !lineEnd, let char = iterator.next() {
            
            if char == context.config.enclose {
                // we just hit a string delimiter
                if !enclosed {
                    context.valueStart += 1
                }
                
                enclosed.toggle()
            }
            if !enclosed {
                
                if char == context.config.delimiter {
                    // read value
                    readValue(data, &context, &row)
                    // skip over this character
                    context.valueStart += 1
                }
                if char == 0x0A && context.config.eol == .LF {
                    // read last value in row
                    readValue(data, &context, &row)
                    // skip over this character
                    context.valueStart += 1
                    // exit loop
                    lineEnd.toggle()
                }
                if char == 0x0D && context.config.eol == .CR {
                    // read last value in row
                    readValue(data, &context, &row)
                    // skip over this character
                    context.valueStart += 1
                    // exit loop
                    lineEnd.toggle()
                }
                if char == 0x15 && context.config.eol == .NL {
                    // read last value in row
                    readValue(data, &context, &row)
                    // skip over this character
                    context.valueStart += 1
                    // exit loop
                    lineEnd.toggle()
                }
                if char == 0x0D && context.config.eol == .CR_LF && !firstEOL {
                    // flag that we just hit the firstEOL character
                    firstEOL.toggle()
                }
                if char == 0x0A && context.config.eol == .CR_LF && firstEOL {
                    context.valueEnd -= 1
                    // read last value in row
                    readValue(data, &context, &row)
                    // skip over this character
                    context.valueStart += 2
                    // exit loop
                    lineEnd.toggle()
                }
            }
            
            // move word pointer
            context.valueEnd += 1
            // move the pointer
            context.offset += 1
        }
        if !lineEnd {
            // there is still a value to read
            readValue(data, &context, &row)
        }
        
        if row.compactMap({$0}).isEmpty {
            return nil
        } else {
            return row
        }
    }
    
    static func readValue(_ data: UnsafeRawBufferPointer, _ context: inout ReaderContext, _ row: inout [CSVValue?]) {
        
        var spec : FormatSpecifier? = nil
        if !context.config.format.isEmpty,  context.valueIndex < context.config.format.count{
            spec = context.config.format[context.valueIndex]
        }
        
        var start = context.valueStart
        var end = context.valueEnd
        
        if start == end {
            return row.append(nil)
        }
        
        if let escaped = context.config.enclose {
            if data[start] == escaped { start += 1 }
            if data[end-1] == escaped { end -= 1 }
        }
        
        // now parse the value
        var value : CSVValue?
        switch spec {
        case .Text(let encoding):
            value = readText(data[start..<end], encoding)
        case .Number(let format):
            value = readNumber(data[start..<end], format)
        case .Date(let format):
            value = readDate(data[start..<end], format)
        case .none:
            // without context, we try to read text
            value = readText(data[start..<end], .utf8)
        }
        //print("\(start)...\(end); val \(context.valueIndex) = \(value.debugDescription)")
        
        row.append(value)
        
        // increment value count
        context.valueIndex += 1
        // move the word pointer
        context.valueStart = end
    }
    
    static func readValue(_ record: Slice<UnsafeRawBufferPointer>, _ spec: FormatSpecifier?, _ context: inout ReaderContext) -> CSVValue? {
        
        var start = record.startIndex
        var end = record.endIndex
        
        if let escaped = context.config.enclose {
            if record.first == escaped { start += 1 }
            if record.last == escaped { end -= 1 }
        }
        
        switch spec {
        case .Text(let encoding):
            return self.readText(record[start..<end], encoding)
        case .Number(let format):
            return self.readNumber(record[start..<end], format)
        case .Date(let format):
            return self.readDate(record[start..<end], format)
        default:
            return self.readText(record[start..<end], .utf8)
        }
    }
    
    static func readText(_ record: Slice<UnsafeRawBufferPointer>, _ encoding: String.Encoding) -> String? {
        
        return String(data: Data(record), encoding: encoding)
    }
    
    /// read a number
    static func readNumber(_ record: Slice<UnsafeRawBufferPointer>, _ format: NumberFormatter?) -> Double? {
        
        guard let string = String(data: Data(record), encoding: .ascii) else {
            return nil
        }
        
        let formatter = format ?? {
            let fallback = NumberFormatter()
            fallback.allowsFloats = true
            fallback.decimalSeparator = "."
            return fallback
        }()
        
        return formatter.number(from: string)?.doubleValue
    }
    
    /// read a date
    static func readDate(_ record: Slice<UnsafeRawBufferPointer>, _ format: DateFormatter?) -> Date? {
        
        guard let string = String(data: Data(record), encoding: .ascii) else {
            return nil
        }
        
        let formatter = format ?? {
            let fallback = DateFormatter()
            fallback.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            fallback.timeZone = TimeZone(secondsFromGMT: 0)
            return fallback
        }()
        
        return formatter.date(from: string)
    }
}

