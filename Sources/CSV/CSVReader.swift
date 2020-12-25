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
 Parser implementation
 */
struct CSVReader {
    
    /**
     Parse `CSVFile` from raw data
     
     - Parameters:
        - data: Buffered pointer to the data
        - context: The `ReaderContext` to read the data
     */
    static func read(_ data: UnsafeRawBufferPointer, context: inout ReaderContext) -> CSVFile? {
        
        var new = CSVFile()
        
        
        // read head
        if !context.ignoreHead {
            context.ignoreFormat = true
            if context.offset < data.endIndex, let head = self.readLine(data, context: &context) {
                new.header = head.map{$0?.description ?? ""}
            }
            context.ignoreFormat = false
        }
        
        // read the file line by line until there is no more to read
        while context.offset < data.endIndex, let values = self.readLine(data, context: &context){
            // parse values
            new.rows.append(values)
        }
        
        return new
    }
    
    /**
     Parse `CSVRow` from raw data
     
     - Parameters:
        - data: Buffered pointer to the data
        - context: The `ReaderContext` to read the data
     */
    static func readLine(_ data: UnsafeRawBufferPointer, context: inout ReaderContext) -> CSVRow? {
        
        var row : CSVRow = .init()
        // local context
        context.valueIndex = 0
        context.valueStart = context.offset
        context.valueEnd = context.offset
 
        // parser flags
        var enclosed = false
        var wasEnclosed = false
        var firstEOL = false
        var lineEnd = false
        
        var iterator = data.suffix(from: context.offset).makeIterator()
        while !lineEnd, let char = iterator.next() {
            
            if !enclosed {
                if char == context.config.enclose {
                    // we just hit a string delimiter
                    enclosed = true
                    // skip over this character
                    context.valueStart += 1
                }
                if char == context.config.delimiter {
                    // read value
                    readValue(data, &context, &row)
                    // skip over this character
                    context.valueStart += 1
                    if wasEnclosed {
                        context.valueStart += 1
                        context.valueEnd += 1
                        wasEnclosed = false
                    }
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
            } else {
                
                if char == context.config.enclose {
                    // we just hit a string delimiter
                    enclosed = false
                    // skip over this character
                    context.valueEnd -= 1
                    
                    wasEnclosed = true
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
    
    /**
     Parse `CSVValue` from raw data
     
     - Parameters:
        - data: Buffered pointer to the data
        - context: The `ReaderContext` to read the data
        - row: The `CSVRow` currently read
     */
    static func readValue(_ data: UnsafeRawBufferPointer, _ context: inout ReaderContext, _ row: inout CSVRow) {
        
        var spec : FormatSpecifier? = nil
        if !context.ignoreFormat, !context.config.format.isEmpty,  context.valueIndex < context.config.format.count{
            spec = context.config.format[context.valueIndex]
        }
        
        let start = context.valueStart
        let end = context.valueEnd
        
        // we hit an empty value aka ",,"
        if start == end {
            return row.append(nil)
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
    
    /**
     Parse `CSVText` from raw data
     
     - Parameters:
        - record: the bounded section of raw data to read
        - encoding: the text encoding to use
     */
    static func readText(_ record: Slice<UnsafeRawBufferPointer>, _ encoding: String.Encoding) -> CSVText? {
        
        if let string = String(data: Data(record), encoding: encoding) {
            return CSVText(string)
        } else {
            return nil
        }
    }
    
    /**
     Parse `CSVNumber` from raw data
     
     - Parameters:
        - record: the bounded section of raw data to read
        - format: the `NumberFormatter`  to use in order to parse  the number value
     */
    static func readNumber(_ record: Slice<UnsafeRawBufferPointer>, _ format: NumberFormatter?) -> CSVNumber? {
        
        guard let string = String(data: Data(record), encoding: .ascii) else {
            return nil
        }

        let formatter = format ?? {
            let fallback = NumberFormatter()
            fallback.allowsFloats = true
            fallback.decimalSeparator = "."
            return fallback
        }()
        
        if let number = formatter.number(from: string)?.doubleValue {
            return CSVNumber(number)
        } else {
            return nil
        }
    }
    
    /**
     Parse `CSVDate` from raw data
     
     - Parameters:
        - record: the bounded section of raw data to read
        - format: the `DateFormatter`  to use in order to parse  the date
     */
    static func readDate(_ record: Slice<UnsafeRawBufferPointer>, _ format: DateFormatter?) -> CSVDate? {
        
        guard let string = String(data: Data(record), encoding: .ascii) else {
            return nil
        }
        
        let formatter = format ?? {
            let fallback = DateFormatter()
            fallback.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            fallback.timeZone = TimeZone(secondsFromGMT: 0)
            return fallback
        }()
        
        if let date = formatter.date(from: string){
            return CSVDate(date)
        } else {
            return nil
        }
    }
}

