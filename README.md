# cocoapods-develop

cocoapods-develop makes it easy to develop pods without switching workspaces.

## Installation

```bash
$ gem install cocoapods-develop
```

## Usage

Add cocoapods-develop to your Podfile:

```ruby
plugin 'cocoapods-rome'
```

When you want to start development work on one of your project's pod dependencies, add this:

```ruby
pod_develop AwesomePod, '/path/to/project'
```

All subsequent references to `AwesomePod` in the Podfile will then be interpreted as development pods.

In addition, the Xcode project for AwesomePod will be added to your workspace. Because the project will be added to your workspace, the default CocoaPods behavior of sharing the development pod scheme will be overriden.

## Things to remember

If you have the development pod's project open in another workspace, Xcode will complain -- it can't open multiple versions of the same project simultaneously.

Any changes to existing files will be reflected immediately when you build.

If you add or delete files to the development pod, you must re-run `pod install` for those changes to be reflected.