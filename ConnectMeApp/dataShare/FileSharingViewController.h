//
//  SecondViewController.h


#import <UIKit/UIKit.h>

@interface FileSharingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblFiles;

@end
