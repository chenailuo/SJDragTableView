//
//  SJDragTableView.h
//  tableViewProject
//
//  Created by terryer on 2024/5/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJDragTableView : UITableView
/**
 *  tableView的数据源，必须跟外界的数据源一致
 *  不能是外界数据源copy出来的，也必须是可变的
 *
 */
@property (nonatomic, strong) NSMutableArray *dataArray;

/**
 *  你的tableView是否有分组
 *  有分组则设为YES，无分组可不设置
 */
@property (nonatomic, assign) BOOL isGroup;

/**
 *  移动cell的时候，是以交换的方式，还是插入的方式
 *  例如将第1个cell移动到第5个，插入：23451  交换：52341
 *  默认为NO，即插入的方式
 */
@property (nonatomic, assign) BOOL isExchange;

/**
 *  当cell拖拽到tableView边缘时,tableView的滚动速度
 *  每个时间单位滚动多少距离，默认为3
 */
@property (nonatomic, assign) CGFloat scrollSpeed;


/**
 *  所有cell恢复到拖动之前的位置
 */
- (void)resetCellLocation;

@end

NS_ASSUME_NONNULL_END
