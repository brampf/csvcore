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
import FileReader

extension CSVRow : AnyReadable {
    
    public static func upperBound<C>(_ bytes: UnsafeRawBufferPointer, with context: inout C) throws -> Int? where C : Context {
        nil
    }
    
    public mutating func read<C>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?, upperBound: Int?) throws where C : Context {
        // don't re-read this
    }
  
    public static func new<C>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?) throws -> CSVRow? where C : Context {
        
        var new = Self()
        
        guard let csvContext = context as? CSVReaderContext, let config = context.config as? CSVConfig else {
            return nil
        }
        
        // local context
        csvContext.valueIndex = 0
        csvContext.valueStart = context.offset
        csvContext.valueEnd = context.offset
        
        // parser flags
        var enclosed = false
        var wasEnclosed = false
        var firstEOL = false
        var lineEnd = false
        
        var iterator = bytes.suffix(from: context.offset).makeIterator()
        while !lineEnd, let char = iterator.next() {
            
            if !enclosed {
                if char == config.enclose {
                    // we just hit a string delimiter
                    enclosed = true
                    // skip over this character
                    csvContext.valueStart += 1
                }
                if char == config.delimiter {
                    // read value
                    new.append(try CSVValue.new(bytes, with: &context, symbol))
                    // skip over this character
                    csvContext.valueStart += 1
                    if wasEnclosed {
                        csvContext.valueStart += 1
                        csvContext.valueEnd += 1
                        wasEnclosed = false
                    }
                }
                if char == 0x0A && config.eol == .LF {
                    // read last value in row
                    new.append(try CSVValue.new(bytes, with: &context, symbol))
                    // skip over this character
                    csvContext.valueStart += 1
                    // exit loop
                    lineEnd.toggle()
                }
                if char == 0x0D && config.eol == .CR {
                    // read last value in row
                    new.append(try CSVValue.new(bytes, with: &context, symbol))
                    // skip over this character
                    csvContext.valueStart += 1
                    // exit loop
                    lineEnd.toggle()
                }
                if char == 0x15 && config.eol == .NL {
                    // read last value in row
                    new.append(try CSVValue.new(bytes, with: &context, symbol))
                    // skip over this character
                    csvContext.valueStart += 1
                    // exit loop
                    lineEnd.toggle()
                }
                if char == 0x0D && config.eol == .CR_LF && !firstEOL {
                    // flag that we just hit the firstEOL character
                    firstEOL.toggle()
                }
                if char == 0x0A && config.eol == .CR_LF && firstEOL {
                    csvContext.valueEnd -= 1
                    // read last value in row
                    new.append(try CSVValue.new(bytes, with: &context, symbol))
                    // skip over this character
                    csvContext.valueStart += 2
                    // exit loop
                    lineEnd.toggle()
                }
            } else {
                
                if char == config.enclose {
                    // we just hit a string delimiter
                    enclosed = false
                    // skip over this character
                    csvContext.valueEnd -= 1
                    
                    wasEnclosed = true
                }
            }
            
            // move word pointer
            csvContext.valueEnd += 1
            // move the pointer
            context.offset += 1
        }
        if !lineEnd {
            // there is still a value to read
            new.append(try CSVValue.new(bytes, with: &context, symbol))
        }
        
        if new.values.compactMap({$0}).isEmpty {
            return nil
        }
        
        return new
    }
    
    public var byteSize: Int {
        values.byteSize
    }
    
}
