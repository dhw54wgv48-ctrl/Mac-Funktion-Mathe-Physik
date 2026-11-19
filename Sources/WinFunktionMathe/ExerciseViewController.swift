import AppKit

/// Übungsmodus: zufällige Aufgaben zum ausgewählten Lerngebiet mit Antwortprüfung.
final class ExerciseViewController: NSViewController {

    private var topicId = 0
    private var currentExercise: Exercise?
    private var score = 0
    private var solved = 0

    private var topicLabel: NSPopUpButton!
    private var questionLabel: NSTextField!
    private var answerField: NSTextField!
    private var feedbackLabel: NSTextField!
    private var scoreLabel: NSTextField!

    override func loadView() {
        let wrapper = NSView(frame: NSRect(x: 0, y: 0, width: 660, height: 500))
        wrapper.wantsLayer = true

        let title = NSTextField(labelWithString: "🎓  Übungen")
        title.font = NSFont.boldSystemFont(ofSize: 24)
        title.translatesAutoresizingMaskIntoConstraints = false

        let topicField = NSTextField(labelWithString: "Lerngebiet:")
        topicField.font = NSFont.systemFont(ofSize: 14)
        topicField.translatesAutoresizingMaskIntoConstraints = false

        let popup = NSPopUpButton()
        popup.translatesAutoresizingMaskIntoConstraints = false
        for topic in ContentStore.topics {
            popup.addItem(withTitle: topic.title)
        }
        popup.target = self
        popup.action = #selector(topicChanged)
        topicLabel = popup

        let question = NSTextField(wrappingLabelWithString: "")
        question.font = NSFont.systemFont(ofSize: 17)
        question.translatesAutoresizingMaskIntoConstraints = false
        questionLabel = question

        let answer = NSTextField()
        answer.placeholderString = "Deine Antwort …"
        answer.font = NSFont.systemFont(ofSize: 16)
        answer.translatesAutoresizingMaskIntoConstraints = false
        answerField = answer

        let checkButton = NSButton(title: "Antwort prüfen", target: self, action: #selector(checkAnswer))
        checkButton.bezelStyle = .rounded
        checkButton.translatesAutoresizingMaskIntoConstraints = false

        let hintButton = NSButton(title: "Tipp anzeigen", target: self, action: #selector(showHint))
        hintButton.bezelStyle = .rounded
        hintButton.translatesAutoresizingMaskIntoConstraints = false

        let nextButton = NSButton(title: "Nächste Aufgabe", target: self, action: #selector(nextExercise))
        nextButton.bezelStyle = .rounded
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        let feedback = NSTextField(labelWithString: "")
        feedback.font = NSFont.systemFont(ofSize: 15)
        feedback.translatesAutoresizingMaskIntoConstraints = false
        feedbackLabel = feedback

        let score = NSTextField(labelWithString: "Punkte: 0/0")
        score.font = NSFont.systemFont(ofSize: 13)
        score.textColor = NSColor.secondaryLabelColor
        score.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel = score

        wrapper.addSubview(title)
        wrapper.addSubview(topicField)
        wrapper.addSubview(popup)
        wrapper.addSubview(question)
        wrapper.addSubview(answer)
        wrapper.addSubview(checkButton)
        wrapper.addSubview(hintButton)
        wrapper.addSubview(nextButton)
        wrapper.addSubview(feedback)
        wrapper.addSubview(score)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 24),
            title.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            topicField.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            topicField.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            popup.leadingAnchor.constraint(equalTo: topicField.trailingAnchor, constant: 8),
            popup.centerYAnchor.constraint(equalTo: topicField.centerYAnchor),
            question.topAnchor.constraint(equalTo: popup.bottomAnchor, constant: 24),
            question.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            question.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -32),
            answer.topAnchor.constraint(equalTo: question.bottomAnchor, constant: 14),
            answer.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            answer.widthAnchor.constraint(equalToConstant: 220),
            checkButton.topAnchor.constraint(equalTo: answer.bottomAnchor, constant: 16),
            checkButton.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            hintButton.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            hintButton.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 10),
            nextButton.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: hintButton.trailingAnchor, constant: 10),
            feedback.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 16),
            feedback.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            feedback.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -32),
            score.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -20),
            score.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32)
        ])

        view = wrapper
        nextExercise()
    }

    @objc private func topicChanged() {
        topicId = topicLabel.indexOfSelectedItem
        nextExercise()
    }

    private func newExercise() {
        currentExercise = ExerciseGenerator.make(topicId: topicId)
        questionLabel.stringValue = currentExercise?.question ?? ""
        answerField.stringValue = ""
        feedbackLabel.stringValue = ""
    }

    @objc private func nextExercise() {
        newExercise()
    }

    @objc private func showHint() {
        guard let exercise = currentExercise else { return }
        feedbackLabel.stringValue = "💡 \(exercise.hint)"
        feedbackLabel.textColor = NSColor.systemBlue
    }

    @objc private func checkAnswer() {
        guard let exercise = currentExercise else { return }
        solved += 1
        let raw = answerField.stringValue
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        guard let value = Double(raw) else {
            feedbackLabel.stringValue = "Bitte gib eine Zahl ein (Punkt oder Komma als Dezimaltrennzeichen)."
            feedbackLabel.textColor = NSColor.systemOrange
            return
        }
        if abs(value - exercise.answer) <= exercise.tolerance {
            score += 1
            feedbackLabel.stringValue = "✅ Richtig! Die Lösung ist \(NumberFormatting.german(exercise.answer))."
            feedbackLabel.textColor = NSColor.systemGreen
        } else {
            feedbackLabel.textColor = NSColor.systemRed
            feedbackLabel.stringValue = "❌ Leider falsch. Richtig wäre \(NumberFormatting.german(exercise.answer)). Tipp: \(exercise.hint)"
        }
        scoreLabel.stringValue = "Punkte: \(score)/\(solved)"
    }
}
