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

enum MyKey: String, Codable {
    case one, two, three
}


struct ModelObject: Codable {
    
    @ServerTimestamp
    var myTime: Date? = Date()
    
    @RawTypeEncoding<[MyKey: String]>
    var myObj = [.one: "nice", .two: "very nice"]
    
    @RawTypeEncoding
    var test99: [MyKey: Int]
    
}


struct InitalisableModel: Codable {
    
    @RawTypeEncoding
    var test99: [MyKey: Int]
    
}
