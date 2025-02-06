//
//  Responses.swift
//  UMobile
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Foundation

struct UmobileResponse {
    struct News: Codable {
        let count: Int
        let next: String
        let results: [Result]
        
        enum CodingKeys: String, CodingKey {
            case count
            case next
            case results
        }
        
        struct Result: Codable {
            let id: Int
            let title: String
            let url: String
            let imageURL: String
            let newsSite, summary: String
            let publishedAt: Date
            let updatedAt: String
            let featured: Bool
            let launches: [Launch]
            let events: [Event]

            enum CodingKeys: String, CodingKey {
                case id, title, url
                case imageURL = "image_url"
                case newsSite = "news_site"
                case summary
                case publishedAt = "published_at"
                case updatedAt = "updated_at"
                case featured, launches, events
            }
        }

        struct Event: Codable {
            let eventID: Int
            let provider: String

            enum CodingKeys: String, CodingKey {
                case eventID = "event_id"
                case provider
            }
        }

        struct Launch: Codable {
            let launchID, provider: String

            enum CodingKeys: String, CodingKey {
                case launchID = "launch_id"
                case provider
            }
        }
    }
}
