//
//  MainViewController.swift
//  StreamSpree
//
//  Created by Giorgi Zautashvili on 23.05.25.
//


import UIKit

class MainViewController: UIViewController {
    
    private let viewModel = MovieViewModel()
    
    private let scrollView = UIScrollView()
    
    private let contentStack = UIStackView()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Filter 🎯", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .systemYellow
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let shuffleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Shuffle 🎲", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
        viewModel.fetchRandomTrendingMovie()
    }
    
    private func setupLayout() {
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.addSubview(contentStack)
        
        contentStack.axis = .vertical
        contentStack.spacing = 10
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.addArrangedSubview(posterImageView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(ratingLabel)
        contentStack.addArrangedSubview(genreLabel)
        contentStack.addArrangedSubview(overviewLabel)
        
        view.addSubview(filterButton)
        view.addSubview(shuffleButton)
        
        NSLayoutConstraint.activate([
            filterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: shuffleButton.topAnchor, constant: -10),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

            posterImageView.heightAnchor.constraint(equalToConstant: 300),

            shuffleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            shuffleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            shuffleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            shuffleButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        
        shuffleButton.addTarget(self, action: #selector(shuffleTapped), for: .touchUpInside)
        
    }
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.titleLabel.text = self.viewModel.title
            self.ratingLabel.text = self.viewModel.ratings
            self.genreLabel.text = self.viewModel.genre
            self.overviewLabel.text = self.viewModel.overwiev
            self.loadImage()
        }
    }
    
    @objc private func shuffleTapped() {
        viewModel.fetchRandomTrendingMovie()
    }
    
    @objc private func filterTapped() {
        let alert = UIAlertController(title: "Filter", message: "Enter genre and min rating", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Genre (e.g., Action)" }
        alert.addTextField { $0.placeholder = "Min Rating (e.g., 7.5)"; $0.keyboardType = .decimalPad }
        
        let apply = UIAlertAction(title: "Apply", style: .default) { _ in
            let genre = alert.textFields?[0].text
            let ratingText = alert.textFields?[1].text
            let minRating = Double(ratingText ?? "")
            self.viewModel.filterMovies(genre: genre, minRating: minRating)
        }
        alert.addAction(apply)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func loadImage() {
        guard let url = viewModel.posterURL else {
            posterImageView.image = nil
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.posterImageView.image = image
            }
        } .resume()
    }
}
