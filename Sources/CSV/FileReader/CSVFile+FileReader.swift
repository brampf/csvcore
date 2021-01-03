//
//  File.swift
//  
//
//  Created by May on 03.01.21.
//

import Foundation
import FileReader

extension CSVFile : Root {

    

}

extension CSVFile : Node {
    public typealias Configuration = CSVConfig
    public typealias Context = CSVReaderContext
    
    
    public init?(_ data: UnsafeRawBufferPointer, context: inout CSVReaderContext) {
        
        // read head
        if !context.ignoreHead {
            context.ignoreFormat = true
            if context.offset < data.endIndex, let head = CSVRow(data, context: &context) {
                self.header = head.map{$0?.description ?? ""}
            }
            context.ignoreFormat = false
        }
        
        // read the file line by line until there is no more to read
        while context.offset < data.endIndex, let values = CSVRow(data, context: &context){
            // parse values
            self.rows.append(values)
        }
    }
    
}
