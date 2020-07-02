//
//  EncodableTypes.swift
//  FirestoreEncoderTest
//
//  Created by Bradley Mackey on 21/05/2020.
//  Copyright © 2020 Bradley Mackey. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum MyKey: String, Codable, Hashable {
    case one, two, three
}


struct ModelObject: Codable {
    
    @ServerTimestamp
    var myTime: Date? = Date()
    
    @RawValueEncode<[MyKey: String]>
    var myObj = [.one: "nice", .two: "very nice"]
    
    @RawValueEncode
    var test99: [MyKey: Int]
    
}


struct InitalisableModel: Codable {
    
    @RawValueEncode
    var test99: [MyKey: Int]
    
    init(test99: [MyKey: Int]) {
        self.test99 = test99
    }
    
}
