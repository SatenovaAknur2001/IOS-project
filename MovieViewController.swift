//
//  MovieViewController.swift
//  Project-1
//
//  Created by Акнур on 4/12/20.
//  Copyright © 2020 Акнур. All rights reserved.
//

import UIKit

class MovieViewController: UITableViewController {

    
     init(movie: Movie) {
         super.init(nibName: nil, bundle: nil)
         print("movie \(movie.title)")
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .lightGray
     }
 }

