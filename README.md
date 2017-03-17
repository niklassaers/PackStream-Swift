PackStream implementation in Swift

PackStream is a binary message format very similar to [MessagePack](http://msgpack.org). It can be used stand-alone, but it has been built as a message format for use in the Bolt protocol to communicate between the Neo4j server and its clients.

This implementation is written in Swift, primarily as a dependency for the Swift Bolt implementation. That implementation will in turn provide [Theo](https://github.com/graphstory/neo4j-ios), the [Neo4j](https://neo4j.com) Swift driver, with Bolt support.

To use with Xcode, type "swift package generate-xcodeproj"

Swift Package Manager
Add the following to your dependencies array in Package.swift:
.Package(url: "https://github.com/niklassaers/PackStream-swift.git",
                         majorVersion: 0),
and you can now do a
swift build

CocoaPods
Add the 
pod "PackStream"
to your Podfile, and you can now do
pod install
to have PackStream included in your Xcode project via CocoaPods

Carthage
Put 
github "niklassaers/PackStream-swift"
in your Cartfile
If this is your entire Cartfile, do
carthage bootstrap
If you have already done that, do
carthage update
instead.

Then do 
cd Carthage/Checkouts/PackStream-swift
swift package generate-xcodeproj
cd -

And Carthage is now set up. You can now do
carthage build
and you should find a build for macOS, iOS, tvOS and watchOS in Carthage/Build