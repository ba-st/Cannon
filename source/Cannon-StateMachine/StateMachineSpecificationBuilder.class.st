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
	#category : #'Cannon-StateMachine'
}

{ #category : #configuring }
StateMachineSpecificationBuilder >> addStateNamed: aName [

	self addStateNamed: aName onEntry: [  ] onExit: [  ]
]

{ #category : #configuring }
StateMachineSpecificationBuilder >> addStateNamed: aName onEntry: anEntryBlock onExit: anExitBlock [

	states add: (MachineState named: aName onEntry: anEntryBlock onExit: anExitBlock)
]

{ #category : #configuring }
StateMachineSpecificationBuilder >> addTransitionNamed: aName fromStateNamed: aSourceStateName toStateNamed: aDestinationStateName [

	self
		addTransitionNamed: aName
		fromStateNamed: aSourceStateName
		toStateNamed: aDestinationStateName
		allowedWhen: (CompositeCondition satisfyingAll: #())
		completedUsing: [  ]
		triggeredBy: ManualTransitionTrigger new
]

{ #category : #configuring }
StateMachineSpecificationBuilder >> addTransitionNamed: aName fromStateNamed: aSourceStateName toStateNamed: aDestinationStateName allowedWhen: aCondition completedUsing: anAction triggeredBy: aTrigger [

	self
		addTransitionNamed: aName
		fromStateNamed: aSourceStateName
		toStateNamed: aDestinationStateName
		allowedWhen: aCondition
		startedUsing: [ :context :actionWhenCompleted | 
			anAction cull: context.
			actionWhenCompleted value ]
		triggeredBy: aTrigger
]

{ #category : #configuring }
StateMachineSpecificationBuilder >> addTransitionNamed: aName fromStateNamed: aSourceStateName toStateNamed: aDestinationStateName allowedWhen: aCondition startedUsing: anAction triggeredBy: aTrigger [

	| transition sourceState destinationState |

	sourceState := self onlyStateNamed: aSourceStateName.
	destinationState := self onlyStateNamed: aDestinationStateName.
	transition := MachineTransition
		named: aName
		from: sourceState
		to: destinationState
		allowedWhen: aCondition
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

{ #category : #'private - accessing' }
StateMachineSpecificationBuilder >> initialState [

	^ initialStateNameOptional
		withContentDo: [ :initialStateName | self onlyStateNamed: initialStateName ]
		ifUnused: [ self onlyState ]
]

{ #category : #initialization }
StateMachineSpecificationBuilder >> initialize [

	super initialize.
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

{ #category : #configuring }
StateMachineSpecificationBuilder >> startFromStateNamed: aStateName [

	initialStateNameOptional := Optional containing: aStateName
]
