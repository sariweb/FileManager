//
//  SADirectoryViewController.m
//  FileManager
//
//  Created by SA on 8/6/18.
//  Copyright © 2018 SA. All rights reserved.
//

#import "SADirectoryViewController.h"
#import "SAFileCell.h"
#import "UIView+UITableViewCell.h"

@interface SADirectoryViewController ()

@property (strong, nonatomic) NSArray *contents;
@property (strong, nonatomic) NSString *selectedPath;
@property (strong, nonatomic) NSFileManager *fileManager;

@end

static NSString *initPath = @"/Volumes/";

@implementation SADirectoryViewController

- (id) initWithFolderPath:(NSString*) path
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.path = path;
    }
    return self;
}

- (void)setPath:(NSString *)path {
    
    _path = path;
    
    if (!self.fileManager) {
        self.fileManager= [NSFileManager defaultManager];
    }
    
    [self reloadContents];
    
    self.navigationItem.title = [self.path lastPathComponent];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSMutableArray *rightBarItems = [NSMutableArray array];
    
    if ([self.navigationController.viewControllers count] > 1) {
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"Root"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(actionBackToRoot:)];
        [rightBarItems addObject:item];

    }
    
    UIBarButtonItem *itemAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                            target:self
                            action:@selector(actionCreateFileFolder:)];
    
    [rightBarItems addObject:itemAdd];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithArray:rightBarItems];
    
    [self reloadContents];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.navigationItem.title = [self.path lastPathComponent];
    
    if (!self.path) {
        self.path = initPath;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - File/Directory Methods

- (BOOL) isHiddenFile:(NSString*)fileName {
    
    NSString* firstSymbol = [fileName substringToIndex:1];
    
    if ([firstSymbol isEqualToString:@"."]) {
        return YES;
    } else {
        return NO;
    }
    
}

- (BOOL) isDirectoryFileAtPath:(NSString*)path {
    
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    return isDirectory;
    
}

- (BOOL)isDirectoryAtIndexPath:(NSIndexPath*)indexPath {
    
    NSString *fileName = [self.contents objectAtIndex:indexPath.row];
    NSString *filePath = [self.path stringByAppendingPathComponent:fileName];

    return [self isDirectoryFileAtPath:filePath];
}

- (NSString*)pathToFile:(NSString*)fileName {
    
    return [self.path stringByAppendingPathComponent:fileName];
    
}

- (NSString*)fileSizeFromValue:(unsigned long long) size {
    
    static NSString* units[] = {@"B", @"KB", @"MB", @"GB", @"TB"};
    static int unitsCount = 5;
    
    int index = 0;
    
    double fileSize = (double)size;
    
    while (fileSize > 1024 && index < unitsCount) {
        fileSize /= 1024;
        index++;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", fileSize, units[index]];
}

#pragma mark - Contents Methods

- (void)removeHiddenFilesFromContents {
    
    NSMutableArray* contents = [NSMutableArray array];
    for (NSString* fileName in self.contents) {
        if (![self isHiddenFile:fileName]) {
            [contents addObject:fileName];
        }
    }
    self.contents = contents;
    
}

- (void)sortContents {
    
    self.contents = [self.contents sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        
        BOOL isDirectoryObj1 = [self isDirectoryFileAtPath:[self.path stringByAppendingPathComponent:obj1]];
        BOOL isDirectoryObj2 = [self isDirectoryFileAtPath:[self.path stringByAppendingPathComponent:obj2]];
        
        if (isDirectoryObj1 && !isDirectoryObj2) {
            return NSOrderedAscending;
        } else if (!isDirectoryObj1 && isDirectoryObj2) {
            return NSOrderedDescending;
        } else {
            return [obj1 compare:obj2];
        }
    }];
    
}

- (void)getContents {
    
    NSError *error = nil;
    
    self.contents = [self.fileManager contentsOfDirectoryAtPath:self.path
                                                          error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
}

- (void)reloadContents {
    
    [self getContents];
    
    [self removeHiddenFilesFromContents];
    
    [self sortContents];
    
    [self.tableView reloadData];
}

#pragma mark - Create Methods

- (void)createFolderWithName:(NSString*)name {
    
    NSError *error = nil;
    
    NSString *directory = [self.path stringByAppendingPathComponent:name];
    
    if(![self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
        // An error has occurred, do something to handle it
        NSLog(@"Failed to create directory \"%@\". Error: %@", directory, error);
    }
    
    [self reloadContents];
}

- (void)createFileWithName:(NSString*)name {
    
    NSError *error = nil;
    
    NSString *file = [self.path stringByAppendingPathComponent:name];
    
    if(![self.fileManager createFileAtPath:file contents:nil attributes:nil]) {
        // An error has occurred, do something to handle it
        NSLog(@"Failed to create file \"%@\". Error: %@", file, error);
    }
    
    [self reloadContents];
    
}

#pragma mark - Actions

- (void)actionCreateFileFolder:(UIBarButtonItem*)sender{
    
    UIAlertController *alertController =[UIAlertController alertControllerWithTitle:@"Create Folder / File"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *createFolderButton = [UIAlertAction
                                         actionWithTitle:@"Create Folder"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             if ([alertController.textFields[0].text length] > 0) {
                                                 [self createFolderWithName:alertController.textFields[0].text];
                                             }
                                             
                                         }];
    
    UIAlertAction *createFileButton = [UIAlertAction
                                       actionWithTitle:@"Create File"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           if ([alertController.textFields[0].text length] > 0) {
                                               [self createFileWithName:alertController.textFields[0].text];
                                           }
                                       }];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:createFolderButton];
    [alertController addAction:createFileButton];
    [alertController addAction:cancelButton];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Name";
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void) actionBackToRoot:(UIBarButtonItem*) sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction) actionInfoCell:(UIButton*)sender {
    
    NSLog(@"actionInfoCell");
    
    UITableViewCell* cell = [sender superCell];
    
    if (cell) {
        
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        
        
 
    }
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *fileIdentifier = @"FileCell";
    static NSString *folderIdentifier = @"FolderCell";
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier];
        
        cell.textLabel.text = fileName;
        
        return cell;
        
    } else {
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        NSDictionary* attributes = [self.fileManager attributesOfItemAtPath:path error:nil];
        
        SAFileCell *cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        
        cell.textLabel.text = fileName;
        cell.detailTextLabel.text = [self fileSizeFromValue:[attributes fileSize]];
        
        return cell;
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    return YES;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    NSMutableArray* tempContents = [NSMutableArray arrayWithArray:self.contents];
    
    if ([self.fileManager removeItemAtPath:[self pathToFile:fileName] error:nil]) {
        [tempContents removeObject:fileName];
        self.contents = tempContents;
    }
    
    [self.tableView beginUpdates];
    NSArray* indexes = [NSArray arrayWithObject:indexPath];
    [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        return 44.f;
    } else {
        return 80.f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
    
        NSString *fileName = [self.contents objectAtIndex:indexPath.row];
        
        NSString *path = [self.path stringByAppendingPathComponent:fileName];
        
        SADirectoryViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SADirectoryViewController"];
        vc.path = path;
        [self.navigationController pushViewController:vc animated:YES];

    }

}


@end
