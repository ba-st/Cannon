"
A StateMachineBuilderTest is a test class for testing the behavior of StateMachineBuilder
"
Class {
	#name : #StateMachineSpecificationBuilderTest,
	#superclass : #TestCase,
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #'private - processing' }
StateMachineSpecificationBuilderTest >> applyOnlyTransitionOf: machine writingTo: aStream [

	| candidates |

	candidates := (self transitionsFromInitialStateOf: machine) any.

	(TransitionStarter within: StateMachineSpecificationContextExample new for: machine)
		start: candidates
		whenComplete: [ aStream
				nextPutAll: 'Done';
				cr ]
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAddStateNamed [

	| builder machine |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addTransitionNamed: 'Tester' fromStateNamed: 'A' toStateNamed: 'A'.
	machine := builder build.

	self assert: machine initialState name equals: 'A'
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAddStateNamedOnEntryOnExit [

	| builder machine stream |

	stream := WriteStream on: String new.
	builder := StateMachineSpecificationBuilder new.
	builder
		addStateNamed: 'A'
		onEntry: [ stream
				nextPutAll: 'Entering';
				cr ]
		onExit: [ stream
				nextPutAll: 'Exiting';
				cr ].
	builder addTransitionNamed: 'Tester' fromStateNamed: 'A' toStateNamed: 'A'.
	machine := builder build.

	self assert: machine initialState name equals: 'A'.

	self assert: stream contents isEmpty.
	self applyOnlyTransitionOf: machine writingTo: stream.
	self assert: stream contents equals: 'Exiting<r>Entering<r>Done<r>' expandMacros
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAddTransitionNamedFromStateNamedToStateNamed [

	| builder machine transitions stream |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addTransitionNamed: 'only' fromStateNamed: 'A' toStateNamed: 'B'.
	builder startFromStateNamed: 'A'.
	machine := builder build.

	transitions := self transitionsFromInitialStateOf: machine.
	self
		assert: transitions size equals: 1;
		assert: transitions any source name equals: 'A';
		assert: transitions any destination name equals: 'B'.

	stream := WriteStream on: String new.
	stream nextPutAll: transitions any name.
	self assert: stream contents equals: 'only'
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAddTransitionNamedFromStateNamedToStateNamedAllowedWhenCompletedUsingTriggeredBy [

	| builder machine transitions stream |

	stream := WriteStream on: String new.
	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addStateNamed: 'C'.
	builder
		addTransitionNamed: 'Manual'
		fromStateNamed: 'A'
		toStateNamed: 'B'
		allowedWhen: (TransitionConditionExample readingFrom: stream)
		completedUsing: [ stream
				nextPutAll: 'Manual';
				cr ]
		triggeredBy: ManualTransitionTrigger new.
	builder startFromStateNamed: 'A'.
	machine := builder build.

	self assert: (self transitionsFromInitialStateOf: machine) isEmpty.

	stream
		nextPutAll: 'Ready';
		cr.
	transitions := self transitionsFromInitialStateOf: machine.
	self
		assert: transitions size equals: 1;
		assert: transitions any source name equals: 'A';
		assert: transitions any destination name equals: 'B'.

	self applyOnlyTransitionOf: machine writingTo: stream.
	self assert: stream contents equals: 'Ready<r>Manual<r>Done<r>' expandMacros
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAddTransitionNamedFromStateNamedToStateNamedAllowedWhenStartedUsingTriggeredBy [

	| builder machine transitions stream |

	stream := WriteStream on: String new.
	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addStateNamed: 'C'.
	builder
		addTransitionNamed: 'Manual'
		fromStateNamed: 'A'
		toStateNamed: 'B'
		allowedWhen: (TransitionConditionExample readingFrom: stream)
		startedUsing: [ :context :completeBlock | 
			stream
				nextPutAll: 'Manual';
				cr.
			completeBlock value ]
		triggeredBy: ManualTransitionTrigger new.
	builder startFromStateNamed: 'A'.
	machine := builder build.

	self assert: (self transitionsFromInitialStateOf: machine) isEmpty.

	stream
		nextPutAll: 'Ready';
		cr.
	transitions := self transitionsFromInitialStateOf: machine.
	self
		assert: transitions size equals: 1;
		assert: transitions any source name equals: 'A';
		assert: transitions any destination name equals: 'B'.

	self applyOnlyTransitionOf: machine writingTo: stream.
	self assert: stream contents equals: 'Ready<r>Manual<r>Done<r>' expandMacros
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAtLeastOneTransitionMustBeDefined [

	| builder |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.

	self
		should: [ builder build ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :error | 
			self
				assert: error messageText
				equals: 'The initial state (A) must be source of at least one of the transitions.' ]
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testInitialStateMustBeDefinedFirst [

	| builder |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.

	self
		should: [ builder addTransitionNamed: 'Tester' fromStateNamed: 'A' toStateNamed: 'B' ]
		raise: InstanceCreationFailed
		withExceptionDo:
			[ :error | self assert: error messageText equals: 'Couldn''t find a single state named B.' ]
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testStatesInTransitionsMustBeDefined [

	| builder |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder startFromStateNamed: 'B'.

	self
		should: [ builder build ]
		raise: InstanceCreationFailed
		withExceptionDo:
			[ :error | self assert: error messageText equals: 'Couldn''t find a single state named B.' ]
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testThreeStatesAndTwoTransitions [

	| builder machine transitions |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addTransitionNamed: 'Tester' fromStateNamed: 'A' toStateNamed: 'B'.
	builder addStateNamed: 'C'.
	builder addTransitionNamed: 'Tester' fromStateNamed: 'B' toStateNamed: 'C'.
	builder startFromStateNamed: 'A'.
	machine := builder build.

	self assert: machine initialState name equals: 'A'.

	transitions := machine
		transitionsFrom: machine initialState
		allowedWithin: StateMachineSpecificationContextExample new.
	self
		assert: transitions size equals: 1;
		assert: transitions any source name equals: 'A';
		assert: transitions any destination name equals: 'B'.

	transitions := machine
		transitionsFrom: transitions any destination
		allowedWithin: StateMachineSpecificationContextExample new.
	self
		assert: transitions size equals: 1;
		assert: transitions any source name equals: 'B';
		assert: transitions any destination name equals: 'C'
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testWithMoreThanOneStateTheInitialStateMustBeDefined [

	| builder |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addTransitionNamed: 'Tester' fromStateNamed: 'A' toStateNamed: 'B'.

	self
		should: [ builder build ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :error | 
			self
				assert: error messageText
				equals: 'More than one state defined and no initial state name was indicated.' ]
]

{ #category : #'private - processing' }
StateMachineSpecificationBuilderTest >> transitionsFromInitialStateOf: machine [

	^ machine
		transitionsFrom: machine initialState
		allowedWithin: StateMachineSpecificationContextExample new
]
