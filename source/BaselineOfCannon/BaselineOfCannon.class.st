"
I'm the baseline of Cannon
"
Class {
	#name : #BaselineOfCannon,
	#superclass : #BaselineOf,
	#category : #BaselineOfCannon
}

{ #category : #baselines }
BaselineOfCannon >> baseline: spec [

	<baseline>
	spec
		for: #pharo
		do: [ self
				setUpDependencies: spec;
				baselineStateMachine: spec;
				baselineExamples: spec.
			spec
				group: 'CI' with: 'Tests';
				group: 'Development' with: #('Tests' 'Buoy-Tools')
			]
]

{ #category : #private }
BaselineOfCannon >> baselineExamples: spec [

	spec
		package: 'Cannon-Willow-Examples' with: [ spec requires: #('Tests' 'Willow-Deployment') ];
		group: 'Examples' with: 'Cannon-Willow-Examples'
]

{ #category : #private }
BaselineOfCannon >> baselineStateMachine: spec [

	spec
		package: 'Cannon-StateMachine' with: [ spec requires: #('Grease' 'Buoy-Deployment') ];
		group: 'Deployment' with: 'Cannon-StateMachine';
		package: 'Cannon-StateMachine-Tests' with: [ spec requires: #('Cannon-StateMachine' 'Buoy-SUnit') ];
		group: 'Tests' with: 'Cannon-StateMachine-Tests'
]

{ #category : #accessing }
BaselineOfCannon >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : #private }
BaselineOfCannon >> setUpDependencies: spec [

	spec
		baseline: 'Grease'
		with: [ spec
				repository: 'github://SeasideSt/Grease:v1.7.x/repository';
				loads: #('Grease-Core')
			].

	spec
		baseline: 'Buoy' with: [ spec repository: 'github://ba-st/Buoy:v6' ];
		project: 'Buoy-Deployment' copyFrom: 'Buoy' with: [ spec loads: 'Deployment' ];
		project: 'Buoy-SUnit' copyFrom: 'Buoy' with: [ spec loads: 'Dependent-SUnit-Extensions' ];
		project: 'Buoy-Tools' copyFrom: 'Buoy' with: [ spec loads: 'Tools' ].

	spec
		baseline: 'Willow' with: [ spec repository: 'github://ba-st/Willow:v14' ];
		project: 'Willow-Deployment' copyFrom: 'Willow' with: [ spec loads: 'Deployment' ]
]
