import Foundation

/// Realistic sample data for one persona — an iOS developer tracking a bank
/// stock, a football club, sci-fi releases, a trip, and a car purchase.
/// Used by mock services (so the app runs fully without a backend) and by
/// every SwiftUI `#Preview`.
enum PreviewData {

    // MARK: Profile

    static let profile = UserProfile(
        displayName: "Minh",
        profession: "iOS Developer",
        interests: ["SwiftUI", "Liverpool FC", "Sci-fi movies"],
        goals: ["Trip to Japan in the fall", "Buy a new car in the next 6 months"],
        locations: ["Ho Chi Minh City"],
        notificationPreference: .balanced,
        dailyBriefTime: DateComponents(hour: 8, minute: 0)
    )

    // MARK: Topics

    static let topicOCB = Topic(
        name: "OCB",
        category: .investments,
        relationship: .holding,
        priority: .high,
        trackingRules: ["Earnings results", "Leadership changes", "Dividends", "Regulatory news"],
        notificationMode: .immediate,
        relevanceReason: "You hold OCB as a mid-term position, so Nora prioritizes earnings, leadership changes, dividends, and regulatory news."
    )

    static let topicLiverpool = Topic(
        name: "Liverpool FC",
        category: .sports,
        relationship: .favorite,
        priority: .standard,
        trackingRules: ["Match schedule", "Results", "Transfer news"],
        notificationMode: .dailyBrief,
        relevanceReason: "Liverpool is your favorite club, so Nora rolls match schedules and results into your daily brief."
    )

    static let topicSwiftUI = Topic(
        name: "SwiftUI",
        category: .work,
        relationship: .learning,
        priority: .standard,
        trackingRules: ["New APIs", "WWDC sessions", "Breaking changes"],
        notificationMode: .dailyBrief,
        relevanceReason: "You work as an iOS Developer and follow SwiftUI, so Nora prioritizes new APIs and changes that could affect your work."
    )

    static let topicJapan = Topic(
        name: "Japan trip",
        category: .travel,
        relationship: .planning,
        priority: .standard,
        trackingRules: ["JPY exchange rate", "Weather", "Flight prices"],
        notificationMode: .dailyBrief,
        relevanceReason: "You're planning a trip to Japan, so Nora tracks the exchange rate, weather, and flight prices."
    )

    static let topicMazda = Topic(
        name: "Mazda CX-5",
        category: .purchases,
        relationship: .considering,
        priority: .standard,
        trackingRules: ["Price changes", "Promotions", "New model year", "Ownership costs"],
        notificationMode: .dailyBrief,
        relevanceReason: "You're considering a Mazda CX-5 in the next 6 months, so Nora tracks pricing, promotions, and new model years."
    )

    static let topicSciFi = Topic(
        name: "Sci-fi movies",
        category: .entertainment,
        relationship: .favorite,
        priority: .low,
        trackingRules: ["New releases", "Trailers"],
        notificationMode: .dailyBrief,
        relevanceReason: "You love sci-fi films, so Nora rolls new releases into your brief."
    )

    static let allTopics: [Topic] = [
        topicOCB, topicLiverpool, topicSwiftUI, topicJapan, topicMazda, topicSciFi,
    ]

    // MARK: Insights

    static let insightOCBEarnings = Insight(
        topicId: topicOCB.id,
        topicName: "OCB",
        category: .investments,
        type: .important,
        title: "OCB reports Q2 earnings",
        summary: "Pre-tax profit rose 18% year over year, beating analyst expectations. Non-performing loans dipped slightly.",
        relevanceReason: "You hold OCB — this directly affects your investment.",
        suggestedAction: "View full report",
        sourceCount: 4,
        publishedAt: .now.addingTimeInterval(-3600)
    )

    static let insightLiverpoolMatch = Insight(
        topicId: topicLiverpool.id,
        topicName: "Liverpool FC",
        category: .sports,
        type: .upcoming,
        title: "Liverpool face Chelsea tonight",
        summary: "Kickoff at Anfield, 23:30. Liverpool are unbeaten in their last 6 league games.",
        relevanceReason: "Liverpool is your favorite club.",
        sourceCount: 2,
        publishedAt: .now.addingTimeInterval(-7200),
        eventDate: .now.addingTimeInterval(6 * 3600)
    )

    static let insightSwiftUIAPI = Insight(
        topicId: topicSwiftUI.id,
        topicName: "SwiftUI",
        category: .work,
        type: .informational,
        title: "New API for custom container views in SwiftUI",
        summary: "Apple introduced an expanded `Layout` protocol for finer control over custom containers, useful for complex components.",
        relevanceReason: "You're an iOS Developer following SwiftUI to stay current at work.",
        sourceCount: 3,
        publishedAt: .now.addingTimeInterval(-86400)
    )

    static let insightJPYRate = Insight(
        topicId: topicJapan.id,
        topicName: "Japan trip",
        category: .travel,
        type: .informational,
        title: "JPY falls to a 3-month low",
        summary: "1 JPY now buys about 4% less VND than last month — a good moment to exchange money for your trip.",
        relevanceReason: "You're planning a trip to Japan, so exchange-rate moves affect your trip budget.",
        sourceCount: 2,
        publishedAt: .now.addingTimeInterval(-18000)
    )

    static let insightMazdaPromo = Insight(
        topicId: topicMazda.id,
        topicName: "Mazda CX-5",
        category: .purchases,
        type: .informational,
        title: "Mazda CX-5 registration-fee promotion",
        summary: "Dealers are covering 50% of the registration fee on 2.0L trims through the end of next month.",
        relevanceReason: "You're considering a Mazda CX-5 in the next 6 months.",
        suggestedAction: "Compare trims",
        sourceCount: 3,
        publishedAt: .now.addingTimeInterval(-43200)
    )

    static let insightSciFiRelease = Insight(
        topicId: topicSciFi.id,
        topicName: "Sci-fi movies",
        category: .entertainment,
        type: .upcoming,
        title: "New sci-fi trailer just dropped",
        summary: "The studio released the first trailer, with a release expected later this year.",
        relevanceReason: "You love the sci-fi genre.",
        sourceCount: 1,
        publishedAt: .now.addingTimeInterval(-100_000),
        eventDate: Calendar.current.date(byAdding: .month, value: 4, to: .now)
    )

    static let allInsights: [Insight] = [
        insightOCBEarnings, insightLiverpoolMatch, insightSwiftUIAPI,
        insightJPYRate, insightMazdaPromo, insightSciFiRelease,
    ]

    // MARK: Brief

    static let todayBrief = Brief(
        date: .now,
        headline: "3 things worth your attention today.",
        importantInsights: [insightOCBEarnings, insightLiverpoolMatch],
        otherInsights: [insightSwiftUIAPI, insightJPYRate, insightMazdaPromo],
        upcomingItems: [
            UpcomingItem(
                topicName: "Liverpool FC",
                category: .sports,
                title: "Liverpool vs Chelsea",
                date: .now.addingTimeInterval(6 * 3600)
            ),
            UpcomingItem(
                topicName: "Sci-fi movies",
                category: .entertainment,
                title: "New movie premiere",
                date: Calendar.current.date(byAdding: .month, value: 4, to: .now) ?? .now
            ),
        ]
    )

    static let emptyBrief = Brief(
        date: .now,
        headline: "Nothing needs you right now."
    )

    // MARK: Conversation

    static let conversation: [ConversationMessage] = [
        ConversationMessage(
            role: .user,
            content: "I'm considering buying a Mazda CX-5 in the next six months.",
            createdAt: .now.addingTimeInterval(-300)
        ),
        ConversationMessage(
            role: .assistant,
            content: "Got it — I've noted your purchase intent.",
            createdAt: .now.addingTimeInterval(-280),
            suggestedReplies: ["2.0L Premium", "2.5L AWD", "Not sure yet"],
            extractedContext: ExtractedContext(
                summaryLines: [
                    "Mazda CX-5",
                    "Planning to buy within 6 months",
                    "Tracking price, promotions, new trims, and ownership costs",
                ],
                followUpQuestion: "Which trim are you interested in?",
                quickReplies: ["2.0L Premium", "2.5L AWD", "Not sure yet"]
            )
        ),
    ]
}
