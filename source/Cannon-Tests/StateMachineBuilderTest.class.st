"
A StateMachineBuilderTest is a test class for testing the behavior of StateMachineBuilder
"
Class {
	#name : #StateMachineBuilderTest,
	#superclass : #TestCase,
	#category : #'Cannon-Tests'
}

{ #category : #'private - processing' }
StateMachineBuilderTest >> applyOnlyTransitionOf: machine [

	StateMachineTransitioner new
		apply: (self transitionsFromInitialStateOf: machine) anyOne
		of: machine
]

{ #category : #tests }
StateMachineBuilderTest >> testAddStateNamed [

	| builder machine |

	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
	builder addStateNamed: 'A'.
	builder addTransitionFrom: 'A' to: 'A'.
	machine := builder build.

	self assert: machine initialState name equals: 'A'
]

{ #category : #tests }
StateMachineBuilderTest >> testAddStateNamedOnEntryOnExit [

	| builder machine stream |

	stream := WriteStream on: String new.
	builder := StateMachineBuilder
		buildingContextWith: StateMachineContextExample.
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

	self assert: stream contents equals: 'Entering<r>' expandMacros.
	self applyOnlyTransitionOf: machine.
	self
		assert: stream contents
		equals: 'Entering<r>Exiting<r>Entering<r>' expandMacros
]

{ #category : #tests }
StateMachineBuilderTest >> testAddTransitionFromTo [

	| builder machine transitions stream |

	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
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
StateMachineBuilderTest >> testAddTransitionFromToAllowedWhenDoingTriggeredBy [

	| builder machine transitions stream |

	stream := WriteStream on: String new.
	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
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

	stream nextPutAll: 'Entering A<r>' expandMacros.
	transitions := self transitionsFromInitialStateOf: machine.
	self
		assert: transitions size equals: 1;
		assert: transitions anyOne source name equals: 'A';
		assert: transitions anyOne destination name equals: 'B'.
	self assert: stream contents equals: 'Entering A<r>' expandMacros.

	self applyOnlyTransitionOf: machine.
	self
		assert: stream contents
		equals: 'Entering A<r>Manual...done<r>Auto...done<r>' expandMacros
]

{ #category : #tests }
StateMachineBuilderTest >> testAddTransitionNamedFromTo [

	| builder machine transitions stream |

	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
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
StateMachineBuilderTest >> testAddTransitionNamedFromToAllowedWhenDoingTriggeredBy [

	| builder machine transitions stream |

	stream := WriteStream on: String new.
	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
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

	stream nextPutAll: 'Entering A<r>' expandMacros.
	transitions := self transitionsFromInitialStateOf: machine.
	self
		assert: transitions size equals: 1;
		assert: transitions anyOne source name equals: 'A';
		assert: transitions anyOne destination name equals: 'B'.
	self assert: stream contents equals: 'Entering A<r>' expandMacros.

	self applyOnlyTransitionOf: machine.
	self
		assert: stream contents
		equals: 'Entering A<r>Manual...done<r>Auto...done<r>' expandMacros
]

{ #category : #tests }
StateMachineBuilderTest >> testAtLeastOneTransitionMustBeDefined [

	| builder |

	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
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
StateMachineBuilderTest >> testBuiltContext [

	| builder machine context |

	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
	builder addStateNamed: 'A'.
	builder addTransitionFrom: 'A' to: 'A'.
	machine := builder build.

	context := machine contextBuilder readyFor: machine.
	self assert: (context isA: StateMachineContextExample)
]

{ #category : #tests }
StateMachineBuilderTest >> testInitialStateMustBeDefinedFirst [

	| builder |

	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
	builder addStateNamed: 'A'.

	self
		should: [ builder addTransitionFrom: 'A' to: 'B' ]
		raise: InstanceCreationFailed
		withExceptionDo:
			[ :error | self assert: error messageText equals: 'Couldn''t find a single state named B.' ]
]

{ #category : #tests }
StateMachineBuilderTest >> testStatesInTransitionsMustBeDefined [

	| builder |

	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
	builder addStateNamed: 'A'.
	builder declareAsInitialState: 'B'.

	self
		should: [ builder build ]
		raise: InstanceCreationFailed
		withExceptionDo:
			[ :error | self assert: error messageText equals: 'Couldn''t find a single state named B.' ]
]

{ #category : #tests }
StateMachineBuilderTest >> testThreeStatesAndTwoTransitions [

	| builder machine context transitions |

	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
	builder addStateNamed: 'A'.
	builder addStateNamed: 'B'.
	builder addTransitionFrom: 'A' to: 'B'.
	builder addStateNamed: 'C'.
	builder addTransitionFrom: 'B' to: 'C'.
	builder declareAsInitialState: 'A'.
	machine := builder build.

	context := machine contextBuilder readyFor: machine.
	self
		assert: (context isA: StateMachineContextExample);
		assert: machine initialState name equals: 'A'.

	transitions := machine transitionsFrom: machine initialState allowedWithin: context.
	self
		assert: transitions size equals: 1;
		assert: transitions anyOne source name equals: 'A';
		assert: transitions anyOne destination name equals: 'B'.

	transitions := machine
		transitionsFrom: transitions anyOne destination
		allowedWithin: context.
	self
		assert: transitions size equals: 1;
		assert: transitions anyOne source name equals: 'B';
		assert: transitions anyOne destination name equals: 'C'
]

{ #category : #tests }
StateMachineBuilderTest >> testWithMoreThanOneStateTheInitialStateMustBeDefined [

	| builder |

	builder := StateMachineBuilder buildingContextWith: StateMachineContextExample.
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
StateMachineBuilderTest >> transitionsFromInitialStateOf: machine [

	^ machine
		transitionsFrom: machine initialState
		allowedWithin: (machine contextBuilder readyFor: machine)
]
