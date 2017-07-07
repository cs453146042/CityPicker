
#import "GroupHeadView.h"

@implementation GroupHeadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        UIButton *OpenGroupBtn = [[UIButton alloc] init];
        OpenGroupBtn.frame = self.frame;
        [self addSubview:OpenGroupBtn];
        [OpenGroupBtn addTarget:self action:@selector(click_GrooupBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(void)click_GrooupBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(headerViewDidClickNameView:)]) {
//        if (sender.selected) {
//            [UIView animateWithDuration:0.5 animations:^{
//               self.bottomImgView.transform = CGAffineTransformIdentity;
//                sender.selected = NO
//            } completion:^(BOOL finished) {
//                
//            }];
//        }
//        else {
//            [UIView animateWithDuration:0.5 animations:^{
//                self.bottomImgView.transform = CGAffineTransformMakeRotation((M_PI*90)/180);
//                sender.selected = YES;
//            } completion:^(BOOL finished) {
//            }];
//        }
//        self.isSelect = !self.isSelect;
        
        [self.delegate headerViewDidClickNameView:self];
    }
}
@end
