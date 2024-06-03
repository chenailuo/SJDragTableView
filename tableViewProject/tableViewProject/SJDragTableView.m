//
//  SJDragTableView.m
//  tableViewProject
//
//  Created by terryer on 2024/5/30.
//

#import "SJDragTableView.h"

typedef enum {
    AutoScrollUp,
    AutoScrollDown
}AutoScroll;


@interface SJDragTableView()
@property (nonatomic, strong) NSMutableArray *originalArray;
@property (nonatomic, strong) UIImageView *cellImageView;
@property (nonatomic, strong) NSIndexPath *fromIndexPath;
@property (nonatomic, strong) NSIndexPath *toIndexPath;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) AutoScroll autoScroll;

@end

@implementation SJDragTableView

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (_scrollSpeed == 0) {
        _scrollSpeed = 30;
    }
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveRow:)]];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        if(_scrollSpeed == 0){
            _scrollSpeed = 30;
        }
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveRow:)]];

    }
    return self;
}

- (void)moveRow:(UILongPressGestureRecognizer *)sender{
    
    CGPoint point =  [sender locationInView:self];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.fromIndexPath = [self indexPathForRowAtPoint:point];
        if (!_fromIndexPath) {
            return;
        }
        
        NSLog(@"---move 第index:%ld,count共:%ld个",_fromIndexPath.row,_dataArray.count);

        if (_fromIndexPath.row == _dataArray.count) return;
        UITableViewCell *cell = [self cellForRowAtIndexPath:_fromIndexPath];
        self.cellImageView = [self createCellImageView:cell];
        __block CGPoint center = cell.center;
        _cellImageView.center = center;
        _cellImageView.alpha = 0;
        __weak typeof(self) weak_self = self;
        [UIView animateWithDuration:0.2 animations:^{
            center.y = point.y;
            weak_self.cellImageView.center = center;
            weak_self.cellImageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            weak_self.cellImageView.alpha = 0.9;
            cell.alpha = 0;
        } completion:^(BOOL finished) {
            cell.hidden = YES;
        }];

    }else if(sender.state ==  UIGestureRecognizerStateChanged){
        _toIndexPath = [self indexPathForRowAtPoint:point];
        if (_toIndexPath.row == _dataArray.count) return;
       //更改imageView的中心点为手指点击位置
        CGPoint center = self.cellImageView.center;
        center.y = point.y;
        self.cellImageView.center = center;
        
        
        
        //判断cell是否被拖拽到了tableView的边缘，如果是，则自动滚动tableView
        if ([self isScrollToEdge]) {
            [self startTimerToScrollTableView];
        } else {
            [_displayLink invalidate];
        }
        
        /*
         若当前手指所在indexPath不是要移动cell的indexPath，
         且是插入模式，则执行cell的插入操作
         每次移动手指都要执行该判断，实时插入
        */
        if(_toIndexPath  && ![_toIndexPath isEqual:_fromIndexPath] && !self.isExchange){
            [self insertCell:_toIndexPath];
        }
    }else {
        //将隐藏的cell显示出来，并将imageView移除掉
        UITableViewCell *cell = [self cellForRowAtIndexPath:_fromIndexPath];
        if(!cell){
            NSLog(@"---没有获取到fromcell");
        }
        cell.hidden = NO;
        cell.alpha = 0;
        
//        NSArray<UITableViewCell *> *visibleCells = [self visibleCells];
     
        __weak typeof(self) weak_self = self;

        [UIView animateWithDuration:0.25 animations:^{
            cell.alpha = 1;
            cell.hidden = NO;
            weak_self.cellImageView.alpha = 0;
            weak_self.cellImageView.transform = CGAffineTransformIdentity;
            weak_self.cellImageView.center = cell.center;
        } completion:^(BOOL finished) {
            [weak_self.cellImageView removeFromSuperview];
             weak_self.cellImageView = nil;
        }];
    }
    
    
}


- (UIImageView *)createCellImageView:(UITableViewCell *)cell {
    UIImage *image = [self cellThumbImage:cell];
    UIImageView *cellImageView = [[UIImageView alloc] initWithImage:image];
    cellImageView.layer.borderWidth = 5;
    cellImageView.layer.borderColor = [UIColor redColor].CGColor;
    cellImageView.layer.masksToBounds = YES;
    cellImageView.layer.cornerRadius = 16;
    [self addSubview:cellImageView];
    return cellImageView;
}
- (UIImage *)cellThumbImage:(UITableViewCell *)cell
{
//    UIView *bgView = [cell viewWithTag:100];
//    UIGraphicsBeginImageContext(CGSizeMake(cell.frame.size.width-32, cell.frame.size.height-5));
//    [bgView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    
    // 创建一个与bgView大小相同的图像上下文
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0.0);
      
    // 获取当前图像上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
      
    // 将cell的图层内容渲染到图像上下文中

    [cell.contentView.layer renderInContext:context];
      
    // 从上下文中获取图像
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
      
    // 结束图像上下文
    UIGraphicsEndImageContext();
    return image;
}


- (BOOL)isScrollToEdge {
    //imageView拖动到tableView顶部，且tableView没有滚动到最上面
//    NSLog(@"MaxY=%f,contentOffset.y=%f,\n,self.frame.size.height%f,\n,self.contentInset.bottom=%f",CGRectGetMaxY(self.cellImageView.frame),self.contentOffset.y ,self.frame.size.height,self.contentInset.bottom);
    if ((CGRectGetMaxY(self.cellImageView.frame) > self.contentOffset.y + self.frame.size.height - self.contentInset.bottom) && (self.contentOffset.y < self.contentSize.height - self.frame.size.height + self.contentInset.bottom)) {
        self.autoScroll = AutoScrollDown;
        return YES;
    }
    
    //imageView拖动到tableView底部，且tableView没有滚动到最下面
    if ((self.cellImageView.frame.origin.y < self.contentOffset.y + self.contentInset.top) && (self.contentOffset.y > -self.contentInset.top)) {
        self.autoScroll = AutoScrollUp;
        return YES;
    }
    return NO;
}

- (void)startTimerToScrollTableView {
    [_displayLink invalidate];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollTableView)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}


- (void)scrollTableView{
    //如果已经滚动到最上面或最下面，则停止定时器并返回
    if ((_autoScroll == AutoScrollUp && self.contentOffset.y <= -self.contentInset.top)
        || (_autoScroll == AutoScrollDown && self.contentOffset.y >= self.contentSize.height - self.frame.size.height + self.contentInset.bottom)) {
            [_displayLink invalidate];
            return;
    }
    
    //改变tableView的contentOffset，实现自动滚动
    CGFloat height = _autoScroll == AutoScrollUp? -_scrollSpeed : _scrollSpeed;
    [self setContentOffset:CGPointMake(0, self.contentOffset.y + height)];
    //改变cellImageView的位置为手指所在位置
    _cellImageView.center = CGPointMake(_cellImageView.center.x, _cellImageView.center.y + height);
    
    //滚动tableView的同时也要执行插入操作
    _toIndexPath = [self indexPathForRowAtPoint:_cellImageView.center];
    
//    NSLog(@"scroll index:%ld,indexPath:%@",_toIndexPath.row,_toIndexPath);
    
    if (_toIndexPath && ![_toIndexPath isEqual:_fromIndexPath] && !self.isExchange)
        [self insertCell:_toIndexPath];
}

- (void)insertCell:(NSIndexPath *)toIndexPath{
    if (self.isGroup) {
        //先将cell的数据模型从之前的数组中移除，然后再插入新的数组
        NSMutableArray *fromSection = self.dataArray[_fromIndexPath.section];
        NSMutableArray *toSection = self.dataArray[toIndexPath.section];
        id obj = fromSection[_fromIndexPath.row];
        [fromSection removeObject:obj];
        [toSection insertObject:obj atIndex:toIndexPath.row];
        
        //如果某个组的所有cell都被移动到其他组，则删除这个组
        if (!fromSection.count) {
            [self.dataArray removeObject:fromSection];
        }
    } else {
        //交换两个cell的数据模型
//        NSLog(@"insert to index:%ld,count:%ld",toIndexPath.row,_dataArray.count);
        
        if (toIndexPath.row == _dataArray.count) return;
        
        if (_fromIndexPath.row == _dataArray.count) return;
        
        [self.dataArray exchangeObjectAtIndex:_fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    }
        
    [self reloadData];
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:toIndexPath];
    cell.hidden = YES;
    _fromIndexPath = toIndexPath;
}



- (void)resetCellLocation{
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:_originalArray];
    if (_isGroup) {
        for (int i = 0; i < _dataArray.count; i++) {
            _originalArray[i] = [_dataArray[i] mutableCopy];
        }
    }
    [self reloadData];
}

@end
