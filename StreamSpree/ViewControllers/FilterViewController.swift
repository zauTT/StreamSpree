//
//  FilterViewController.swift
//  StreamSpree
//
//  Created by Giorgi Zautashvili on 30.05.25.
//


import UIKit

class FilterViewController: UIViewController {
    
    var genres: [String] = []
    var ratings: [Double] = []
    
    var selectedGenre: String?
    var selectedRating: Double?
    
    private var hasInteractedWithSlider = false

    var onApply: ((_ genre: String?, _ rating: Double?) -> Void)?
    
    private let genrePicker = UIPickerView()
    private let ratingSlider = UISlider()
    private let ratingLabel = UILabel()
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        
        genrePicker.accessibilityIdentifier = "genrePicker"
        applyButton.accessibilityIdentifier = "applyFilterButton"
        
        if let selectedGenre = selectedGenre,
           let index = genres.firstIndex(of: selectedGenre) {
            genrePicker.selectRow(index, inComponent: 0, animated: false)
        }

        if let selectedRating = selectedRating {
            ratingSlider.value = Float(selectedRating)
            ratingLabel.text = "Rating: \(String(format: "%.1f", selectedRating))"
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))

    }
    
    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Filter Movies"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        
        genrePicker.delegate = self
        genrePicker.dataSource = self
        genrePicker.accessibilityIdentifier = "genrePickerWheel"
        
        ratingLabel.text = "Rating: Any"
        ratingLabel.textAlignment = .center
        
        ratingSlider.minimumValue = 5.0
        ratingSlider.maximumValue = 10.0
        ratingSlider.value = 5.0
        ratingSlider.accessibilityIdentifier = "ratingSlider"
        ratingSlider.addTarget(self, action: #selector(ratingChanged), for: .valueChanged)
        
        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        applyButton.backgroundColor = .systemBlue
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 10
        applyButton.accessibilityIdentifier = "applyFilterButton"
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        
        
        let stack = UIStackView(arrangedSubviews: [
            titleLabel, genrePicker, ratingLabel, ratingSlider, applyButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func ratingChanged(_ sender: UISlider) {
        hasInteractedWithSlider = true
        let rounded = Double(round(sender.value * 10) / 10)
        selectedRating = rounded
        ratingLabel.text = "Rating: \(String(format: "%.1f", rounded))"
    }
    
    @objc private func applyTapped() {
        let genreIndex = genrePicker.selectedRow(inComponent: 0)
        selectedGenre = genres[genreIndex] == "Any" ? nil : genres[genreIndex]
        let finalRating = hasInteractedWithSlider ? selectedRating : nil
        onApply?(selectedGenre, finalRating)
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genres.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genres[row]
    }
}
