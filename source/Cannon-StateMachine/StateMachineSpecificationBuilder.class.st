"
A builder to help with the creation of state machines.
"
Class {
	#name : #StateMachineSpecificationBuilder,
	#superclass : #Object,
	#instVars : [
		'states',
		'transitions',
		'initialStateNameOptional'
	],
	#category : #'Cannon-StateMachine-Cannon-StateMachine'
}

{ #category : #configuring }
StateMachineSpecificationBuilder >> addStateNamed: aName [

	self addStateNamed: aName onEntry: [  ] onExit: [  ]
]

{ #category : #configuring }
StateMachineSpecificationBuilder >> addStateNamed: aName onEntry: anEntryBlock onExit: anExitBlock [

	states add: (StateSpecification named: aName onEntry: anEntryBlock onExit: anExitBlock)
]

{ #category : #configuring }
StateMachineSpecificationBuilder >> addTransitionFrom: aSourceStateName to: aDestinationStateName [

	self
		addTransitionFrom: aSourceStateName
		to: aDestinationStateName
		allowedWhen: (CompositeCondition satisfyingAll: #())
		doing: [  ]
		triggeredBy: ManualTransitionTrigger new
]

{ #category : #configuring }
StateMachineSpecificationBuilder >> addTransitionFrom: aSourceStateName to: aDestinationStateName allowedWhen: aConditionBlock doing: anAction triggeredBy: aTrigger [

	| transition sourceState destinationState |

	sourceState := self onlyStateNamed: aSourceStateName.
	destinationState := self onlyStateNamed: aDestinationStateName.
	transition := TransitionSpecification
		unnamedFrom: sourceState
		to: destinationState
		allowedWhen: aConditionBlock
		doing: anAction
		triggeredBy: aTrigger.
	transitions add: transition
]

{ #category : #configuring }
StateMachineSpecificationBuilder >> addTransitionNamed: aName from: aSourceStateName to: aDestinationStateName [

	self
		addTransitionNamed: aName
		from: aSourceStateName
		to: aDestinationStateName
		allowedWhen: (CompositeCondition satisfyingAll: #())
		doing: [  ]
		triggeredBy: ManualTransitionTrigger new
]

{ #category : #configuring }
StateMachineSpecificationBuilder >> addTransitionNamed: aName from: aSourceStateName to: aDestinationStateName allowedWhen: aConditionBlock doing: anAction triggeredBy: aTrigger [

	| transition sourceState destinationState |

	sourceState := self onlyStateNamed: aSourceStateName.
	destinationState := self onlyStateNamed: aDestinationStateName.
	transition := TransitionSpecification
		named: aName
		from: sourceState
		to: destinationState
		allowedWhen: aConditionBlock
		doing: anAction
		triggeredBy: aTrigger.
	transitions add: transition
]

{ #category : #building }
StateMachineSpecificationBuilder >> build [

	| initialState |

	initialState := self initialState.

	^ StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: initialState
]

{ #category : #configuring }
StateMachineSpecificationBuilder >> declareAsInitialState: aStateName [

	initialStateNameOptional := Optional containing: aStateName
]

{ #category : #'private - accessing' }
StateMachineSpecificationBuilder >> initialState [

	^ initialStateNameOptional
		withContentDo: [ :initialStateName | self onlyStateNamed: initialStateName ]
		ifUnused: [ self onlyState ]
]

{ #category : #initialization }
StateMachineSpecificationBuilder >> initialize [

	states := Set new.
	transitions := Set new.
	initialStateNameOptional := Optional unused
]

{ #category : #'private - accessing' }
StateMachineSpecificationBuilder >> onlyState [

	AssertionChecker
		enforce: [ states size = 1 ]
		because: 'More than one state defined and no initial state name was indicated.'
		raising: InstanceCreationFailed.
	^ states anyOne
]

{ #category : #'private - accessing' }
StateMachineSpecificationBuilder >> onlyStateNamed: initialStateName [

	| candidates |

	candidates := states select: [ :state | state name = initialStateName ].
	AssertionChecker
		enforce: [ candidates size = 1 ]
		because: ('Couldn''t find a single state named <1s>.' expandMacrosWith: initialStateName)
		raising: InstanceCreationFailed.
	^ candidates anyOne
]
