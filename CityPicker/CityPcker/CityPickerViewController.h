

#import <UIKit/UIKit.h>

@interface CityPickerViewController : UIViewController

@property (nonatomic, strong) NSString *defaultTitle;
@property (nonatomic, copy) void (^selectCityHandler) (NSString *);
@property (nonatomic, copy) void (^selectCityModelHandler) (id);


@end
