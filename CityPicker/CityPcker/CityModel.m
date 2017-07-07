
#import "CityModel.h"

@implementation CityModel

- (id)copyWithZone:(NSZone *)zone
{
    CityModel *model = [[[self class] allocWithZone:zone] init];
    
    model.ServerDateTime = self.ServerDateTime;
    model.CityID = [self.CityID copy];
    model.CityName = [self.CityName copy];
    model.CityPinYin = [self.CityPinYin copy];
    model.CityPinYinAbbr = [self.CityPinYinAbbr copy];
    model.CityIATACode = [self.CityIATACode copy];
    model.IsHot = self.IsHot;
    model.IsDeleted = self.IsDeleted;
    model.SortRank = self.SortRank;
    
    return model;
}

@end
