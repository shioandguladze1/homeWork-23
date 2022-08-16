//
//  ViewController.swift
//  HomeWork23 (shio andghuladze)
//
//  Created by shio andghuladze on 16.08.22.
//

import UIKit

class ViewController: UIViewController {
    private let manager = NetworkManager.shared
    private var shows: Shows?
    private var similarShows: Shows?
    private let semaphore = DispatchSemaphore(value: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        getShows()
        getSimilarShows()
        getShowDetails()
    }
    
    func getShows(){
        semaphore.wait()
        manager.fetchData(url: baseUrl + tvShowsPath, dataType: Shows.self) { r in
            
            parseResult(result: r) { (shows: Shows) in
                self.shows = shows
                self.semaphore.signal()
            }
            
        }
    }
    
    func getSimilarShows(){
        semaphore.wait()
        let show = shows?.results.randomElement()
        
        guard let show = show else{
            return
        }
        
        manager.fetchData(url: baseUrl + tvShowDetailsPath + show.id.toString() + similarShowsPath, dataType: Shows.self) { r in
            
            parseResult(result: r) { (shows: Shows) in
                self.similarShows = shows
                self.semaphore.signal()
            }
            
        }
    }
    
    func getShowDetails(){
        semaphore.wait()
        
        let show = similarShows?.results.randomElement()
        
        guard let show = show else{
            return
        }
        
        manager.fetchData(url: baseUrl + tvShowDetailsPath + show.id.toString(), dataType: ShowDetails.self) { r in
            
            parseResult(result: r) { (details: ShowDetails) in
                print(details.name)
                print(details.numberOfEpisodes)
                self.semaphore.signal()
            }
            
        }
    }
    
}

extension Int{
    
    func toString()-> String{
        return "\(self)"
    }
    
}

