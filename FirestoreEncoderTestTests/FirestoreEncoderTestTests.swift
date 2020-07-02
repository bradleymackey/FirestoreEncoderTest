//
//  FirestoreEncoderTestTests.swift
//  FirestoreEncoderTestTests
//
//  Created by Bradley Mackey on 21/05/2020.
//  Copyright © 2020 Bradley Mackey. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseFirestoreSwift
@testable import FirestoreEncoderTest

class FirestoreEncoderTestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results
        let myObj = ModelObject()
        print(myObj.test99)
        print("two", myObj.myObj[.two])
        print("The raw dict:")
        dump(myObj)
        let encoded = try! Firestore.Encoder().encode(myObj)
        print("Now encoding...")
        dump(encoded)
    }
    
    func testInit() throws {
        let initObj = InitalisableModel(test99: [.one: 1])
        print(initObj)
    }
    
    func testIdentifier() throws {
        struct Identifier<Core>: Codable, Hashable, RawRepresentable {
            
            init?(rawValue: String) {
                self.value = rawValue
            }
            
            var rawValue: String {
                value
            }
            
            typealias RawValue = String
            
            var value: String
            
            init(_ value: String) {
                self.value = value
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                value = try container.decode(String.self)
            }
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(value)
            }
        }
        
        struct Person: Codable { let name: String }
        let thing: [Identifier<Person>: Person] = [
            Identifier<Person>("test"): Person(name: "Jonny Test")
        ]
        
        struct EncodeTest: Codable {
            @RawValueEncode
            var thing: [Identifier<Person>: Person]
            
            init(thing: [Identifier<Person>: Person]) {
                self.thing = thing
            }
        }
        
        let myObj = EncodeTest(thing: thing)
        let encoded = try! Firestore.Encoder().encode(myObj)
        print("Now encoding...")
        dump(encoded)
        print(encoded)
    }

}
