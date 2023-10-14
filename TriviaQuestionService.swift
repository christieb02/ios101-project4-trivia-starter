//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Christie beaubrun on 10/13/23.
//

import Foundation

class TriviaQuestionService {
    
    // Constants
    private let triviaURLString = "https://opentdb.com/api.php?amount=10"
    
    // Fetch Trivia Questions
    func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        
        guard let url = URL(string: triviaURLString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // Handle errors in the network call
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Ensure we got data back
            guard let data = data else {
                completion(nil, NSError(domain: "No data received", code: 1, userInfo: nil))
                return
            }
            
            // Decode the data into our TriviaResponse object
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TriviaResponse.self, from: data)
                completion(response.results, nil)
            } catch let decodeError {
                completion(nil, decodeError)
            }
        }
        
        task.resume()
    }
}

