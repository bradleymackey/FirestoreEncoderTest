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
