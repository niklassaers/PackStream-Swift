PackStream implementation in Swift

PackStream is a binary message format very similar to [MessagePack](http://msgpack.org). It can be used stand-alone, but it has been built as a message format for use in the Bolt protocol to communicate between the Neo4j server and its clients.

This implementation is written in Swift, primarily as a dependency for the Swift Bolt implementation. That implementation will in turn provide Theo, the Neo4j Swift driver, with Bolt support.

To use with Xcode, type "swift package generate-xcodeproj"

CocoaPods

Carthage

