//
//  PostCell.swift
//  Be_Real_Clone
//
//  Created by Jonathan Velez on 3/27/23.
//

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {
    
    @IBOutlet weak var UsernameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var initialsLabel: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    
    @IBOutlet weak var postImageView: UIImageView!
    
    
    private var imageDataRequest: DataRequest?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with post: Post) {
        // TODO: Pt 1 - Configure Post Cell
        
        if let user = post.user {
            UsernameLabel.text = user.username
        }
        
        if let imageFile = post.imageFile,
            let imageUrl = imageFile.url {
            
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result{
                case .success(let image):
                    self?.postImageView.image = image
                case .failure(let error):
                    print(" Error fetching image: \(error.localizedDescription)")
                }
            }
        }
        
        captionLabel.text = post.caption
        
        
        if let date = post.createdAt {
           locationLabel.text = DateFormatter.postFormatter.string(from: date)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // TODO: P1 - Cancel image download
        
        postImageView.image = nil
        
        imageDataRequest?.cancel()

    }
}

