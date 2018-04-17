//
// SectionHeaderView.h
// App
//
//  Created by punit jain on 5/31/15.

#import <UIKit/UIKit.h>

@interface SectionHeaderView : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

+ (NSString *) reuseIdentifier;

@end
