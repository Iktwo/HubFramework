#import <XCTest/XCTest.h>

#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBFeatureRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentProviderFactoryMock.h"
#import "HUBContentProviderMock.h"
#import "HUBViewModelLoader.h"
#import "HUBInitialViewModelRegistry.h"

@interface HUBViewModelLoaderFactoryTests : XCTestCase

@property (nonatomic, strong) HUBFeatureRegistryImplementation *featureRegistry;
@property (nonatomic, copy) NSString *defaultComponentNamespace;
@property (nonatomic, strong) HUBViewModelLoaderFactoryImplementation *viewModelLoaderFactory;

@end

@implementation HUBViewModelLoaderFactoryTests

- (void)setUp
{
    [super setUp];
    
    self.featureRegistry = [HUBFeatureRegistryImplementation new];
    self.defaultComponentNamespace = @"default";
    
    HUBJSONSchemaRegistryImplementation * const JSONSchemaRegistry = [[HUBJSONSchemaRegistryImplementation alloc] initWithDefaultComponentNamespace:@"namespace"];
    HUBInitialViewModelRegistry * const initialViewModelRegistry = [HUBInitialViewModelRegistry new];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    
    self.viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:self.featureRegistry
                                                                                        JSONSchemaRegistry:JSONSchemaRegistry
                                                                                  initialViewModelRegistry:initialViewModelRegistry
                                                                                 defaultComponentNamespace:self.defaultComponentNamespace
                                                                                 connectivityStateResolver:connectivityStateResolver];
}

- (void)testCreatingViewModelLoaderForValidViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];

    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    HUBContentProviderFactoryMock * const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[contentProvider]];
    
    [self.featureRegistry registerFeatureWithIdentifier:@"feature"
                                            rootViewURI:viewURI
                               contentProviderFactories:@[contentProviderFactory]
                             customJSONSchemaIdentifier:nil
                                       viewURIQualifier:nil];
    
    XCTAssertTrue([self.viewModelLoaderFactory canCreateViewModelLoaderForViewURI:viewURI]);
    XCTAssertNotNil([self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI]);
}

- (void)testCreatingViewModelLoaderForInvalidViewURIReturnsNil
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:unrecognized"];
    XCTAssertFalse([self.viewModelLoaderFactory canCreateViewModelLoaderForViewURI:viewURI]);
    XCTAssertNil([self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI]);
}

- (void)testNoContentProviderCreatedThrows
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    HUBContentProviderFactoryMock * const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    
    [self.featureRegistry registerFeatureWithIdentifier:@"feature"
                                            rootViewURI:viewURI
                               contentProviderFactories:@[contentProviderFactory]
                             customJSONSchemaIdentifier:nil
                                       viewURIQualifier:nil];
    
    XCTAssertThrows([self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI]);
}

@end
