#if os(Linux)

    //TODO: Find the UUID implementation in Foundation on Linux. In the meanwhile, we need an UUID for the test

    public struct UUID {
        public var uuidString: String {
            return "42c6cddd-9e0c-4b7f-9ca1-bc908a3eccd9"
        }

        public var hashValue: Int {
            return uuidString.hashValue
        }
    }

#endif
