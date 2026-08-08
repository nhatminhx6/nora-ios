import Foundation

/// Produces the daily brief shown on the Today screen.
protocol BriefService: Sendable {
    func fetchBrief(for date: Date, category: String, page: Int) async throws -> Brief
    func submitReflection(question: String, answer: String) async throws
}

enum BriefServiceError: Error {
    case refreshFailed
}

struct LiveBriefService: BriefService {
    private let client: APIClient

    init(client: APIClient = APIClient()) { self.client = client }

    func fetchBrief(for date: Date, category: String, page: Int) async throws -> Brief {
        let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "all"
        let response: DailyBriefResponse = try await client.send(
            "feed?category=\(encodedCategory)&page=\(page)"
        )
        return response.brief ?? Brief(date: date, headline: "")
    }

    func submitReflection(question: String, answer: String) async throws {
        throw APIClientError.server("Reflection feedback is not available yet.")
    }
}

private struct DailyBriefResponse: Decodable {
    let brief: Brief?
}

actor MockBriefService: BriefService {
    private var brief: Brief
    /// Toggle to preview the error state without changing call sites.
    var shouldFail = false

    init(seed: Brief = PreviewData.todayBrief) {
        self.brief = seed
    }

    func fetchBrief(for date: Date, category: String, page: Int) async throws -> Brief {
        try await Task.sleep(for: .milliseconds(400))
        if shouldFail {
            throw BriefServiceError.refreshFailed
        }
        return brief
    }

    func submitReflection(question: String, answer: String) async throws {
        try await Task.sleep(for: .milliseconds(150))
    }
}
