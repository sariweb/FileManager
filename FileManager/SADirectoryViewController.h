//
//  SADirectoryViewController.h
//  FileManager
//
//  Created by SA on 8/6/18.
//  Copyright © 2018 SA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SADirectoryViewController : UITableViewController

@property (strong, nonatomic) NSString* path;

- (id) initWithFolderPath:(NSString*) path;

- (IBAction) actionInfoCell:(id)sender;

@end
