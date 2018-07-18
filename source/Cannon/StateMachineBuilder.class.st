"
A builder to help with the creation of state machines.
"
Class {
	#name : #StateMachineBuilder,
	#superclass : #Object,
	#instVars : [
		'contextBuilder',
		'states',
		'transitions',
		'initialStateNameOptional'
	],
	#category : #Cannon
}

{ #category : #'instance creation' }
StateMachineBuilder class >> buildingContextWith: aContextBuilder [

	^ self new initializeBuildingContextWith: aContextBuilder
]

{ #category : #configuring }
StateMachineBuilder >> addStateNamed: aName [

	self addStateNamed: aName onEntry: [  ] onExit: [  ]
]

{ #category : #configuring }
StateMachineBuilder >> addStateNamed: aName onEntry: anEntryBlock onExit: anExitBlock [

	states add: (StateSpecification named: aName onEntry: anEntryBlock onExit: anExitBlock)
]

{ #category : #configuring }
StateMachineBuilder >> addTransitionFrom: aSourceStateName to: aDestinationStateName [

	self
		addTransitionFrom: aSourceStateName
		to: aDestinationStateName
		allowedWhen: (CompositeCondition satisfyingAll: #())
		doing: [  ]
		triggeredBy: ManualTransitionTrigger new
]

{ #category : #configuring }
StateMachineBuilder >> addTransitionFrom: aSourceStateName to: aDestinationStateName allowedWhen: aConditionBlock doing: anAction triggeredBy: aTrigger [

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
StateMachineBuilder >> addTransitionNamed: aName from: aSourceStateName to: aDestinationStateName [

	self
		addTransitionNamed: aName
		from: aSourceStateName
		to: aDestinationStateName
		allowedWhen: (CompositeCondition satisfyingAll: #())
		doing: [  ]
		triggeredBy: ManualTransitionTrigger new
]

{ #category : #configuring }
StateMachineBuilder >> addTransitionNamed: aName from: aSourceStateName to: aDestinationStateName allowedWhen: aConditionBlock doing: anAction triggeredBy: aTrigger [

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
StateMachineBuilder >> build [

	| initialState |

	initialState := self initialState.

	^ StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: initialState
		buildingContextWith: contextBuilder
]

{ #category : #configuring }
StateMachineBuilder >> declareAsInitialState: aStateName [

	initialStateNameOptional := Optional containing: aStateName
]

{ #category : #'private - accessing' }
StateMachineBuilder >> initialState [

	^ initialStateNameOptional
		withContentDo: [ :initialStateName | self onlyStateNamed: initialStateName ]
		ifUnused: [ self onlyState ]
]

{ #category : #initialization }
StateMachineBuilder >> initializeBuildingContextWith: aContextBuilder [

	contextBuilder := aContextBuilder.
	states := Set new.
	transitions := Set new.
	initialStateNameOptional := Optional unused
]

{ #category : #'private - accessing' }
StateMachineBuilder >> onlyState [

	AssertionChecker
		enforce: [ states size = 1 ]
		because: 'More than one state defined and no initial state name was indicated.'
		raising: InstanceCreationFailed.
	^ states anyOne
]

{ #category : #'private - accessing' }
StateMachineBuilder >> onlyStateNamed: initialStateName [

	| candidates |

	candidates := states select: [ :state | state name = initialStateName ].
	AssertionChecker
		enforce: [ candidates size = 1 ]
		because: ('Couldn''t find a single state named <1s>.' expandMacrosWith: initialStateName)
		raising: InstanceCreationFailed.
	^ candidates anyOne
]
