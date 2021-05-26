# AKYSqlite

<!--[![CI Status](https://img.shields.io/travis/Aikyuichi/AKYSqlite.svg?style=flat)](https://travis-ci.org/Aikyuichi/AKYSqlite)-->
[![Version](https://img.shields.io/cocoapods/v/AKYSqlite.svg?style=flat)](https://cocoapods.org/pods/AKYSqlite)
[![License](https://img.shields.io/cocoapods/l/AKYSqlite.svg?style=flat)](https://cocoapods.org/pods/AKYSqlite)
<!-- [![Platform](https://img.shields.io/cocoapods/p/AKYSqlite.svg?style=flat)](https://cocoapods.org/pods/AKYSqlite) -->

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

AKYSqlite is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AKYSqlite'
```
Import AKYSqlite.h
```Objective-C
#import <AKYSqlite/AKYSqlite.h>
```

### Don't want to use CocoaPods?

Copy files from AKYSqlite/Classes to your project

Import AKYSqlite.h
```Objective-C
#import "AKYSqlite.h"
```
## Usage
```Objective-C
NSString *dbPath = @"/path/to/the/database/file";
AKYDatabase *db = [AKYDatabase databaseAtPath:dbPath];
[db open];
AKYStatement *stmt = [db prepareStatement:@"SELECT name, lastname FROM person WHERE person_id = $id"];
if (stmt != nil) {
    [stmt bindIntegerWithName:@"$id" value:1];
    while ([stmt step]) {
        NSString *name = [stmt getColumnStringWithName:@"name"];
        NSString *lastname = [stmt getColumnStringWithName:@"lastname"];
    }
    [stmt finalize];
}
[db close];
```

## Author

Aikyuichi, aikyu.sama@gmail.com

## License

AKYSqlite is available under the MIT license. See the LICENSE file for more info.