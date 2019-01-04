# Installation

## Basic Installation

You can load **Cannon** evaluating:
```smalltalk
Metacello new
	baseline: 'Cannon';
	repository: 'github://ba-st/Cannon:release-candidate/source';
	load.
```
>  Change `release-candidate` to some released version if you want a pinned version

## Using as dependency

In order to include **Cannon** as part of your project, you should reference the package in your product baseline:

```smalltalk
setUpDependencies: spec

	spec
		baseline: 'Cannon'
			with: [ spec
				repository: 'github://ba-st/Cannon:v{XX}/source';
				loads: #('Deployment') ];
		import: 'Cannon'.
```
> Replace `{XX}` with the version you want to depend on

```smalltalk
baseline: spec

	<baseline>
	spec
		for: #common
		do: [ self setUpDependencies: spec.
			spec package: 'My-Package' with: [ spec requires: #('Cannon') ] ]
```
