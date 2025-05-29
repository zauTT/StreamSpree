//
//  MovieDetailViewController.swift
//  StreamSpree
//
//  Created by Giorgi Zautashvili on 27.05.25.
//

import UIKit

class MovieDetailViewController: UIViewController {
    private let movie: Movie
    
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = movie.title
        
        setupLayout()
        configureView()
    }
    
    private func setupLayout() {
        view.addSubview(posterImageView)
        view.addSubview(genreLabel)
        view.addSubview(ratingLabel) 
        view.addSubview(overviewLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            posterImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            posterImageView.widthAnchor.constraint(equalToConstant: 150),
            posterImageView.heightAnchor.constraint(equalToConstant: 250),
            
            genreLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 10),
            genreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 130),
            genreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            ratingLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 30),
            ratingLabel.leadingAnchor.constraint(equalTo: genreLabel.leadingAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            overviewLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 10),
            overviewLabel.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    private func configureView() {
        genreLabel.text = "Genres: " + movie.genreNames.joined(separator: ", ")
        ratingLabel.text = "⭐️ \(movie.voteAverage)"
        overviewLabel.text = "Description: \(movie.overview)"
        
        if let url = movie.posterURL {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.posterImageView.image = image
                    }
                }
            } .resume()
        } else {
            posterImageView.image = nil
        }
    }
}
