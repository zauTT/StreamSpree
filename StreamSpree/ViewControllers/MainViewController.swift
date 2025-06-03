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
    
    private let genres = ["Any", "Action", "Adventure", "Animation", "Comedy", "Crime", "Documentary", "Drama", "Family", "Fantasy", "History", "Horror", "Music", "Mystery", "Romance", "Sci-Fi", "TV Movie", "Thriller", "War", "Western"]
    
    private let ratings: [String] = ["Any"] + (5...10).map { String(format: "%.1f", Double($0)) }
    
    private let pickerView = UIPickerView()
    
    private var selectedGenre: String?
    
    private var selectedRating: Double?
    
    private let watchlistButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Watchlist ❤️", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        
        edgeSwipeGesture()
        
        let filterNavButton = UIButton(type: .system)
        filterNavButton.setTitle("Filter", for: .normal)
        filterNavButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        filterNavButton.accessibilityIdentifier = "FilterButton"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: filterNavButton)
        
        let goToWatchlistButton = UIButton(type: .system)
        goToWatchlistButton.setTitle("Watchlist >", for: .normal)
        goToWatchlistButton.addTarget(self, action: #selector(goToWatchlistTapped), for: .touchUpInside)
        goToWatchlistButton.accessibilityIdentifier = "watchlistTabButton"

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: goToWatchlistButton)
        
        setupLayout()
        bindViewModel()
        viewModel.fetchRandomTrendingMovie()
        
        titleLabel.accessibilityIdentifier = "movieTitleLabel"
        goToWatchlistButton.accessibilityIdentifier = "watchlistTabButton"
        watchlistButton.accessibilityIdentifier = "addToWatchlistButton"
        shuffleButton.accessibilityIdentifier = "shuffleButton"
        pickerView.accessibilityIdentifier = "genrePicker"
        filterButton.accessibilityIdentifier = "FilterButton"
    }
    
    private func edgeSwipeGesture() {
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeSwipe(_:)))
        edgeSwipe.edges = [.right]
        view.addGestureRecognizer(edgeSwipe)
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
        contentStack.addArrangedSubview(watchlistButton)
        contentStack.addArrangedSubview(genreLabel)
        contentStack.addArrangedSubview(overviewLabel)
        
        view.addSubview(shuffleButton)
        
        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        watchlistButton.addTarget(self, action: #selector(addToWatchlistTapped), for: .touchUpInside)
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
        viewModel.onNoResults = { [weak self] in
            self?.showToast(message: "No movies matched your filters.")
        }
    }
    
    func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.isAccessibilityElement = true
        toastLabel.accessibilityIdentifier = "toastLabel"
        toastLabel.accessibilityLabel = message
        toastLabel.accessibilityTraits = .staticText
        
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toastLabel)

        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toastLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toastLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 35)
        ])

        let isUITesting = ProcessInfo.processInfo.environment["UI_TESTING"] == "1"

        if isUITesting {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                toastLabel.removeFromSuperview()
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 2.0, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    @objc private func handleEdgeSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            let watchlistVC = WatchlistViewController()
            navigationController?.pushViewController(watchlistVC, animated: true)
        }
    }
    
    @objc private func shuffleTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        viewModel.fetchRandomTrendingMovie()
    }
    
    @objc private func addToWatchlistTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        guard let movie = viewModel.currentMovie else { return }
        WatchlistManager().addToWatchlist(movie)
        showToast(message: "Added to Watchlist!")
    }
    
    @objc private func goToWatchlistTapped() {
        let watchlistVC = WatchlistViewController()
        navigationController?.pushViewController(watchlistVC, animated: true)
    }
    
    @objc private func filterTapped() {
        let filterVC = FilterViewController()
        filterVC.genres = genres
        filterVC.ratings = (5...10).map { Double($0) }
        filterVC.modalPresentationStyle = .formSheet

        filterVC.onApply = { [weak self] selectedGenre, selectedRating in
            self?.selectedGenre = selectedGenre
            self?.selectedRating = selectedRating
            self?.viewModel.filterMovies(genre: selectedGenre, minRating: selectedRating)
        }

        present(filterVC, animated: true)
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

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? genres.count : ratings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? genres[row] : ratings[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedGenre = genres[row] == "Any" ? nil : genres[row]
        } else {
            selectedRating = ratings[row] == "Any" ? nil : Double(ratings[row])
        }
    }
}
