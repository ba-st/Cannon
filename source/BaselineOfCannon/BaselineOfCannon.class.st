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
		for: #common
		do: [ self setUpDependencies: spec.

			spec
				package: 'Cannon-StateMachine' with: [ spec requires: #('Buoy' 'Mole') ];
				package: 'Cannon-Workflow' with: [ spec requires: #('Cannon-StateMachine') ];
				package: 'Cannon-StateMachine-Tests' with: [ spec requires: 'Cannon-StateMachine' ];
				package: 'Cannon-Workflow-Tests' with: [ spec requires: 'Cannon-Workflow' ];
				package: 'Cannon-Willow-Examples' with: [ spec requires: #('Cannon-Workflow-Tests' 'Willow') ].

			spec
				group: 'Deployment' with: #('Cannon-StateMachine' 'Cannon-Workflow');
				group: 'Development' with: #('Cannon-StateMachine-Tests' 'Cannon-Workflow-Tests');
				group: 'Examples' with: #('Cannon-Willow-Examples');
				group: 'default' with: #('Deployment' 'Examples') ]
]

{ #category : #baselines }
BaselineOfCannon >> setUpDependencies: spec [

	spec
		baseline: 'Buoy'
		with: [ spec
				repository: 'github://ba-st/Buoy:v4/source';
				loads: #('Deployment') ].

	spec
		baseline: 'Mole'
		with: [ spec
				repository: 'github://ba-st/Mole:v3/source';
				loads: #('Deployment') ].

	spec
		baseline: 'Willow'
		with: [ spec
				repository: 'github://ba-st/Willow:v10/source';
				loads: #('Willow') ]
]
