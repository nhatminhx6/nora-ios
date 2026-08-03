import Foundation

enum AppConfiguration {
    static var apiBaseURL: URL {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "NORA_API_BASE_URL") as? String,
              let url = URL(string: value) else {
            preconditionFailure("NORA_API_BASE_URL is missing or invalid")
        }
        return url
    }
}

struct APIEnvelope<Value: Decodable>: Decodable {
    let success: Bool
    let data: Value?
    let message: String
}

private struct APIErrorEnvelope: Decodable {
    let message: String
}

enum APIClientError: LocalizedError {
    case invalidResponse
    case unauthorized
    case server(String)
    case connection

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Nora received an unexpected response. Please try again."
        case .unauthorized:
            "Your session has expired. Please sign in again."
        case .server(let message):
            message
        case .connection:
            "Couldn't connect to Nora. Check your connection and try again."
        }
    }
}

struct EmptyResponse: Decodable {}

struct APIClient: Sendable {
    let baseURL: URL
    private let session: URLSession
    private let tokenStore: AuthTokenStore

    init(
        baseURL: URL = AppConfiguration.apiBaseURL,
        session: URLSession? = nil,
        tokenStore: AuthTokenStore = AuthTokenStore()
    ) {
        self.baseURL = baseURL
        self.session = session ?? Self.makeSession()
        self.tokenStore = tokenStore
    }

    func send<Response: Decodable, Body: Encodable>(
        _ path: String,
        method: String = "GET",
        body: Body? = Optional<String>.none,
        authenticated: Bool = true,
        timeoutInterval: TimeInterval = 10
    ) async throws -> Response {
        let components = path.split(separator: "?", maxSplits: 1).map(String.init)
        var url = baseURL.appending(path: components[0])
        if components.count == 2, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            urlComponents.percentEncodedQuery = components[1]
            if let resolved = urlComponents.url { url = resolved }
        }
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            var queryItems = urlComponents.queryItems ?? []
            if !queryItems.contains(where: { $0.name == "locale" }) {
                queryItems.append(URLQueryItem(name: "locale", value: AppLanguagePreference.apiCode))
            }
            urlComponents.queryItems = queryItems
            if let resolved = urlComponents.url { url = resolved }
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try makeEncoder().encode(body)
        }
        if authenticated {
            guard let token = tokenStore.load()?.accessToken else { throw APIClientError.unauthorized }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        logCurl(request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIClientError.connection
        }
        guard let http = response as? HTTPURLResponse else { throw APIClientError.invalidResponse }
        if http.statusCode == 401 { throw APIClientError.unauthorized }
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? makeDecoder().decode(APIErrorEnvelope.self, from: data).message)
            throw APIClientError.server(message ?? HTTPURLResponse.localizedString(forStatusCode: http.statusCode))
        }
        if http.statusCode == 204, Response.self == EmptyResponse.self {
            return EmptyResponse() as! Response
        }
        guard let value = try makeDecoder().decode(APIEnvelope<Response>.self, from: data).data else {
            throw APIClientError.invalidResponse
        }
        return value
    }

    func send<Response: Decodable>(
        _ path: String,
        method: String = "GET",
        authenticated: Bool = true
    ) async throws -> Response {
        try await send(path, method: method, body: Optional<String>.none, authenticated: authenticated)
    }

    private func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = false
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 15
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let value = try decoder.singleValueContainer().decode(String.self)
            let fractional = ISO8601DateFormatter()
            fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = fractional.date(from: value) { return date }
            let standard = ISO8601DateFormatter()
            guard let date = standard.date(from: value) else {
                throw DecodingError.dataCorruptedError(in: try decoder.singleValueContainer(), debugDescription: "Invalid ISO-8601 date")
            }
            return date
        }
        return decoder
    }

    private func logCurl(_ request: URLRequest) {
        #if DEBUG
        guard let url = request.url?.absoluteString else { return }
        var components = ["curl"]

        if let method = request.httpMethod, method != "GET" {
            components.append("-X \(shellQuote(method))")
        }

        for (key, value) in (request.allHTTPHeaderFields ?? [:]).sorted(by: { $0.key < $1.key }) {
            components.append("-H \(shellQuote("\(key): \(value)"))")
        }

        if let body = request.httpBody, !body.isEmpty {
            let bodyString = String(data: body, encoding: .utf8) ?? body.base64EncodedString()
            components.append("--data-raw \(shellQuote(bodyString))")
        }

        components.append(shellQuote(url))
        print("\n[Nora API cURL]\n\(components.joined(separator: " \\\n  "))\n")
        #endif
    }

    private func shellQuote(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\"'\"'"))'"
    }
}
