# Firestore Encoding

The default Firestore encoder does not encode dictionaries correctly when the key is a strongly-typed, raw-representable, encodable value.
This is an experiment to create an `@propertyWrapper` to fix this behaviour.
