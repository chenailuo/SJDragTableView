//
//  ViewController.m
//  tableViewProject
//
//  Created by terryer on 2024/5/30.
//

#import "ViewController.h"
#import "SJDragTableView.h"

@interface CustomTableViewCell : UITableViewCell
  
@property (nonatomic, strong)  UIImageView *imageV;
@property (nonatomic, strong)  UILabel *label;
  
@end

  
@implementation CustomTableViewCell
  
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 初始化图片视图和标签
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        imageView.image = [UIImage imageNamed:@"your_image_name"]; // 替换为你的图片名
        [self.contentView addSubview:imageView];
          
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, self.bounds.size.width - 110, 60)];
        label.text = @"Your Label Text";
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 0; // 多行文本
        [self.contentView addSubview:label];
        self.label = label;
        // 设置单元格的高度（这通常不是在这里设置的，而是在 tableView:heightForRowAt: 代理方法中）
        // 但为了完整性，我们可以设置一个内部的固定高度标志
        self.frame = CGRectMake(0, 0, self.bounds.size.width, 100);
    }
    return self;
}
  
// 如果你在 Interface Builder 中设计单元格，可以使用 awakeFromNib 方法来设置视图
- (void)awakeFromNib {
    [super awakeFromNib];
    // 初始化图片视图和标签的代码（如果你使用 Storyboard 或 XIB）
}
  
@end
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)SJDragTableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView =  [[SJDragTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1000) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self ;
    self.dataArray = [NSMutableArray arrayWithObjects:@"第一行aaa",@"第2行bba",@"第3行ccc",@"第4行DDDD", nil];
    self.tableView.dataArray =  self.dataArray;
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"CustomCellIdentifier"];
    [self.tableView reloadData];
}

 -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCellIdentifier" forIndexPath:indexPath];
    // 配置 cell 的内容，比如设置 imageView.image 和 label.text
//    cell.label.text = [NSString stringWithFormat:@"我是第%ld行label",indexPath.row];
    NSString *textStr = self.dataArray[indexPath.row];
    cell.label.text = [NSString stringWithFormat:@"%@", textStr];

    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return  100;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
@end
