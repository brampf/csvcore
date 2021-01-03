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

extension CSVRow : Node {
    
    public typealias Configuration = CSVConfig
    public typealias Context = CSVReaderContext
    
    
    /**
     Parse `CSVRow` from raw data
     
     - Parameters:
     - data: Buffered pointer to the data
     - context: The `ReaderContext` to read the data
     */
    public init?(_ data: UnsafeRawBufferPointer, context: inout CSVReaderContext) throws {
        
        self.init()
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
                    self.append(try CSVValue.read(data, context: &context))
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
                    self.append(try CSVValue.read(data, context: &context))
                    // skip over this character
                    context.valueStart += 1
                    // exit loop
                    lineEnd.toggle()
                }
                if char == 0x0D && context.config.eol == .CR {
                    // read last value in row
                    self.append(try CSVValue.read(data, context: &context))
                    // skip over this character
                    context.valueStart += 1
                    // exit loop
                    lineEnd.toggle()
                }
                if char == 0x15 && context.config.eol == .NL {
                    // read last value in row
                    self.append(try CSVValue.read(data, context: &context))
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
                    self.append(try CSVValue.read(data, context: &context))
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
            self.append(try CSVValue.read(data, context: &context))
        }
        
        if self.compactMap({$0}).isEmpty {
            return nil
        }
    }
    
}
