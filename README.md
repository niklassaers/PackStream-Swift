# PackStream implementation in Swift

PackStream is a binary message format very similar to [MessagePack](http://msgpack.org). It can be used stand-alone, but it has been built as a message format for use in the Bolt protocol to communicate between the Neo4j server and its clients.

This implementation is written in Swift, primarily as a dependency for the Swift Bolt implementation. That implementation will in turn provide [Theo](https://github.com/graphstory/neo4j-ios), the [Neo4j](https://neo4j.com) Swift driver, with Bolt support.

## Usage
Through PackStream you can encode Bool, Int, Float (Double in Swift lingo), String, List, Map and Structure. They all implement the `PackProtocol`, so if you want to have a collection of packable items, you can specify them as implementing PackProtocol. 

### Example

```swift
let map = Map(dictionary: [
    "alpha": 42,
    "beta": 39.3,
    "gamma": "☺",
    "delta": List(items: [1,2,3,4])
    ])
let result = try map.pack()
let restored = try Map.unpack(result[0..<result.count])
```

## Getting started

To use directly with Xcode, type "swift package generate-xcodeproj"


### Swift Package Manager
Add the following to your dependencies array in Package.swift:
```swift
.Package(url: "https://github.com/niklassaers/PackStream-swift.git",
 majorVersion: 0),
```
and you can now do a
```bash
swift build
```

### CocoaPods
Add the 
```ruby
pod "PackStream"
```
to your Podfile, and you can now do
```bash
pod install
```
to have PackStream included in your Xcode project via CocoaPods

### Carthage
Put 
```ogdl
github "niklassaers/PackStream-swift"
```
in your Cartfile. If this is your entire Cartfile, do
```bash
carthage bootstrap
```
If you have already done that, do
```bash
carthage update
```
instead.

Then do 
```bash
cd Carthage/Checkouts/PackStream-swift
swift package generate-xcodeproj
cd -
```

And Carthage is now set up. You can now do
```bash
carthage build
```
and you should find a build for macOS, iOS, tvOS and watchOS in Carthage/Build