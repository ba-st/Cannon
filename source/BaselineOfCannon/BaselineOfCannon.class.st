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
				package: 'Cannon-StateMachine' with: [ spec requires: #('Grease' 'Buoy') ];
				package: 'Cannon-StateMachine-Tests' with: [ spec requires: 'Cannon-StateMachine' ];
				package: 'Cannon-Willow-Examples'
					with: [ spec requires: #('Cannon-StateMachine-Tests' 'Willow') ].

			spec
				group: 'Deployment' with: #('Cannon-StateMachine');
				group: 'Development' with: #('Cannon-StateMachine-Tests');
				group: 'Examples' with: #('Cannon-Willow-Examples');
				group: 'default' with: #('Deployment') ]
]

{ #category : #baselines }
BaselineOfCannon >> setUpDependencies: spec [

	spec
		baseline: 'Grease'
		with: [ spec
				repository: 'github://SeasideSt/Grease:v1.3.5/repository';
				loads: #('Grease-Core') ].
			
	spec
		baseline: 'Buoy'
		with: [ spec
				repository: 'github://ba-st/Buoy:v4/source';
				loads: #('Deployment') ].

	spec
		baseline: 'Willow'
		with: [ spec
				repository: 'github://ba-st/Willow:v10/source';
				loads: #('Willow') ]
]
