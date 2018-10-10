//
//  ViewController.m
//  NSOperation学习
//
//  Created by shoule on 2018/8/9.
//  Copyright © 2018年 yqs. All rights reserved.
//


//https://www.jianshu.com/p/4b1d77054b35
//NSOperation是基于GCD之上的更高一层封装，NSOperation需要配合NSOperationQueue来实现多线程。
// 实现方式
//1. 创建任务：先将需要执行的操作封装到NSOperation对象中。
//2. 创建队列：创建NSOperationQueue。
//3. 将任务加入到队列中：将NSOperation对象添加到NSOperationQueue中。
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
-(void)clickButton{
//    ///创建一个NSInvocationOperation任务
//    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(invocationOperation:) object:@"我是你"];
//    [operation start];
//    创建一个NSBlockOperation任务
    [self testNSBlockOperationExecution];
//    NSOperation + NSOperationQueue的基本结合使用
//    [self testOperationQueue];
//    NSOperation的操作依赖
//    [self testAddDependency];
}
#pragma mark -- NSOperation的操作依赖
//NSOperation有一个非常好用的方法，就是操作依赖。可以从字面意思理解：某一个操作（operation2）依赖于另一个操作（operation1），只有当operation1执行完毕，才能执行operation2。
- (void)testAddDependency {
    // 并发队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperationAddOperation:) object:nil];
    // 操作1
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"operation1======%@", [NSThread  currentThread]);
        }
    }];
    
    // 操作2
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
//        NSLog(@"****operation2依赖于operation1，只有当operation1执行完毕，operation2才会执行****");
        for (int i = 0; i < 3; i++) {
            NSLog(@"operation2======%@", [NSThread  currentThread]);
        }
    }];
    
    // 使操作2依赖于操作1
    [operation2 addDependency:operation1];
    
//    [operation1 addDependency:invocationOperation];
    // 把操作加入队列
    [queue addOperation:operation1];
    [queue addOperation:operation2];
//    [queue addOperation:invocationOperation];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.view.backgroundColor = [UIColor greenColor];
        ///等待queue队列中的事情全部执行完毕才向下执行
        [queue waitUntilAllOperationsAreFinished];
        NSLog(@"111111111111111");
    });
    NSLog(@"222222222222222");
}


#pragma mark -- NSOperation + NSOperationQueue的基本结合使用
- (void)testOperationQueue {
    // 创建队列，默认并发
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //maxConcurrentOperationCount最大并发数，默认-1，系统默认有最大上限
    ///maxConcurrentOperationCount = 1为串行操作
    queue.maxConcurrentOperationCount = -1;
    // 创建操作，NSInvocationOperation
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperationAddOperation:) object:nil];
    // 创建操作，NSBlockOperation
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        ///默认开启新线程
        
        for (int i = 0; i < 3; i++) {
            NSLog(@"%d------队列======%@", i,[NSThread currentThread]);
        }
        
        [NSThread sleepForTimeInterval:2.f];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.backgroundColor = [UIColor grayColor];
        });
    }];
//    queuePriority代表优先级,优先级不会影响依赖关系
    //在同一队列中的任务,处于准备就绪状态下的任务,优先级高的先执行
    blockOperation.queuePriority = NSOperationQueuePriorityLow;
    //加入队列默认开启
    
    //暂停队列在它上面的会继续执行下面的不再执行
//    暂停和取消不是立刻取消当前操作，而是等当前的操作执行完之后不再进行新的操作。
//    暂停当前队列
//    [queue setSuspended:YES];
//    取消invocationOperation操作
//        [invocationOperation cancel];

    [queue addOperation:blockOperation];
    [queue addOperation:invocationOperation];

//    另一种添加操作
    // 添加操作到队列
//    [queue addOperationWithBlock:^{
//        ///默认开启新线程
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"%d------队列======%@", i,[NSThread currentThread]);
//        }
//    }];
}


- (void)invocationOperationAddOperation:(NSInvocationOperation*)invocationOperation {
    [invocationOperation cancel];
    for (int i = 0; i<200; i++) {
        
        NSLog(@"11111111111111");
    }
    NSLog(@"把任务添加到队列====%@", [NSThread currentThread]);
}
#pragma mark -- 创建一个NSBlockOperation任务
-(void)testNSBlockOperationExecution{
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i<200; i++) {
            NSLog(@"11111111111111");
        }
        
        NSLog(@"主任务========%@", [NSThread currentThread]);
    }];
    ///当使用addExecutionBlock方法时主线程在忙开辟分线程，主线程空闲时会在主线程中执行block中的方法
    [blockOperation addExecutionBlock:^{
        NSLog(@"任务1========%@", [NSThread currentThread]);
        ///为什么分线程中过一段时间也能改变背景颜色？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
        
        self.view.backgroundColor = [UIColor redColor];
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"任务2========%@", [NSThread currentThread]);
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"任务3========%@", [NSThread currentThread]);
    }];
    [blockOperation start];
}
-(void)invocationOperation:(id)str{
    NSLog(@"%@",str);
    NSLog(@"========%@", [NSThread currentThread]);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
