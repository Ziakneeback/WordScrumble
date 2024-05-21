//
//  ContentView.swift
//  WordScrunble
//
//  Created by Жанибек Асылбек on 29.10.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String] ()
    @State private var newWord = ""
    @State private var rootWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    Text("^[\(usedWords.count) word](inflect: true)")
                }
                Section{
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar{
                Button("New Game", action: startGame)
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingAlert){
                Button("OK") {}
            }message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else{
            wordError(title: "Word used already", message: "Be more original")
             return
         }

         guard isPossible(word: answer) else {
             wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
             return
         }

         guard isReal(word: answer) else {
             wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
             return
         }
        
        guard isTooShort(word: answer) else {
            wordError(title: "Word is too short", message: "Try something longer, dude!")
            return
        }
        
        guard isTheSame(word: answer) else{
            wordError(title: "Are you serious?", message: "It's the same word as rootWord, bro!")
            return
        }
        withAnimation{
            usedWords.insert(newWord, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        usedWords.removeAll()
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.text from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isTooShort(word: String) -> Bool {
        word.count >= 3
    }
    
    func isTheSame(word: String) -> Bool{
        word != rootWord
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingAlert = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
