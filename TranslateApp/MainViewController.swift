//
//  ViewController.swift
//  TranslateApp
//
//  Created by Anna Melekhina on 30.03.2025.
//

import UIKit

final class MainViewController: UIViewController {
    private let networkService: NetworkServiceProtocol = NetworkService()
    
    private lazy var sourceLanguageButton: UIButton = makeLanguageButton()
    private lazy var targetLanguageButton: UIButton = makeLanguageButton()
    
    private lazy var sourceTextField: UITextField = {
        let textField = makeTextField(includeClearButton: true)
        textField.placeholder = "Введите текст для перевода"
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var translationTextField: UITextField = {
        let textField = makeTextField(includeCopyButton: true)
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    private weak var currentLanguageButton: UIButton?

    private lazy var languagePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.isHidden = true
        picker.backgroundColor = .white
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private lazy var swapButton = makeButton(systemName: "arrow.2.squarepath")
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var sourceLanguage: String = "en"
    private var targetLanguage: String = "ru"
    private var sourceText: String = ""
    private var translatedText: String = ""
    private var translateWorkItem: DispatchWorkItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
        setupActions()
        setupInitialState()
        
        languagePicker.delegate = self
        languagePicker.dataSource = self
    }
}


private extension MainViewController {
    func makeTextField(includeClearButton: Bool = false, includeCopyButton: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        if includeClearButton {
                let clearButton = UIButton(type: .custom)
                clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                clearButton.tintColor = .gray
                clearButton.addTarget(self, action: #selector(clearSourceText), for: .touchUpInside)
                clearButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                textField.rightView = clearButton
                textField.rightViewMode = .whileEditing
            textField.rightViewMode = .always
            }
        
        return textField
    }
    
    func makeButton(systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: systemName)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 22
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func makeLanguageButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func setupView() {
        view.backgroundColor = .white
        [sourceLanguageButton, sourceTextField,
         swapButton,
         targetLanguageButton, translationTextField, copyButton,
         activityIndicator, languagePicker].forEach(view.addSubview)
    }
    
    func setupInitialState() {
        sourceLanguageButton.setTitle(getLanguageName(for: sourceLanguage), for: .normal)
        targetLanguageButton.setTitle(getLanguageName(for:  targetLanguage), for: .normal)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            sourceLanguageButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            sourceLanguageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            sourceTextField.topAnchor.constraint(equalTo: sourceLanguageButton.bottomAnchor, constant: 8),
            sourceTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sourceTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sourceTextField.heightAnchor.constraint(equalToConstant: 100),
            
            swapButton.topAnchor.constraint(equalTo: sourceTextField.bottomAnchor, constant: 16),
            swapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            targetLanguageButton.topAnchor.constraint(equalTo: swapButton.bottomAnchor, constant: 16),
            targetLanguageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            translationTextField.topAnchor.constraint(equalTo: targetLanguageButton.bottomAnchor, constant: 8),
            translationTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            translationTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            translationTextField.heightAnchor.constraint(equalToConstant: 100),
            
            copyButton.trailingAnchor.constraint(equalTo: translationTextField.trailingAnchor, constant: -8),
            copyButton.centerYAnchor.constraint(equalTo: translationTextField.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 20),
            copyButton.heightAnchor.constraint(equalToConstant: 20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: translationTextField.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: translationTextField.centerYAnchor),
            
            languagePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            languagePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            languagePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            languagePicker.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    func setupActions() {
        sourceTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        swapButton.addTarget(self, action: #selector(swapButtonTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
    }
    
    @objc func textFieldDidChange() {
            sourceText = sourceTextField.text ?? ""
            translate()
        }
        
        @objc func swapButtonTapped() {
            (sourceLanguage, targetLanguage) = (targetLanguage, sourceLanguage)
            (sourceText, translatedText) = (translatedText, sourceText)
            
            sourceTextField.text = sourceText
            translationTextField.text = translatedText
            
            setupInitialState()
            
            translate()
        }
        
    @objc func clearSourceText() {
        sourceTextField.text = ""
        sourceText = ""
        translationTextField.text = ""
        translatedText = ""
        translateWorkItem?.cancel()
    }
        
        @objc func copyButtonTapped() {
            UIPasteboard.general.string = translationTextField.text
        }
        
    @objc func sourceLanguageTapped() {
        currentLanguageButton = sourceLanguageButton
        showPicker()
    }

    @objc func targetLanguageTapped() {
        currentLanguageButton = targetLanguageButton
        showPicker()
    }
    
     func showPicker() {
        languagePicker.reloadAllComponents()
        languagePicker.selectRow(0, inComponent: 0, animated: false)
        languagePicker.isHidden = false
        view.bringSubviewToFront(languagePicker)
    }
    
    
        func getLanguageName(for code: String) -> String {
            return languageNames[code] ?? code.uppercased()
        }
    
    }

private extension MainViewController {
    func translate() {
        translateWorkItem?.cancel()
        
        guard !sourceText.isEmpty else {
            translationTextField.text = ""
            return
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performTranslation()
        }
        translateWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    func performTranslation() {
        updateLoadingState(true)
        
        let parameters = TranslationParameters(
            sourceLanguage: sourceLanguage,
            destinationLanguage: targetLanguage,
            text: sourceText
        )
        
        networkService.translate(parameters: parameters) { [weak self] result in
            DispatchQueue.main.async {
                self?.updateLoadingState(false)
                switch result {
                case .success(let response):
                    self?.translatedText = response.destinationText
                    self?.translationTextField.text = response.destinationText
                case .failure(let error):
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            translationTextField.textColor = .systemGray
        } else {
            activityIndicator.stopAnimating()
            translationTextField.textColor = .label
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension MainViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    var sortedLanguageList: [(code: String, name: String)] {
        languageNames
            .sorted { $0.value < $1.value }
            .map { (code: $0.key, name: $0.value) }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortedLanguageList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortedLanguageList[row].name.capitalized
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = sortedLanguageList[row]

           if currentLanguageButton === sourceLanguageButton {
               sourceLanguage = selected.code
           } else if currentLanguageButton === targetLanguageButton {
               targetLanguage = selected.code
           }

           currentLanguageButton?.setTitle(selected.name.capitalized, for: .normal)
           translate()
        languagePicker.isHidden = false

    }
}



