//
//  RawTypeEncoding.swift
//  FirestoreEncoderTest
//
//  Created by Bradley Mackey on 21/05/2020.
//  Copyright © 2020 Bradley Mackey. All rights reserved.
//

public protocol RawTypeEncodingWrappable {
    associatedtype Key where Key: Hashable, Key: RawRepresentable, Key.RawValue: Hashable
    associatedtype EncodedPayload
    /// create an empty, unpopulated instance of the type
    init()
    /// convert weakly typed into a strong typed dict
    init(keyedBy key: Key.Type, from value: EncodedPayload)
    /// get the raw encoded value from this instance
    func rawEncoded() -> EncodedPayload
}

/// a dictionary type that will transform the key to the `Key.RawValue` when encoding
///
/// what is the point of this?
/// Cloud Firestore messes up it's encoding if a dictionary with a strongly typed key (such as if a `Codable`
/// `enum` is used)
/// this will transform the key of the dictionary to it's `RawValue` when encoding, which bypasses the
/// problem
@propertyWrapper
public struct RawTypeEncoding<Wrapped> where Wrapped: RawTypeEncodingWrappable {
    
    var value: Wrapped
    
    public init(wrappedValue value: Wrapped = .init()) {
        self.value = value
    }
    
    // TODO: add modify accessor (Swift 6?)
    public var wrappedValue: Wrapped {
        get { value }
        set { value = newValue }
    }
    
}

// MARK: - Equatable, Comparable, Hashable

extension RawTypeEncoding: Equatable where Wrapped: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }

}

extension RawTypeEncoding: Comparable where Wrapped: Comparable {
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
    
}

extension RawTypeEncoding: Hashable where Wrapped: Hashable {
        
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
}

// MARK: - Codable

extension RawTypeEncoding: Codable where Wrapped.Key.RawValue: Codable, Wrapped.EncodedPayload: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringlyTyped = try container.decode(Wrapped.EncodedPayload.self)
        value = Wrapped.init(keyedBy: Wrapped.Key.self, from: stringlyTyped)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let rawKeyedValue = value.rawEncoded()
        try container.encode(rawKeyedValue)
    }
    
}

// MARK: - Conforming Types

extension Dictionary: RawTypeEncodingWrappable
where
    Key: RawRepresentable,
    Key.RawValue: Hashable
{
    
    public typealias Key = Key
    public typealias EncodedPayload = [Key.RawValue: Value]
    
    public init() {
        self = [:]
    }
    
    public init(keyedBy key: Key.Type, from value: [Key.RawValue: Value]) {
        self = Dictionary(
            uniqueKeysWithValues: value.compactMap { key, val in
                guard let newKey = Key.init(rawValue: key) else { return nil }
                return (newKey, val)
            }
        )
    }
    
    public func rawEncoded() -> [Key.RawValue: Value] {
        [Key.RawValue: Value](uniqueKeysWithValues: map { ($0.rawValue, $1) })
    }
    
}

extension Optional: RawTypeEncodingWrappable where Wrapped: RawTypeEncodingWrappable {
    
    public typealias Key = Wrapped.Key
    public typealias EncodedPayload = Wrapped.EncodedPayload?
    
    public init() {
        // creating with nothing means we should use a nil default value
        self = nil
    }
    
    public init(keyedBy key: Wrapped.Key.Type, from value: Wrapped.EncodedPayload?) {
        if let value = value {
            // delegate the keying to the wrapped type
            self = Wrapped.init(keyedBy: Wrapped.Key.self, from: value)
        } else {
            self = nil
        }
    }
    
    public func rawEncoded() -> Wrapped.EncodedPayload? {
        // delegate the keying to the wrapped type
        self?.rawEncoded()
    }
    
}
