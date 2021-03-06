#import "FDInfiniteTableView.h"
#import "UIView+Layout.h"


#pragma mark Constants


#pragma mark - Class Extension

@interface FDInfiniteTableView ()

- (void)_initializeInfiniteTableView;


@end


#pragma mark - Class Definition

@implementation FDInfiniteTableView
{
//	@private __weak id<FDInfiniteTableViewDataSource> _infiniteTableViewDataSource;
	
	@private __strong UIView *_loadingView;
	@private __strong UIView *_loadingViewContainer;
	@private __strong UIActivityIndicatorView *_activityIndicatorView;
	
	@private BOOL _loadingData;
}


#pragma mark - Properties

@dynamic dataSource;

//-(void)setDataSource: (id<FDInfiniteTableViewDataSource>)dataSource
//{
//	super.dataSource = dataSource;
//	
//	_infiniteTableViewDataSource = dataSource;
//}
//- (id<FDInfiniteTableViewDataSource>)dataSource
//{
//	return _infiniteTableViewDataSource;
//}


#pragma mark - Constructors

- (id)initWithFrame: (CGRect)frame
{
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: frame]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeInfiniteTableView];
	
	// Return initialized instance.
	return self;
}

- (id)initWithCoder: (NSCoder *)coder
{
	// Abort if base initializer fails.
	if ((self = [super initWithCoder: coder]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeInfiniteTableView];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

- (void)showLoadingView
{
	_loadingData = YES;
	
	_loadingView.alpha = 1.0f;
	
	[_activityIndicatorView startAnimating];
}

- (void)doneLoading
{
	if (_loadingData == NO)
	{
		return;
	}
	
	[UIView animateWithDuration: 0.33 
		delay: 0.0  
		options: UIViewAnimationOptionCurveEaseInOut 
		animations: ^
		{
			_loadingView.alpha = 0.0f;
		} 
		completion: ^(BOOL finished)
		{
			_loadingData = NO;
			
			[_activityIndicatorView stopAnimating];
		}];
}


#pragma mark - Overridden Methods

- (void)layoutSubviews
{
	_loadingView.width = _loadingViewContainer.width;
	_loadingView.height = _loadingViewContainer.height;
	
	// Call base implementation.
	[super layoutSubviews];
	
	if (_loadingData == NO 
		&& [self isDragging] == YES 
		&& self.contentOffset.y + self.height > self.contentSize.height - _loadingView.height)
	{
		if ([self.dataSource canLoadDataForInfiniteTableView: self] == YES)
		{
			[self showLoadingView];
			
			[self.dataSource loadDataForInfiniteTableView: self];
		}
		else
		{
			_loadingView.alpha = 0.0f;
		}
	}
}

- (void)setTableFooterView: (UIView *)tableFooterView
{
	[NSException raise: NSInternalInconsistencyException 
		format: @"tableFooterView cannot be set on FDInfiniteTableView. It is used to display the loading view.\n%s", 
			__PRETTY_FUNCTION__];
}


#pragma mark - Private Methods

- (void)_initializeInfiniteTableView
{
	// Initialize instance variables.
	_loadingView = [[UIView alloc] 
		initWithFrame: CGRectMake(
			0.0f, 
			0.0f, 
			self.width, 
			40.0f)];
	_loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth 
		| UIViewAutoresizingFlexibleHeight;
	
	_loadingViewContainer = [[UIView alloc] 
		initWithFrame: CGRectMake(
			0.0f, 
			0.0f, 
			_loadingView.width, 
			_loadingView.height)];
	
	_activityIndicatorView = [[UIActivityIndicatorView alloc] 
		initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
	_activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin 
		| UIViewAutoresizingFlexibleTopMargin 
		| UIViewAutoresizingFlexibleRightMargin 
		| UIViewAutoresizingFlexibleBottomMargin;
	
	[_loadingView addSubview: _activityIndicatorView];
	[_activityIndicatorView alignHorizontally: UIViewHorizontalAlignmentCenter 
		vertically: UIViewVerticalAlignmentMiddle];
	
	[_loadingViewContainer addSubview:_loadingView];
	
	super.tableFooterView = _loadingViewContainer;
}


@end