//
//  IssueDetailsViewController.swift
//  Scout
//
//  Created by redphx on 4/7/16.
//  Copyright © 2016 Team Nato. All rights reserved.
//

import UIKit
import ImageSlideshow
import GoogleMaps
import FontAwesome_swift

class IssueDetailsViewController: UIViewController {
  var issue: Issue?
  @IBOutlet weak var photosSlideshow: ImageSlideshow!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var userLabel: UILabel!
  @IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var locationNameLabel: UILabel!
  @IBOutlet weak var locationMap: GMSMapView!
  @IBOutlet weak var commentsTable: UITableView!
  @IBOutlet weak var commentsTableHeightContrstaint: NSLayoutConstraint!
  @IBOutlet weak var commentText: UITextField!
  @IBOutlet weak var postButton: UIButton!
  @IBOutlet weak var keyboardHeight: NSLayoutConstraint!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var voteButton: UIButton!
  
  var isVoted = false
  var comments: [Comment]?
  
  var transitionDelegate: ZoomAnimatedTransitioningDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IssueDetailsViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IssueDetailsViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    
    let tapDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IssueDetailsViewController.dismissKeyboard))
    view.addGestureRecognizer(tapDismiss)


    if let issue = issue {
      let photos = issue.photos
      var sources = [AlamofireSource]()
      if photos.count > 0 {
        for photo in photos {
          let source = AlamofireSource(urlString: photo.url)
          sources.append(source!)
        }
        
        photosSlideshow.circular = true
        photosSlideshow.zoomEnabled = true
        photosSlideshow.contentScaleMode = .ScaleAspectFill
        photosSlideshow.slideshowInterval = 5
        
        photosSlideshow.setImageInputs(sources)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(IssueDetailsViewController.viewPhotoFullscreen))
        photosSlideshow.addGestureRecognizer(recognizer)
      }
      
      titleLabel.text = issue.title
      descriptionLabel.text = issue.objectForKey("description") as? String
      
      userLabel.text = issue.reporter.fullName()
      userImage.af_setImageWithURL(NSURL(string: issue.reporter.avatarURL)!)
      
      locationNameLabel.text = issue.locationName
      let camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: issue.locationCoordinate.latitude, longitude: issue.locationCoordinate.longitude), zoom: 16, bearing: 0, viewingAngle: 0)
      locationMap.camera = camera
      locationMap.settings.setAllGesturesEnabled(false)
      
      let marker = GMSMarker()
      marker.position = CLLocationCoordinate2DMake(issue.locationCoordinate.latitude, issue.locationCoordinate.longitude)
      marker.map = locationMap
      
      setupCommentsTable()
      getComments()
      setupVoteButton()
    }
  }
  
  func dismissKeyboard() {
    commentText.resignFirstResponder()
  }
  
  func keyboardWillShow(notification: NSNotification) {
    var info = notification.userInfo!
    let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    
    UIView.animateWithDuration(0.1, animations: { () -> Void in
      self.keyboardHeight.constant = keyboardFrame.size.height
    })
  }
  
  func keyboardWillHide(notification: NSNotification) {
    UIView.animateWithDuration(0.1, animations: { () -> Void in
      self.keyboardHeight.constant = 0
    })
  }
  
  func setupVoteButton() {
    voteButton.titleLabel?.font = UIFont.fontAwesomeOfSize(24)
    issue?.isVotedByUser(PFUser.currentUser()!, callback: { (isVoted) in
      self.setVoteButtonState(isVoted)
    })
  }
  
  func setVoteButtonState(isVoted: Bool) -> Void {
    self.isVoted = isVoted

    if (isVoted) {
      voteButton.setTitle("", forState: .Normal) // fa-check-circle
    } else {
      voteButton.setTitle("", forState: .Normal) // fa-check-circle-o
    }
  }
  
  @IBAction func onVoteTapped(sender: UIButton) {
    issue!.updateVoteStatus(!isVoted, user: PFUser.currentUser()!) { 
      self.setVoteButtonState(!self.isVoted)
    }
  }
  
  func getComments() {
    issue?.getComments({ (comments) in
      self.comments = comments
      self.setupCommentsTable()
    })
  }
  
  func setupCommentsTable() {
    commentsTable.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
    commentsTable.rowHeight = UITableViewAutomaticDimension
    commentsTable.estimatedRowHeight = 60
    
    commentsTable.delegate = self
    commentsTable.dataSource = self
    
    commentsTable.reloadData()
  }
  
  @IBAction func onBackTapped(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func viewPhotoFullscreen() {
    let ctr = FullScreenSlideshowViewController()
    ctr.pageSelected = {(page: Int) in
      self.photosSlideshow.setScrollViewPage(page, animated: false)
    }
    
    ctr.initialPage = photosSlideshow.scrollViewPage
    ctr.inputs = photosSlideshow.images
    self.transitionDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: photosSlideshow);
    ctr.transitioningDelegate = self.transitionDelegate!
    self.presentViewController(ctr, animated: true, completion: nil)
  }

  @IBAction func onPostTapped(sender: UIButton) {
    dismissKeyboard()
    let message = commentText.text
    
    let pfComment = PFObject(className: "Comment")
    pfComment["message"] = message!
    pfComment["user"] = PFUser.currentUser()
    pfComment["issue"] = issue
    
    pfComment.saveInBackgroundWithBlock { (success, error) in
      self.commentText.text = ""
      self.commentsTable.setContentOffset(CGPointMake(0, 0), animated: true)
      self.getComments()
    }
  }
  
}

extension IssueDetailsViewController: UITableViewDelegate {
  
}

extension IssueDetailsViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = commentsTable.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
    cell.comment = comments![indexPath.row]
    
    return cell
  }
}
