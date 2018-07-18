"
A StateMachineSpecificationTest is a test class for testing the behavior of StateMachineSpecification
"
Class {
	#name : #StateMachineSpecificationTest,
	#superclass : #TestCase,
	#category : #'Cannon-Tests'
}

{ #category : #'private - accessing' }
StateMachineSpecificationTest >> stateNamed: aName [

	^ StateSpecification named: aName onEntry: [  ] onExit: [  ]
]

{ #category : #tests }
StateMachineSpecificationTest >> testInitialStateMustBeSourceOfSomeTransition [

	| states transitions |

	states := OrderedCollection
		with: (self stateNamed: 'a')
		with: (self stateNamed: 'b')
		with: (self stateNamed: 'c').
	transitions := OrderedCollection
		with: (self transitionFrom: states first to: states second).

	self
		should: [ StateMachineSpecification
				transitioningThrough: transitions
				startingFrom: states last
				buildingContextWith: StateMachineContextExample ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: 'The initial state (c) must be source of at least one of the transitions.' ].

	self
		should: [ StateMachineSpecification
				transitioningThrough: transitions
				startingFrom: states second
				buildingContextWith: StateMachineContextExample ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: 'The initial state (b) must be source of at least one of the transitions.' ]
]

{ #category : #tests }
StateMachineSpecificationTest >> testRepeatedStateNamesAreNotAllowed [

	| states transitions |

	states := OrderedCollection
		with: (self stateNamed: 'c')
		with: (self stateNamed: 'c')
		with: (self stateNamed: 'a')
		with: (self stateNamed: 'a')
		with: (self stateNamed: 'b').
	transitions := OrderedCollection new.
	states allButLast
		with: states allButFirst
		do: [ :source :destination | transitions add: (self transitionFrom: source to: destination) ].
	self
		should: [ StateMachineSpecification
				transitioningThrough: transitions
				startingFrom: states first
				buildingContextWith: StateMachineContextExample ]
		raise: InstanceCreationFailed
		withExceptionDo:
			[ :exception | self assert: exception messageText equals: 'State names can''t be repeated (a, c).' ]
]

{ #category : #tests }
StateMachineSpecificationTest >> testRepeatedTransitionsAreNotAllowed [

	| states transitions |

	states := OrderedCollection
		with: (self stateNamed: 'a')
		with: (self stateNamed: 'b')
		with: (self stateNamed: 'c').
	transitions := OrderedCollection
		with: (self transitionNamed: 'repeater' from: states first to: states second)
		with: (self transitionNamed: 'duplicated' from: states second to: states last)
		with: (self transitionNamed: 'singular' from: states second to: states last)
		with: (self transitionNamed: 'duplicated' from: states second to: states last)
		with: (self transitionNamed: 'repeater' from: states second to: states first).
	self
		should: [ StateMachineSpecification
				transitioningThrough: transitions
				startingFrom: states first
				buildingContextWith: StateMachineContextExample ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: 'Transitions can''t be repeated (duplicated:b-->c).' ]
]

{ #category : #tests }
StateMachineSpecificationTest >> testTransitioningThroughStartingFromBuildingContextWith [

	| states transitions machine |

	states := OrderedCollection with: (self stateNamed: 'a') with: (self stateNamed: 'b').
	transitions := OrderedCollection
		with: (self transitionFrom: states first to: states last)
		with: (self transitionFrom: states last to: states first).
	machine := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first
		buildingContextWith: StateMachineContextExample.

	self
		assert: machine initialState equals: states first;
		assertCollection: (machine transitionsFrom: states first allowedWithin: self)
			equals: transitions allButLast;
		assertCollection: (machine transitionsFrom: states last allowedWithin: self)
			equals: transitions allButFirst;
		assert: machine contextBuilder equals: StateMachineContextExample
]

{ #category : #'private - accessing' }
StateMachineSpecificationTest >> transitionFrom: aSource to: aTarget [

	^ TransitionSpecification
		unnamedFrom: aSource
		to: aTarget
		allowedWhen: (CompositeCondition satisfyingAll: #())
		doing: [  ]
		triggeredBy: ManualTransitionTrigger new
]

{ #category : #'private - accessing' }
StateMachineSpecificationTest >> transitionNamed: aName from: aSource to: aTarget [

	^ TransitionSpecification
		named: aName
		from: aSource
		to: aTarget
		allowedWhen: (CompositeCondition satisfyingAll: #())
		doing: [  ]
		triggeredBy: ManualTransitionTrigger new
]