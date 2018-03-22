//
//  ViewController.swift
//  WorksHack
//
//  Created by Matej Svrznjak on 18/03/2018.
//  Copyright © 2018 Matej Svrznjak s.p. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var textfield: UITextField!
    @IBOutlet var textview: UITextView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var wordsArray = [String]()

    fileprivate let serialQueue = DispatchQueue(label: "IXSerialQueue", attributes: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        self.textfield.alpha = 0
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()

        self.serialQueue.async {
            if let rtfPath = Bundle.main.url(forResource: "SlovenianWords", withExtension: "rtf") {
                do {
                    let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)

                    let separateIntoLines = attributedStringWithRtf.string.components(separatedBy: .newlines)
                    for line in separateIntoLines {
                        if line.count > 2 && line.count < 9 {
                            if line.contains("w") && line.contains("y") && line.contains("q") {
                                continue
                            }
                            self.wordsArray.append(line)
                        }
                    }

                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        self.activityIndicator.stopAnimating()

                        UIView.animate(withDuration: 0.3, animations: {
                            self.textfield.alpha = 1
                        })
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        self.activityIndicator.stopAnimating()
                        UIView.animate(withDuration: 0.3, animations: {
                            self.textfield.alpha = 1
                        })
                    }
                }
            }
        }
    }

    func searchTapped() {
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        self.textfield.resignFirstResponder
        let string = self.textfield.text?.lowercased() ?? ""
        let characters = Array(string)
        self.textview.text = ""

        self.serialQueue.async {
            var hits: [[String]] = []
            for _ in 0..<9 {
                hits.append([])
            }

            for word in self.wordsArray {
                if word.count < 3 || word.count > 8 || word.count > string.count  { continue }
                var wordCOunter = 0
                for char in characters {
                    if word.contains(char) {
                        wordCOunter += 1
                    }
                }

                if wordCOunter == word.count {
                    hits[word.count].append(word)
                }
            }

            var newText = ""
            var firstLine = true
            for var hitarray in hits {
                if hitarray.count < 1 { continue }
                hitarray.sort { (first, second) -> Bool in
                    return first < second
                }

                var firstWord = true

                if let first = hitarray.first {
                    if firstLine {
                        newText += "\(first.count): \n"
                        firstLine = false
                    } else {
                        newText += "\n\n\(first.count): \n"
                    }
                }

                for hit in hitarray {
                    if !firstWord {
                        newText += hit.count % 2 == 0 ? "🔸" : "🔹"
                    }
                    newText += hit.uppercased()
                    firstWord = false
                }
            }

            DispatchQueue.main.async {
                self.textview.text = newText
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }

        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTapped()
        textField.resignFirstResponder()
        return true
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
