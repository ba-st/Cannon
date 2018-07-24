"
A StateMachineBuilderTest is a test class for testing the behavior of StateMachineBuilder
"
Class {
	#name : #StateMachineSpecificationBuilderTest,
	#superclass : #TestCase,
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #'private - processing' }
StateMachineSpecificationBuilderTest >> applyOnlyTransitionOf: machine [

	TransitionApplicator new
		apply: (self transitionsFromInitialStateOf: machine) anyOne
		of: machine
		within: StateMachineContextExample new
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAddStateNamed [

	| builder machine |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addTransitionFrom: 'A' to: 'A'.
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
	builder addTransitionFrom: 'A' to: 'A'.
	machine := builder build.

	self assert: machine initialState name equals: 'A'.

	self assert: stream contents isEmpty.
	self applyOnlyTransitionOf: machine.
	self assert: stream contents equals: 'Exiting<r>Entering<r>' expandMacros
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAddTransitionFromTo [

	| builder machine transitions stream |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addTransitionFrom: 'A' to: 'B'.
	builder declareAsInitialState: 'A'.
	machine := builder build.

	transitions := self transitionsFromInitialStateOf: machine.
	self
		assert: transitions size equals: 1;
		assert: transitions anyOne source name equals: 'A';
		assert: transitions anyOne destination name equals: 'B'.

	stream := WriteStream on: String new.
	transitions anyOne
		withNameDo: [ :name | self fail ]
		ifUnnamed: [ stream nextPutAll: 'test passed' ].
	self assert: stream contents equals: 'test passed'
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAddTransitionFromToAllowedWhenDoingTriggeredBy [

	| builder machine transitions stream |

	stream := WriteStream on: String new.
	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addStateNamed: 'C'.
	builder
		addTransitionFrom: 'A'
		to: 'B'
		allowedWhen: (TransitionConditionExample readingFrom: stream)
		doing: [ stream
				nextPutAll: 'Manual...done';
				cr ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ false ]).
	builder
		addTransitionFrom: 'B'
		to: 'C'
		allowedWhen: (TransitionConditionExample readingFrom: stream)
		doing: [ stream
				nextPutAll: 'Auto...done';
				cr ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ true ]).
	builder declareAsInitialState: 'A'.
	machine := builder build.

	self assert: (self transitionsFromInitialStateOf: machine) isEmpty.

	stream
		nextPutAll: 'Ready';
		cr.
	transitions := self transitionsFromInitialStateOf: machine.
	self
		assert: transitions size equals: 1;
		assert: transitions anyOne source name equals: 'A';
		assert: transitions anyOne destination name equals: 'B'.

	self applyOnlyTransitionOf: machine.
	self
		assert: stream contents
		equals: 'Ready<r>Manual...done<r>Auto...done<r>' expandMacros
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAddTransitionNamedFromTo [

	| builder machine transitions stream |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addTransitionNamed: 'only' from: 'A' to: 'B'.
	builder declareAsInitialState: 'A'.
	machine := builder build.

	transitions := self transitionsFromInitialStateOf: machine.
	self
		assert: transitions size equals: 1;
		assert: transitions anyOne source name equals: 'A';
		assert: transitions anyOne destination name equals: 'B'.

	stream := WriteStream on: String new.
	transitions anyOne
		withNameDo: [ :name | stream nextPutAll: name ]
		ifUnnamed: [ self fail ].
	self assert: stream contents equals: 'only'
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testAddTransitionNamedFromToAllowedWhenDoingTriggeredBy [

	| builder machine transitions stream |

	stream := WriteStream on: String new.
	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addStateNamed: 'C'.
	builder
		addTransitionNamed: 'Manual'
		from: 'A'
		to: 'B'
		allowedWhen: (TransitionConditionExample readingFrom: stream)
		doing: [ stream
				nextPutAll: 'Manual...done';
				cr ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ false ]).
	builder
		addTransitionNamed: 'Automatic'
		from: 'B'
		to: 'C'
		allowedWhen: (TransitionConditionExample readingFrom: stream)
		doing: [ stream
				nextPutAll: 'Auto...done';
				cr ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ true ]).
	builder declareAsInitialState: 'A'.
	machine := builder build.

	self assert: (self transitionsFromInitialStateOf: machine) isEmpty.

	stream
		nextPutAll: 'Ready';
		cr.
	transitions := self transitionsFromInitialStateOf: machine.
	self
		assert: transitions size equals: 1;
		assert: transitions anyOne source name equals: 'A';
		assert: transitions anyOne destination name equals: 'B'.

	self applyOnlyTransitionOf: machine.
	self
		assert: stream contents
		equals: 'Ready<r>Manual...done<r>Auto...done<r>' expandMacros
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
		should: [ builder addTransitionFrom: 'A' to: 'B' ]
		raise: InstanceCreationFailed
		withExceptionDo:
			[ :error | self assert: error messageText equals: 'Couldn''t find a single state named B.' ]
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testStatesInTransitionsMustBeDefined [

	| builder |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder declareAsInitialState: 'B'.

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
	builder addTransitionFrom: 'A' to: 'B'.
	builder addStateNamed: 'C'.
	builder addTransitionFrom: 'B' to: 'C'.
	builder declareAsInitialState: 'A'.
	machine := builder build.

	self assert: machine initialState name equals: 'A'.

	transitions := machine
		transitionsFrom: machine initialState
		allowedWithin: StateMachineContextExample new.
	self
		assert: transitions size equals: 1;
		assert: transitions anyOne source name equals: 'A';
		assert: transitions anyOne destination name equals: 'B'.

	transitions := machine
		transitionsFrom: transitions anyOne destination
		allowedWithin: StateMachineContextExample new.
	self
		assert: transitions size equals: 1;
		assert: transitions anyOne source name equals: 'B';
		assert: transitions anyOne destination name equals: 'C'
]

{ #category : #tests }
StateMachineSpecificationBuilderTest >> testWithMoreThanOneStateTheInitialStateMustBeDefined [

	| builder |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addTransitionFrom: 'A' to: 'B'.

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
		allowedWithin: StateMachineContextExample new
]
