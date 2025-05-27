//
//  MovieDetailViewController.swift
//  StreamSpree
//
//  Created by Giorgi Zautashvili on 27.05.25.
//

import UIKit

class MovieDetailViewController: UIViewController {
    private let movie: Movie

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
        
    }
}
