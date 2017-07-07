

#import <Foundation/Foundation.h>

@interface CityModel : NSObject

@property (nonatomic) long ServerDateTime;
@property (nonatomic, strong) NSString *CityID;
@property (nonatomic, strong) NSString *CityName;
@property (nonatomic, strong) NSString *CityIATACode;
@property (nonatomic, strong) NSString *CityPinYinAbbr;
@property (nonatomic, strong) NSString *CityPinYin;
@property (nonatomic) BOOL IsHot;
@property (nonatomic) BOOL IsDeleted;
@property (nonatomic) int SortRank;

@end
