

#import "CityPickerViewController.h"
#import "CityGroupModel.h"
#import "GroupHeadView.h"
#import "CityModel.h"
#import <sqlite3.h>

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define ksc750BL                        ([UIScreen mainScreen].bounds.size.width / 750.0f)
#define kScreenWidth                    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight                   [UIScreen mainScreen].bounds.size.height
@interface CityPickerViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,GroupHeadViewDelegate,CAAnimationDelegate>
{
    IBOutlet UITableView *tableview;
    IBOutlet UITextField *tfSearch;
    
    NSMutableArray *arrayData;//根据条件组装的数组
    NSArray *allCities;//用来存储数据库中拿到的数据
    NSMutableArray *groupArr;//组装成model后存储model的数组
    UIButton *cityBtn;  //热门城市显示的btn
    NSMutableArray *imageArr;//存储箭头的数组
    
    UIView *backView; //点击查找弹出的蒙版
    BOOL isSearch;  //是否进行了查找
    NSString *selectedCity;
    CityModel *selectedCityModel;
}

@end

@implementation CityPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isSearch = NO;
    if (self.defaultTitle) {
        self.title = self.defaultTitle;
    } else {
        self.title = @"选择城市";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent= NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    tfSearch.delegate = self;
    imageArr = [[NSMutableArray alloc] init];
    groupArr = [[NSMutableArray alloc] init];
    arrayData = [[NSMutableArray alloc] init];

    tableview.backgroundColor = RGB(235, 235, 235);
    tableview.delegate = self;
    tableview.dataSource = self;
    if ([tableview respondsToSelector:@selector(separatorInset)]) {
        tableview.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    }
    tableview.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
   
    allCities = [self getCityData:@""];
    [self searchAction:nil];
    
    backView = [self InitBackgroundView];
    [self.view addSubview:backView];
    backView.hidden = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self createBarButton:@"取消" withTag:1 withSize:CGSizeMake(30, 30)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)barButtonAction:(UIButton *)sender
{
    [self BottomPopViewController];
}

- (void)btnBackPressed
{
    [self BottomPopViewController];
}
#pragma mark - 查找
- (void)searchAction:(NSString *)text
{
    [groupArr removeAllObjects];
    [arrayData removeAllObjects];
    NSString *searchText = text;
    if (searchText.length == 0) {
        
        isSearch = NO;
        [arrayData addObject:[NSMutableArray array]];
        
        if (allCities.count > 0) {
            NSMutableArray *arrayHot = [NSMutableArray array];
            for (CityModel *model in allCities) {
                if (model.IsHot) {
                    [arrayHot addObject:model];
                }
            }
            [arrayData addObject:[self sortHotCity:arrayHot]];
            [arrayData addObjectsFromArray:[self groupByPinYin:allCities]];
        }
        for (int i = 0; i<arrayData.count; i++) {
            CityGroupModel *groupModel = [[CityGroupModel alloc] init];
            groupModel.opened = NO;
            groupModel.cityArr = arrayData[i];
            [groupArr addObject:groupModel];
        }
    } else {
        isSearch = YES;
        backView.hidden = YES;
        searchText = [searchText lowercaseString];
        
        [arrayData addObject:[NSMutableArray array]];
        
        if (allCities.count > 0) {
            NSMutableArray *arraySearch = [NSMutableArray array];
            for (CityModel *model in allCities) {
                if([model.CityName.lowercaseString rangeOfString:searchText].location !=NSNotFound || [model.CityPinYin.lowercaseString rangeOfString:searchText].location !=NSNotFound || [model.CityPinYinAbbr.lowercaseString rangeOfString:searchText].location !=NSNotFound || [model.CityIATACode.lowercaseString rangeOfString:searchText].location !=NSNotFound ){
                    [arraySearch addObject:model];
                }

            }
            if (arraySearch.count > 0) {
                NSMutableArray *arrayHot = [NSMutableArray array];
                for (CityModel *model in arraySearch) {
                    if (model.IsHot) {
                        [arrayHot addObject:model];
                    }
                }
                
                [arrayData addObject:[self sortHotCity:arrayHot]];                
                [arrayData addObjectsFromArray:[self groupByPinYin:arraySearch]];
            }
            for (int i = 0; i<arrayData.count; i++) {
                CityGroupModel *groupModel = [[CityGroupModel alloc] init];
                groupModel.opened = YES;
                groupModel.cityArr = arrayData[i];
                [groupArr addObject:groupModel];
            }
        }
    }
    [tableview reloadData];
}

- (NSArray *)groupByPinYin:(NSArray *)aArray
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSUInteger sectionTitlesCount = [collation.sectionTitles count];
    NSMutableArray *indexs = [NSMutableArray arrayWithCapacity:sectionTitlesCount];
    
    for (NSUInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [NSMutableArray array];
        [indexs addObject:array];
    }
    
    for (CityModel *c in aArray) {
        NSInteger index = [collation sectionForObject:c.CityPinYinAbbr collationStringSelector:@selector(lowercaseString)];
        NSMutableArray *sectionNames = indexs[index];
        [sectionNames addObject:c];
    }
    
    for (NSUInteger index = 0; index < sectionTitlesCount; index++) {
      
        NSMutableArray *namesForSection = indexs[index];
        NSArray *sortedNamesForSection = [collation sortedArrayFromArray:namesForSection collationStringSelector:@selector(CityPinYinAbbr)];
        [indexs replaceObjectAtIndex:index withObject:sortedNamesForSection];
    }
    return indexs;
}

- (NSArray *)sortHotCity:(NSMutableArray *)arrayHotCity
{
    [arrayHotCity sortUsingComparator:^NSComparisonResult(CityModel *obj1, CityModel *obj2) {
        if (obj1.SortRank > obj2.SortRank){
            return NSOrderedAscending;
        } else if (obj1.SortRank < obj2.SortRank){
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    return arrayHotCity;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    if ([arrayData[section] count] == 0 || section > 2) {
    //        return 0;
    //    }
    //    return 30;
    
    //    if (section < 2) {
    if ([arrayData[section] count] == 0) {
        return 0.1;
    } else {
        return isSearch ? 0.1 : 30;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
     return arrayData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(groupArr.count>0)
    {
        if(section == 0)
        {
            CityGroupModel *groupModel = groupArr[section];
           
            if(isSearch)
            {
                 groupModel.opened = NO;
            }
            else
            {
                 groupModel.opened = YES;
            }
            return groupModel.isOpened == 0 ? 0 : groupModel.cityArr.count;
        }
        else if(section == 1)
        {
            return 1;
        }
        else
        {
            CityGroupModel *groupModel = groupArr[section];
            
            return groupModel.isOpened == 0 ? 0 : groupModel.cityArr.count;
        }
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell) {
        for (UIView *obj in cell.contentView.subviews) {
            [obj removeFromSuperview];
        }
    }
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    }
    UIImageView *ivMarker = [[UIImageView alloc] initWithFrame:CGRectMake(320, 10, 22, 15)];
    ivMarker.tag = 100;
    ivMarker.image = [UIImage imageNamed:@"icon_confirm"];
    [cell.contentView addSubview:ivMarker];
    
        if(indexPath.section == 1)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
           
            if(!isSearch)
            {
                 [self createCell:cell];
            }
            [ivMarker removeFromSuperview];
        }
        else
        {
            CityModel *model = arrayData[indexPath.section][indexPath.row];
            //        cell.textLabel.text = model.CityName;
            UILabel *cityLab = [[UILabel alloc] init];
            cityLab.frame = CGRectMake(20, 10, 100, 30);
            [cell.contentView addSubview:cityLab];
            [cityLab setText:model.CityName];
            cityLab.font =[UIFont systemFontOfSize:13];
            [cityLab sizeToFit];
            UIImageView *ivMarker = (UIImageView *)[cell.contentView viewWithTag:100];
            if ([model.CityName isEqualToString:selectedCity]) {
                ivMarker.hidden = NO;
            } else {
                ivMarker.hidden = YES;
            }
        }
        return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CityModel *entity = arrayData[indexPath.section][indexPath.row];
    selectedCity = [entity.CityName copy];
    selectedCityModel = entity;
    [tableView reloadData];
    [self performSelector:@selector(selectItemAction) withObject:nil afterDelay:0.1];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSInteger lastLine = arrayData.count - 1;
    for (NSInteger i = arrayData.count - 1; i>=0; i--) {
        NSArray *array = arrayData[i];
        if (array.count > 0) {
            lastLine = i;
            break;
        }
    }
    
    if (section == lastLine) {
        return 1;
    }
    
    return 0.1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(isSearch){
        return nil;
    }
    GroupHeadView *v = [[GroupHeadView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [self bottomLine:v];
    
    v.tag = section;
    v.delegate = self;
    v.backgroundColor = RGB(235, 235, 235);;

    UIImageView *_bottomImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"change"]];
    if (section > 1 ) {
        [v addSubview:_bottomImgView];
        _bottomImgView.tag = section;
        _bottomImgView.frame = CGRectMake(375-10, 11, 5, 8);
    }
    
    NSString *imageStr = [NSString stringWithFormat:@"%ld",(long)v.tag];
    if([imageArr containsObject:imageStr])
    {
        [UIView animateWithDuration:0.5 animations:^{
           
        _bottomImgView.transform = CGAffineTransformMakeRotation((M_PI*90)/180);

        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            _bottomImgView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            
        }];
    }

    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor darkGrayColor];
    lblTitle.font = [UIFont systemFontOfSize:15];
    [v addSubview:lblTitle];
    NSArray *firstLetter = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"];
    if (section == 0) {
        lblTitle.text = @"";
    } else if (section == 1) {
        lblTitle.text = @"热门城市";
    } else {
        lblTitle.text = firstLetter[section-2];
    }
    return v;
//    } else {
//        return nil;
//    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if(indexPath.section == 1 )
    {
        if(!isSearch)
        {
            NSArray *cityArr = arrayData[1];
            
            return cityArr.count ? cityBtn.frame.size.height+cityBtn.frame.origin.y+10:0 ;
        }
        else
        {
            return 0;
        }
        
    }
    return 40;
}

-(void)createCell:(UITableViewCell*)cell
{
    NSArray *cityArr = arrayData[1];
    
    //    NSLog(@"%@",arrayData[1]);
    for (int i = 0; i<cityArr.count; i++) {
        cityBtn = [[UIButton alloc] init];
        [cell.contentView addSubview:cityBtn];
        cityBtn.tag = i;
        CGFloat w = (kScreenWidth-140*ksc750BL)/3.0;
        cityBtn.frame = CGRectMake(50*ksc750BL+(w+10)*(i%3), 22*ksc750BL+75*ksc750BL*(i/3), w, 70*ksc750BL);
        cityBtn.layer.masksToBounds=YES;
        cityBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        cityBtn.layer.borderWidth = 1.0f;
        cityBtn.layer.borderColor = RGB(128, 128, 128).CGColor;
        [cityBtn.layer setCornerRadius:8];
        [cityBtn addTarget: self action:@selector(click_touchCell:) forControlEvents:UIControlEventTouchUpInside];
        CityModel *model = cityArr[i];
        [cityBtn setTitle:model.CityName forState:UIControlStateNormal];
        [cityBtn setTitleColor:RGB(90, 90, 90) forState:UIControlStateNormal];
    }
}
-(void)click_touchCell:(UIButton *)sender
{
    CityModel *entity = arrayData[1][sender.tag];
    selectedCity = [entity.CityName copy];
    selectedCityModel = entity;
    [tableview reloadData];
    [self performSelector:@selector(selectItemAction) withObject:nil afterDelay:0.1];
}
- (void)selectItemAction
{
    if (selectedCity && self.selectCityHandler) {
        self.selectCityHandler(selectedCity);
    }
    
    if (self.selectCityModelHandler && selectedCityModel) {
        self.selectCityModelHandler(selectedCityModel);
    }
    [self BottomPopViewController];
    //    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - GroupHeadViewDelegate
- (void)headerViewDidClickNameView:(GroupHeadView *)headerView
{
    CityGroupModel *groupModel = groupArr[headerView.tag];
    NSString *headStr = [NSString stringWithFormat:@"%ld",(long)headerView.tag];
    if(headerView.tag == 1 || headerView.tag == 0)
    {
        return;
    }
    if(groupModel.opened == YES)
    {
        [imageArr removeObject:headStr];
    }
    else
    {
        [imageArr removeAllObjects];
        [imageArr addObject:headStr];
    }
    groupModel.opened = !groupModel.opened;
    for (int i = 0; i<groupArr.count; i++) {
        CityGroupModel *groupModel = [[CityGroupModel alloc] init];
        groupModel = groupArr[i];
        if(groupModel.opened == YES  && i != headerView.tag && i>1)
        {
            groupModel.opened = NO;
        }
    }
    [tableview reloadData];
}

- (void)dealloc
{
    tableview.delegate = nil;
    tableview.dataSource = nil;
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    backView.hidden = YES;
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(text.length == 0)
    {
        backView.hidden = NO;
    }
    [self searchAction:text];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self searchAction:textField.text];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    backView.hidden = NO;
}
#pragma mark 向下推出动画
-(void)BottomPopViewController
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
}
-(UIView *)InitBackgroundView
{
    UIView *backgroundView;
    if(!backgroundView)
    {
        backgroundView = [[UIView alloc] init];
        backgroundView.tag = 1034;
        backgroundView.frame = CGRectMake(0, 44, kScreenWidth, kScreenHeight);
        backgroundView.backgroundColor = RGBA(0, 0, 0, 0.7);
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_removeBackgroundView)];
        [backgroundView addGestureRecognizer:tapGesture];
    }
    return backgroundView;
}
-(void)click_removeBackgroundView
{
    [self.view endEditing:YES];
    UIView *view = [self.view viewWithTag:1034];
    view.hidden = YES;
}
//右侧按钮
- (UIView *)createBarButton:(NSString *)text
{
    return [self createBarButton:text withTag:0];
}
- (UIView *)createBarButton:(NSString *)text withTag:(NSInteger)tag
{
    return [self createBarButton:text withTag:tag withSize:CGSizeMake(50, 30)];
}
- (UIView *)createBarButton:(NSString *)text withTag:(NSInteger)tag withSize:(CGSize)size
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, 44)];
    container.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 7, size.width, size.height);
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    btn.tag = tag;
    [btn addTarget:self action:@selector(barButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:btn];
    if(tag == 0)
    {
        [btn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    }
    
    return container;
}
//画底部线
- (void)bottomLine:(UIView *)aView
{
    UIView *bottomLine = [[UIView alloc] init];
    [aView addSubview:bottomLine];
    bottomLine.backgroundColor = RGB(200, 200, 200);
    bottomLine.frame = CGRectMake(0, 29, kScreenWidth, 1);
}
//从数据库取值
- (NSArray *)getCityData:(NSString *)name
{
    static sqlite3* database;
    if (!database) {
        NSString *databaseFilePath=[[NSBundle mainBundle] pathForResource:@"CityDB" ofType:@"sqlite"];
        if (sqlite3_open([databaseFilePath UTF8String], &database)==SQLITE_OK) {
            NSLog(@"open sqlite db ok.");
            
        }
    }
    NSMutableArray *ArrAll = [NSMutableArray new];
    NSString *searchStr;
    
    if(name.length>0){
       searchStr =[NSString stringWithFormat:@"select * from CityTable where CityName = '%@' and IsDeleted = 0  order by CityPinYin asc",name];
    }else{
        searchStr = [NSString stringWithFormat:@"select CityIATACode,CityID,CityName,CityPinYin,CityPinYinAbbr,IsHot,SortRank from CityTable where IsDeleted = 0"];
    }
    
    const char *selectSql=[searchStr UTF8String];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK) {
        while (sqlite3_step(statement)==SQLITE_ROW) {
            
            CityModel *model=[[CityModel alloc] init];
            model.CityIATACode = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            model.CityID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            model.CityName = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            model.CityPinYin = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            model.CityPinYinAbbr = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            model.IsDeleted = [@(sqlite3_column_int(statement, 5)) boolValue];
            model.IsHot = [@(sqlite3_column_int(statement, 5)) boolValue];
            model.SortRank = sqlite3_column_int(statement, 6);
            [ArrAll addObject:model];
        }
    }
    return ArrAll;
}

@end
