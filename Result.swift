
public enum Result<Value> {
    case success(Value)
    case failure(Error)

    public func dematerialize() throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }

    public func doBlock(_ success: (Value) -> Void, failure: (Error) -> Void) {
        switch self {
        case .success(let v):
            success(v)
        case .failure(let e):
            failure(e)
        }
    }

    func map<T>(_ f: @escaping (Value) -> T) -> Result<T> {
        switch self {
        case .success(let value):
            return .success(f(value))
        case .failure(let err):
            return .failure(err)
        }
    }

    func flatMap<T>(_ f: @escaping (Value) -> Result<T>) -> Result<T> {
        switch self {
        case .success(let value):
            return f(value)
        case .failure(let err):
            return .failure(err)
        }
    }

    public var objc: ObjcResult {
        switch self {
        case .success(let v):
            return ObjcResult(result: .success(v))
        case .failure(let e):
            return ObjcResult(result: .failure(e))
        }
    }
}

@objc public class ObjcResult: NSObject {

    private let result: Result<Any>
    public var value: Any?
    public var failure: Any?
    
    public init(result: Result<Any>) {
        self.result = result
    }

    public init(value: Any) {
        self.result = .success(value)
    }

    public init(error: Error) {
        self.result = .failure(error)
    }

    public func success(_ success: (Any) -> Void, failure: (Error) -> Void) {
        result.doBlock(success, failure: failure)
    }

    func map(_ f: @escaping (Any) -> Any) -> ObjcResult {
        return result.map(f).objc
    }

    func flatMap(_ f: @escaping (Any) -> ObjcResult) -> ObjcResult {
        switch result {
        case .success(let value):
            return f(value)
        case .failure(let err):
            return ObjcResult(error: err)
        }
    }
}
