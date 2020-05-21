# Firestore Encoding

The default Firestore encoder does not encode dictionaries correctly when the key is a strongly-typed, raw-representable, encodable value.

For example, the current behaviour is:
```swift
enum StrongKey: Int, Codable {
  case one, two, three
}

struct Model: Codable {
  var obj: [StrongKey: Int] = [.one: 1, .two: 2, .three: 3]
}

let encoded = try! Firestore.Encoder().encode(Model())
// encoded:
//   - obj (ARRAY):
//      -> "one"
//      -> 1
//      -> "two"
//      -> 2
//      -> "three"
//      -> 3
```

Clearly this makes **no** sense (how does a Dictionary even become an Array?!). 
This is an experiment to create an `@propertyWrapper` to fix this behaviour, correctly encoding this to a dictionary.
```swift
struct FixedModel: Codable {
  @RawTypeEncoding
  var obj: [StrongKey: Int] = [.one: 1, .two: 2, .three: 3]
}

let encoded = try! Firestore.Encoder().encode(Model())
// encoded:
//   - obj (DICTIONARY):
//      -> K:"one", V:1
//      -> K:"two", V:2
//      -> K:"three", V:3
```

I'm not aware if this currently happens with other data types as well, but they can easily be fixed by adding a conformance for them in the core model.
