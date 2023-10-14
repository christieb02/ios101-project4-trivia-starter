//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

extension String {
    var htmlDecoded: String? {
        guard let data = self.data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        return attributedString?.string
    }
}


class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
  private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addGradient()
    questionContainerView.layer.cornerRadius = 8.0
      fetchTriviaQuestions()
  }

    private func fetchTriviaQuestions() {
        
        let triviaService = TriviaQuestionService()
        
        triviaService.fetchTriviaQuestions { [weak self] (questions, error) in
            
            guard let strongSelf = self else { return }
            
            // Handle errors
            if let error = error {
                print("Error fetching questions: \(error.localizedDescription)")
                return
            }
            
            guard let questions = questions else {
                print("No questions returned")
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.questions = questions
                strongSelf.updateQuestion(withQuestionIndex: strongSelf.currQuestionIndex)
            }
        }
    }

  
  private func updateQuestion(withQuestionIndex questionIndex: Int) {
      currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
          let question = questions[questionIndex]

          // Decode question
          questionLabel.text = question.question.htmlDecoded ?? question.question
          categoryLabel.text = question.category

          // Decode answers
          var decodedAnswers = [String]()
          if let decodedCorrectAnswer = question.correctAnswer.htmlDecoded {
              decodedAnswers.append(decodedCorrectAnswer)
          } else {
              // Fallback to raw correct answer if decoding fails
              decodedAnswers.append(question.correctAnswer)
          }

          for incorrectAnswer in question.incorrectAnswers {
              if let decodedIncorrectAnswer = incorrectAnswer.htmlDecoded {
                  decodedAnswers.append(decodedIncorrectAnswer)
              } else {
                  // Fallback to raw incorrect answer if decoding fails
                  decodedAnswers.append(incorrectAnswer)
              }
          }
          // Shuffle the answers
          let shuffledAnswers = decodedAnswers.shuffled()
      
      let isBooleanQuestion = shuffledAnswers.count == 2

          if isBooleanQuestion {  // If it's a true or false question
              answerButton0.setTitle(shuffledAnswers[0], for: .normal)
              answerButton1.setTitle(shuffledAnswers[1], for: .normal)
              
              answerButton0.isHidden = false
              answerButton1.isHidden = false
              answerButton2.isHidden = true
              answerButton3.isHidden = true
          } else {  // If it's a multiple choice question
              if shuffledAnswers.count > 0 {
                  answerButton0.setTitle(shuffledAnswers[0], for: .normal)
                  answerButton0.isHidden = false
              }
              if shuffledAnswers.count > 1 {
                  answerButton1.setTitle(shuffledAnswers[1], for: .normal)
                  answerButton1.isHidden = false
              }
              if shuffledAnswers.count > 2 {
                  answerButton2.setTitle(shuffledAnswers[2], for: .normal)
                  answerButton2.isHidden = false
              }
              if shuffledAnswers.count > 3 {
                  answerButton3.setTitle(shuffledAnswers[3], for: .normal)
                  answerButton3.isHidden = false
              }
          }
  }
  
  private func updateToNextQuestion(answer: String) {
    if isCorrectAnswer(answer) {
      numCorrectQuestions += 1
    }
    currQuestionIndex += 1
    guard currQuestionIndex < questions.count else {
      showFinalScore()
      return
    }
    updateQuestion(withQuestionIndex: currQuestionIndex)
  }
  
  private func isCorrectAnswer(_ answer: String) -> Bool {
      if currQuestionIndex < questions.count {
              return answer == questions[currQuestionIndex].correctAnswer
          }
          return false
  }
  
  private func showFinalScore() {
    let alertController = UIAlertController(title: "Game over!",
                                            message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                            preferredStyle: .alert)
    let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
      currQuestionIndex = 0
      numCorrectQuestions = 0
      updateQuestion(withQuestionIndex: currQuestionIndex)
    }
    alertController.addAction(resetAction)
    present(alertController, animated: true, completion: nil)
  }
  
  private func addGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                            UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  @IBAction func didTapAnswerButton0(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton1(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton2(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton3(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
}

