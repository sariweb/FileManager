//
//  SAFileCell.h
//  FileManager
//
//  Created by SA on 8/6/18.
//  Copyright © 2018 SA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;

@end
