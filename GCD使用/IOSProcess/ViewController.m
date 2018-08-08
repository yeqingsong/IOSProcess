//
//  ViewController.m
//  IOSProcess
//
//  Created by shoule on 2018/8/7.
//  Copyright © 2018年 yqs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    dispatch_queue_t queue;
}
@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,strong) UIImageView* imageView1;
@property (nonatomic,strong) UIImageView* imageView2;
@property (nonatomic,strong) UIImageView* imageView3;
@end
//http://www.cocoachina.com/ios/20170707/19769.html 参考链接
@implementation ViewController
//进程：可以理解成一个运行中的应用程序，是系统进行资源分配和调度的基本单位，是操作系统结构的基础，主要管理资源。
//线程：是进程的基本执行单元，一个进程对应多个线程。
//主线程：处理UI，所有更新UI的操作都必须在主线程上执行。不要把耗时操作放在主线程，会卡界面。
//多线程：在同一时刻，一个CPU只能处理1条线程，但CPU可以在多条线程之间快速的切换，只要切换的足够快，就造成了多线程一同执行的假象。
//线程就像火车的一节车厢，进程则是火车。车厢（线程）离开火车（进程）是无法跑动的，而火车（进程）至少有一节车厢（主线程）。多线程可以看做多个车厢，它的出现是为了提高效率。
//多线程是通过提高资源使用率来提高系统总体的效率。
//我们运用多线程的目的是：将耗时的操作放在后台执行！
- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor blueColor];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
   
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 200, 200, 200)];
    self.imageView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.imageView];
    self.imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(200, 200, 200, 200)];
    self.imageView1.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.imageView1];
    self.imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 400, 200, 200)];
    self.imageView2.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.imageView2];
    self.imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(200, 400, 200, 200)];
    self.imageView3.backgroundColor = [UIColor brownColor];
    [self.view addSubview:self.imageView3];
}
-(void)clickButton{
    ///线程同步死锁
//    [self tongBuBingFa];
    ///新建队列中进行同步和异步执行是否开辟新线程
//    [self ShiFoukaipixinxiancheng];
    ///主队列中进行同步和异步执行情况
//    [self ZhuDuiLieXianCheng];
    ///GCD栅栏方法使用
    /*栅栏函数只有在自己create的并发队列中使用 而不能与全局并发队列和主队列使用*/
//    [self zhalanshiyong];
  ///GCDgroup组的使用
//    [self GCDgroupShiYong];
///GCD信号量dispatch_semaphore的使用
    [self GCDSemaphoreShiYong];
}

//参考 https://www.cnblogs.com/yajunLi/p/6274282.html
////创建信号量，参数：信号量的初值，如果小于0则会返回NULL，最大可开辟的线程量
//dispatch_semaphore_create（信号量值）
//
////等待降低信号量
//dispatch_semaphore_wait（信号量，等待时间）
//
////提高信号量
//dispatch_semaphore_signal(信号量)
#pragma mark -- GCDSemaphore信号量的使用
///模拟应用场景：同时发送多个异步请求，全部请求结束后再操作主线程UI
-(void)GCDSemaphoreShiYong{
    ///创建semaphore
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block UIImage *image1 ;
    __block UIImage *image2 ;
    __block UIImage *image3 ;
    __block UIImage *image4 ;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1111111111111111");
      __block  NSInteger num = 0;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *picURLStr = @"http://c.hiphotos.baidu.com/image/pic/item/4bed2e738bd4b31ccda81d7a8bd6277f9f2ff85f.jpg";
            NSURL *picURL = [NSURL URLWithString:picURLStr];
            NSData *picData = [NSData dataWithContentsOfURL:picURL];
            image1 = [UIImage imageWithData:picData];
            NSLog(@"队列组：有一个耗时操作完成！");
            num++;
            if (num == 4) {
                dispatch_semaphore_signal(semaphore);
            }
        });
    
       
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *picURLStr = @"http://h.hiphotos.baidu.com/image/pic/item/95eef01f3a292df57f4575cab0315c6035a8736f.jpg";
            NSURL *picURL = [NSURL URLWithString:picURLStr];
            NSData *picData = [NSData dataWithContentsOfURL:picURL];
            image2 = [UIImage imageWithData:picData];
            NSLog(@"队列组：有一个耗时操作完成！");
            num++;
            if (num == 4) {
                dispatch_semaphore_signal(semaphore);
            }
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *picURLStr = @"http://g.hiphotos.baidu.com/image/pic/item/0df3d7ca7bcb0a468c3807fd6763f6246a60afd8.jpg";
            NSURL *picURL = [NSURL URLWithString:picURLStr];
            NSData *picData = [NSData dataWithContentsOfURL:picURL];
            image3 = [UIImage imageWithData:picData];
            NSLog(@"队列组：有一个耗时操作完成！");
            num++;
            if (num == 4) {
                dispatch_semaphore_signal(semaphore);
            }
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *picURLStr = @"http://d.hiphotos.baidu.com/image/pic/item/b17eca8065380cd79a75c52cad44ad3458828183.jpg";
            NSURL *picURL = [NSURL URLWithString:picURLStr];
            NSData *picData = [NSData dataWithContentsOfURL:picURL];
            image4 = [UIImage imageWithData:picData];
            NSLog(@"队列组：有一个耗时操作完成！");
            num++;
            if (num == 4) {
                dispatch_semaphore_signal(semaphore);
            }
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"22222222222222");
            self.imageView.image = image1;
            self.imageView1.image = image2;
            self.imageView2.image = image3;
            self.imageView3.image = image4;
            
        });
    });
    NSLog(@"33333333333333333");
}
#pragma mark -- GCDgroup组的使用
-(void)GCDgroupShiYong{
    //创建GCD组
    dispatch_group_t group =  dispatch_group_create();
    
    __block UIImage *image1 ;
    __block UIImage *image2 ;
    //添加GCD组成员
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSString *picURLStr = @"http://c.hiphotos.baidu.com/image/pic/item/4bed2e738bd4b31ccda81d7a8bd6277f9f2ff85f.jpg";
        NSURL *picURL = [NSURL URLWithString:picURLStr];
        NSData *picData = [NSData dataWithContentsOfURL:picURL];
        image1 = [UIImage imageWithData:picData];
        NSLog(@"队列组：有一个耗时操作完成！");
    });
    //添加GCD组成员
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSString *picURLStr = @"http://h.hiphotos.baidu.com/image/pic/item/95eef01f3a292df57f4575cab0315c6035a8736f.jpg";
        NSURL *picURL = [NSURL URLWithString:picURLStr];
        NSData *picData = [NSData dataWithContentsOfURL:picURL];
        image2 = [UIImage imageWithData:picData];
        NSLog(@"队列组：有一个耗时操作完成！");
    });
    ///组操作会等待组里的异步操作执行完以后再接受notify，开始执行dispatch_group_notify方法，不会阻碍主线程所以操作3最先输出
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        self.imageView.image = image1;
        self.imageView1.image = image2;
        NSLog(@"1111111111111111");
    });
    //操作3
    NSLog(@"333333333333333");
}
#pragma mark -- GCD栅栏方法使用
-(void)zhalanshiyong{
    /*栅栏函数只有在自己create的并发队列中使用 而不能与全局并发队列和主队列使用*/
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    // 异步
   __block UIImage *image1 ;
    // 操作1
    dispatch_async(queue, ^{
        // 耗时操作放在这里，例如下载图片。（运用线程休眠两秒来模拟耗时操作）
//        http://h.hiphotos.baidu.com/image/pic/item/95eef01f3a292df57f4575cab0315c6035a8736f.jpg
//        http://g.hiphotos.baidu.com/image/pic/item/0df3d7ca7bcb0a468c3807fd6763f6246a60afd8.jpg
//        http://d.hiphotos.baidu.com/image/pic/item/b17eca8065380cd79a75c52cad44ad3458828183.jpg
//        [NSThread sleepForTimeInterval:2];
        NSLog(@"333333333333333");
        NSString *picURLStr = @"http://c.hiphotos.baidu.com/image/pic/item/4bed2e738bd4b31ccda81d7a8bd6277f9f2ff85f.jpg";
        NSURL *picURL = [NSURL URLWithString:picURLStr];
        NSData *picData = [NSData dataWithContentsOfURL:picURL];
        image1 = [UIImage imageWithData:picData];
    });
    
    /*栅栏函数只有在自己create的并发队列中使用 而不能与全局并发队列和主队列使用*/
    ///只有添加了栅栏方法下面的代码才能执行，才能更新主线程UI,否则会先执行操作2，再执行操作1
    dispatch_barrier_async(queue, ^{
        NSLog(@"------------barrier------------%@", [NSThread currentThread]);
        
    });
    // 回到主线程处理UI
    // 操作2
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // 在主线程上添加图片
            self.imageView.image = image1;
            NSLog(@"1111111111111111");
        });
    });
    
   
}
#pragma mark -- 主队列中进行同步和异步执行情况
-(void)ZhuDuiLieXianCheng{
    // 主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    // 同步执行：主队列同步会造成线程死锁，不能往下执行，不会开辟新线程
//    dispatch_sync(queue, ^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"主队列异步1   %@",[NSThread currentThread]);
//        }
//    });
//    dispatch_sync(queue, ^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"主队列异步2   %@",[NSThread currentThread]);
//        }
//    });
//    dispatch_sync(queue, ^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"主队列异步3   %@",[NSThread currentThread]);
//        }
//    });
    
    
    // 异步执行：主队列异步执行按顺序执行，不会开辟新线程
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"主队列异步1   %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"主队列异步2   %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"主队列异步3   %@",[NSThread currentThread]);
        }
    });
}
#pragma mark -- 新建队列中进行同步和异步执行是否开辟新线程
-(void)ShiFoukaipixinxiancheng{
//    // 串行队列
//    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
//
//    // 同步执行：串行同步不会开辟新线程,顺序执行
//    dispatch_sync(queue, ^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"串行同步1   %@",[NSThread currentThread]);
//        }
//    });
//    dispatch_sync(queue, ^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"串行同步2   %@",[NSThread currentThread]);
//        }
//    });
//    dispatch_sync(queue, ^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"串行同步3   %@",[NSThread currentThread]);
//        }
//    });
//
//    // 异步执行：串行异步虽然开辟新线程,但也是顺序执行，用时也和串行同步相同
//    dispatch_async(queue, ^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"串行异步1   %@",[NSThread currentThread]);
//        }
//    });
//    dispatch_async(queue, ^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"串行异步2   %@",[NSThread currentThread]);
//        }
//    });
//    dispatch_async(queue, ^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"串行异步3   %@",[NSThread currentThread]);
//        }
//    });
    
    
    // 并发队列
    dispatch_queue_t queue1 = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
//
//    // 同步执行：并行同步不会开辟新线程,顺序执行
//    dispatch_sync(queue1, ^{
//        for (int i = 0; i < 30; i++) {
//            NSLog(@"并发同步1   %@",[NSThread currentThread]);
//        }
//    });
//    dispatch_sync(queue1, ^{
//        for (int i = 0; i < 30; i++) {
//            NSLog(@"并发同步2   %@",[NSThread currentThread]);
//        }
//    });
//    dispatch_sync(queue1, ^{
//        for (int i = 0; i < 30; i++) {
//            NSLog(@"并发同步3   %@",[NSThread currentThread]);
//        }
//    });
    
    // 异步执行：并行异步不仅开辟新线程,而且每个任务互相独立执行，顺序不定，比同步执行速度要快
    dispatch_async(queue1, ^{
        for (int i = 0; i < 30; i++) {
            NSLog(@"并发异步1   %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue1, ^{
        for (int i = 0; i < 30; i++) {
            NSLog(@"并发异步2   %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue1, ^{
        for (int i = 0; i < 30; i++) {
            NSLog(@"并发异步3   %@",[NSThread currentThread]);
        }
    });
}
#pragma mark -- 线程同步死锁
-(void)tongBuBingFa{
//    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    //操作1
    dispatch_sync(dispatch_get_global_queue(0,0),^{
        //dispatch_get_global_queue默认创建全局并发队列
        //         耗时操作放在这里
        [self xuanZePaiXu];
        NSLog(@"222222222222222222");
        //操作2
        dispatch_sync(dispatch_get_main_queue(),^{
            //              回到主线程进行UI操作
            //操作1和操作2都为同步时下面的所有代码都不会执行，因为同步操作在主队列中添加后要立即执行，而当前方法tongBuBingFa正在主队列中执行，需要等待他执行完毕，而tongBuBingFa每次执行到这里都要停下来等待无法执行完毕，所以卡在这里.
            //当有异步执行存在时不会卡主线程，互相执行不会冲突
            self.view.backgroundColor = [UIColor redColor];
            NSLog(@"111111111111111111");
        });
    });
    
    NSLog(@"3333333333333");
}
-(void)xuanZePaiXu{
    int array[] = {55, 23, 93, 23, 4, 56, 1, 34, 11, 55, 23, 93, 23, 4, 56, 1, 34, 1155, 23, 93, 23, 4, 56, 1, 34, 1155, 23, 93, 23, 4, 56, 1, 34, 11};
    
    int num = sizeof(array)/sizeof(int);
    
    for (int i = 0; i < num - 1; i++) {
        
        for (int j = i + 1; j < num ; j++) {
            
            if (array[i] > array [j]) {
                
                int temp = array[i];
                
                array[i] = array[j];
                
                array[j] = temp;
            }
            
        }
    }
    
    for (int i = 0; i < num; i++) {
        
        printf("%d", array[i]);
        NSLog(@"%d",array[i]);

        if (i == num - 1) {
            
            printf("\n");
            
        } else {
            
            printf(" ");
        }
    }
    
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"//////////////////");
    
}

@end
