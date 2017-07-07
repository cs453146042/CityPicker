
#import <Foundation/Foundation.h>

@interface CityGroupModel : NSObject

@property (nonatomic,strong)NSArray *cityArr;

/**
 *  标记这组是否需要打开。YES表示打开，NO表示不打开
 */
@property (nonatomic,assign,getter = isOpened) BOOL opened;

@end
