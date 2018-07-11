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
		do: [
			self setUpDependencies: spec.

			spec
				package: 'Cannon' with: [ spec requires: #('Buoy' 'Mole') ];
				package: 'Cannon-Tests' with: [ spec requires: 'Cannon' ].

			spec
				group: 'Deployment' with: #('Cannon');
				group: 'Development' with: #('Cannon-Tests');
				group: 'default' with: #('Deployment') ]
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
]
