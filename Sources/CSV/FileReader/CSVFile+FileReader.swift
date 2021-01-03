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

extension CSVFile : Root {

    

}

extension CSVFile : Node {
    public typealias Configuration = CSVConfig
    public typealias Context = CSVReaderContext
    
    
    public init?(_ data: UnsafeRawBufferPointer, context: inout CSVReaderContext) throws {
        
        // read head
        if !context.ignoreHead {
            context.ignoreFormat = true
            if context.offset < data.endIndex, let head = try CSVRow(data, context: &context) {
                self.header = head.map{$0?.description ?? ""}
            }
            context.ignoreFormat = false
        }
        
        // read the file line by line until there is no more to read
        while context.offset < data.endIndex, let values = try CSVRow(data, context: &context){
            // parse values
            self.rows.append(values)
        }
    }
    
}
