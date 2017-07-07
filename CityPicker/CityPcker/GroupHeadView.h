

#import <UIKit/UIKit.h>

@class GroupHeadView;

@protocol GroupHeadViewDelegate <NSObject>

@optional
//点击Cell头部时的代理反馈
- (void)headerViewDidClickNameView:(GroupHeadView *)headerView;

@end

@interface GroupHeadView : UIView

@property (nonatomic)    BOOL isSelect;

@property (nonatomic,strong)id<GroupHeadViewDelegate > delegate;

@end
