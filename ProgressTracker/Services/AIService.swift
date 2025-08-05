import Foundation
import UIKit

class AIService {
    static let shared = AIService()
    
    private let apiKey = "YOUR_GEMINI_API_KEY_HERE" // Replace with your actual API key
    private let apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"
    
    private init() {}
    
    func analyzeFoodMenu(image: UIImage, completion: @escaping (Result<[Dish], Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(AIServiceError.imageProcessingFailed))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        let userLanguage = DataManager.shared.userSettings.language
        
        let requestBody = createRequestBody(base64Image: base64Image, language: userLanguage)
        
        guard let url = URL(string: "\(apiURL)?key=\(apiKey)") else {
            completion(.failure(AIServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(AIServiceError.requestCreationFailed))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(AIServiceError.noDataReceived))
                }
                return
            }
            
            do {
                let aiResponse = try JSONDecoder().decode(AIResponse.self, from: data)
                guard let firstCandidate = aiResponse.candidates.first,
                      let responseText = firstCandidate.content.parts.first?.text else {
                    DispatchQueue.main.async {
                        completion(.failure(AIServiceError.invalidResponse))
                    }
                    return
                }
                
                let dishes = try self.parseDishesFromJSON(responseText)
                DispatchQueue.main.async {
                    completion(.success(dishes))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func createRequestBody(base64Image: String, language: String) -> [String: Any] {
        let prompt = """
        Analyze this restaurant menu. For each dish, provide its original name, a translation into \(language), estimated calories, estimated macronutrients (protein, carbs, fat), and identify if it is Keto, Vegan, or Gluten-Free. If information is not available or cannot be confidently determined, state "N/A". Provide the output as a JSON array of dish objects.
        """
        
        return [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "response_mime_type": "application/json",
                "response_schema": [
                    "type": "ARRAY",
                    "items": [
                        "type": "OBJECT",
                        "properties": [
                            "originalName": ["type": "STRING"],
                            "translatedName": ["type": "STRING"],
                            "calories": ["type": "STRING"],
                            "protein": ["type": "STRING"],
                            "carbs": ["type": "STRING"],
                            "fat": ["type": "STRING"],
                            "dietaryTags": [
                                "type": "ARRAY",
                                "items": ["type": "STRING"]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }
    
    private func parseDishesFromJSON(_ jsonString: String) throws -> [Dish] {
        guard let data = jsonString.data(using: .utf8) else {
            throw AIServiceError.jsonParsingFailed
        }
        
        return try JSONDecoder().decode([Dish].self, from: data)
    }
}

enum AIServiceError: LocalizedError {
    case imageProcessingFailed
    case invalidURL
    case requestCreationFailed
    case noDataReceived
    case invalidResponse
    case jsonParsingFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .invalidURL:
            return "Invalid API URL"
        case .requestCreationFailed:
            return "Failed to create API request"
        case .noDataReceived:
            return "No data received from API"
        case .invalidResponse:
            return "Invalid response from API"
        case .jsonParsingFailed:
            return "Failed to parse response data"
        }
    }
}