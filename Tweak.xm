#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>

// Объявляем методы SBUIController, которые будем использовать
@interface SBUIController : NSObject
+ (id)sharedInstance;
- (void)clickedMenuButton;      // Эмуляция нажатия кнопки "Домой" (выход на рабочий стол)
- (void)handleMenuDoubleTap;    // Эмуляция двойного нажатия (переключатель задач)
@end

// Объявляем метод для открытия Центра управления (может отличаться в зависимости от iOS)
@interface SBControlCenterController : NSObject
+ (id)sharedInstance;
- (void)presentAnimated:(BOOL)animated;
@end

%hook SBUIController

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    %orig;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window) return;
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    // --- 1. Нижняя зона для жестов "Домой" и "Переключатель задач" ---
    UIView *bottomGestureView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - 30, screenWidth, 30)];
    bottomGestureView.backgroundColor = [UIColor clearColor];
    bottomGestureView.userInteractionEnabled = YES;
    
    // Свайп вверх для выхода на рабочий стол
    UISwipeGestureRecognizer *swipeUpHome = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpHome:)];
    swipeUpHome.direction = UISwipeGestureRecognizerDirectionUp;
    [bottomGestureView addGestureRecognizer:swipeUpHome];
    
    // Свайп вверх с задержкой (эмуляция долгого свайпа) для переключателя задач
    UILongPressGestureRecognizer *longPressSwipeUp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressSwipeUp:)];
    longPressSwipeUp.minimumPressDuration = 0.5; // Задержка 0.5 секунды
    [bottomGestureView addGestureRecognizer:longPressSwipeUp];
    
    [window addSubview:bottomGestureView];
    
    // --- 2. Верхняя зона для открытия Центра управления ---
    UIView *topGestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
    topGestureView.backgroundColor = [UIColor clearColor];
    topGestureView.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *swipeDownCC = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownControlCenter:)];
    swipeDownCC.direction = UISwipeGestureRecognizerDirectionDown;
    [topGestureView addGestureRecognizer:swipeDownCC];
    
    [window addSubview:topGestureView];
    
    // --- 3. Визуальная полоска Home Bar внизу экрана ---
    UIView *homeBar = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2 - 50, screenHeight - 8, 100, 4)];
    homeBar.backgroundColor = [UIColor whiteColor];
    homeBar.alpha = 0.5;
    homeBar.layer.cornerRadius = 2;
    [window addSubview:homeBar];
}

// Обработчик свайпа вверх (выход на рабочий стол)
- (void)handleSwipeUpHome:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [[%c(SBUIController) sharedInstance] clickedMenuButton];
    }
}

// Обработчик долгого свайпа вверх (переключатель задач)
- (void)handleLongPressSwipeUp:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [[%c(SBUIController) sharedInstance] handleMenuDoubleTap];
    }
}

// Обработчик свайпа вниз сверху (Центр управления)
- (void)handleSwipeDownControlCenter:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // Пытаемся открыть Центр управления
        // Метод может отличаться в зависимости от версии iOS
        Class ccClass = objc_getClass("SBControlCenterController");
        if (ccClass) {
            id ccController = [ccClass sharedInstance];
            if ([ccController respondsToSelector:@selector(presentAnimated:)]) {
                [ccController presentAnimated:YES];
            }
        }
    }
}

%end
