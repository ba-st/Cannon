"
A WorkflowTransitionerTest is a test class for testing the behavior of WorkflowTransitioner
"
Class {
	#name : #WorkflowTransitionerTest,
	#superclass : #TestCase,
	#category : #'Cannon-Workflow-Tests'
}

{ #category : #'private - configuring' }
WorkflowTransitionerTest >> addAutomaticConfirmationTransitionTo: builder writingTo: stream [

	^ self addConfirmationTransitionTo: builder writingTo: stream triggeredWhen: [ true ]
]

{ #category : #'private - configuring' }
WorkflowTransitionerTest >> addAutomaticSettlementTransitionTo: builder writingTo: stream [

	^ self addSettlementTransitionTo: builder writingTo: stream triggeredWhen: [ true ]
]

{ #category : #'private - configuring' }
WorkflowTransitionerTest >> addConfirmationTransitionTo: builder writingTo: stream triggeredWhen: aBooleanBlock [

	builder
		addTransitionNamed: 'Confirm'
		from: 'Pending'
		to: 'Confirmed'
		allowedWhen: self confirmationCondition
		doing: [ stream
				nextPutAll: 'Confirmation complete';
				cr ]
		triggeredBy: (PluggableTriggerExample activatedWhen: aBooleanBlock)
]

{ #category : #'private - configuring' }
WorkflowTransitionerTest >> addManualConfirmationTransitionTo: builder writingTo: stream [

	^ self addConfirmationTransitionTo: builder writingTo: stream triggeredWhen: [ false ]
]

{ #category : #'private - configuring' }
WorkflowTransitionerTest >> addManualSettlementTransitionTo: builder writingTo: stream [

	^ self addSettlementTransitionTo: builder writingTo: stream triggeredWhen: [ false ]
]

{ #category : #'private - configuring' }
WorkflowTransitionerTest >> addSettlementTransitionTo: builder writingTo: stream triggeredWhen: aBooleanBlock [

	builder
		addTransitionNamed: 'Settlement'
		from: 'Confirmed'
		to: 'Settled'
		allowedWhen: self settlementCondition
		doing: [ stream
				nextPutAll: 'Settlement complete';
				cr ]
		triggeredBy: (PluggableTriggerExample activatedWhen: aBooleanBlock)
]

{ #category : #'private - configuring' }
WorkflowTransitionerTest >> addStateNamed: aName to: aMachineSpecBuilder loggingTo: aLogCollection [

	aMachineSpecBuilder
		addStateNamed: aName
		onEntry: [ aLogCollection add: ('Now <1s>' expandMacrosWith: aName) ]
		onExit: [ :context | 
			| text |

			text := '<1s> no more' expandMacrosWith: aName.
			aLogCollection add: text.
			context inCaseOfRollback: [ aLogCollection remove: text ] ]
]

{ #category : #'private - accessing' }
WorkflowTransitionerTest >> confirmationCondition [

	^ PluggableConditionExample
		evaluating: [ :conditionContext | conditionContext loggedUser ~= conditionContext tradeOriginator ]
]

{ #category : #'private - accessing' }
WorkflowTransitionerTest >> machineSpecBuilder [

	| builder |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'Pending'.
	builder addStateNamed: 'Confirmed'.
	builder addStateNamed: 'Settled'.
	^ builder
]

{ #category : #'private - accessing' }
WorkflowTransitionerTest >> machineSpecWithAutomaticConfirmationAndSettlementWritingTo: aStream [

	| builder |

	builder := self machineSpecBuilder.
	self addAutomaticConfirmationTransitionTo: builder writingTo: aStream.
	self addAutomaticSettlementTransitionTo: builder writingTo: aStream.
	builder declareAsInitialState: 'Pending'.
	^ builder build
]

{ #category : #'private - accessing' }
WorkflowTransitionerTest >> machineSpecWithManualConfirmationAndAutomaticSettlementWritingTo: aStream [

	| builder |

	builder := self machineSpecBuilder.
	self addManualConfirmationTransitionTo: builder writingTo: aStream.
	self addAutomaticSettlementTransitionTo: builder writingTo: aStream.
	builder declareAsInitialState: 'Pending'.
	^ builder build
]

{ #category : #'private - accessing' }
WorkflowTransitionerTest >> machineSpecWithManualConfirmationAndSettlementWritingTo: aStream [

	| builder |

	builder := self machineSpecBuilder.
	self addManualConfirmationTransitionTo: builder writingTo: aStream.
	self addManualSettlementTransitionTo: builder writingTo: aStream.
	builder declareAsInitialState: 'Pending'.
	^ builder build
]

{ #category : #'private - accessing' }
WorkflowTransitionerTest >> settlementCondition [

	^ PluggableConditionExample
		evaluating:
			[ :conditionContext | conditionContext expectedSettlementDate <= conditionContext currentDate ]
]

{ #category : #tests }
WorkflowTransitionerTest >> testFailedManualTransitionOnlyRollbacksThatTransition [

	| builder logs machine workflowContext transitioner |

	logs := OrderedCollection new.
	builder := StateMachineSpecificationBuilder new.
	self addStateNamed: 'Pending' to: builder loggingTo: logs.
	self addStateNamed: 'Confirmed' to: builder loggingTo: logs.
	self addStateNamed: 'Settled' to: builder loggingTo: logs.
	builder
		addTransitionNamed: 'Confirm'
		from: 'Pending'
		to: 'Confirmed'
		allowedWhen: self confirmationCondition
		doing: [ logs add: 'User interaction while confirming' ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ false ]).
	builder
		addTransitionNamed: 'Settle'
		from: 'Confirmed'
		to: 'Settled'
		allowedWhen: self confirmationCondition
		doing: [ 1 / 0 ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ false ]).
	builder declareAsInitialState: 'Pending'.
	machine := builder build.
	workflowContext := self workflowContext.
	transitioner := WorkflowTransitioner within: workflowContext inInitialStateFor: machine.

	self assertCollection: logs hasSameElements: (Array with: 'Now Pending').
	transitioner transitionTo: 'Confirmed'.
	self assert: transitioner currentState name equals: 'Confirmed'.
	self
		assertCollection: logs
		hasSameElements:
			(Array
				with: 'Now Pending'
				with: 'Pending no more'
				with: 'User interaction while confirming'
				with: 'Now Confirmed').

	transitioner transitionTo: 'Settled'.
	self assert: transitioner currentState name equals: 'Confirmed'.
	self
		assertCollection: logs
		hasSameElements:
			(Array
				with: 'Now Pending'
				with: 'Pending no more'
				with: 'User interaction while confirming'
				with: 'Now Confirmed')
]

{ #category : #tests }
WorkflowTransitionerTest >> testFailedTransitionDuringTriggerOnlyRollbacksLastTransition [

	| builder logs machine workflowContext transitioner |

	logs := OrderedCollection new.
	builder := StateMachineSpecificationBuilder new.
	self addStateNamed: 'Pending' to: builder loggingTo: logs.
	self addStateNamed: 'Confirmed' to: builder loggingTo: logs.
	self addStateNamed: 'Settled' to: builder loggingTo: logs.
	builder
		addTransitionNamed: 'Confirm'
		from: 'Pending'
		to: 'Confirmed'
		allowedWhen: self confirmationCondition
		doing: [ logs add: 'User interaction while confirming' ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ false ]).
	builder
		addTransitionNamed: 'Settle'
		from: 'Confirmed'
		to: 'Settled'
		allowedWhen: self confirmationCondition
		doing: [ 1 / 0 ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ true ]).
	builder declareAsInitialState: 'Pending'.
	machine := builder build.
	workflowContext := self workflowContext.
	transitioner := WorkflowTransitioner within: workflowContext inInitialStateFor: machine.


	self assertCollection: logs hasSameElements: (Array with: 'Now Pending').
	transitioner transitionTo: 'Confirmed'.
	self assert: transitioner currentState name equals: 'Confirmed'.
	self
		assertCollection: logs
		hasSameElements:
			(Array
				with: 'Now Pending'
				with: 'Pending no more'
				with: 'User interaction while confirming'
				with: 'Now Confirmed')
]

{ #category : #tests }
WorkflowTransitionerTest >> testInstanceCreationFailsWhenEntryActionToInitialStateIsInvalid [

	| builder machine workflowContext |

	builder := StateMachineSpecificationBuilder new.
	builder
		addStateNamed: 'Only'
		onEntry: [ Error signal: 'Test should catch this' ]
		onExit: [  ].
	builder addTransitionFrom: 'Only' to: 'Only'.
	machine := builder build.
	workflowContext := self workflowContext.
	
	self
		should: [ WorkflowTransitioner within: workflowContext inInitialStateFor: machine ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: '-->Only could not be completed because Test should catch this.' ]
]

{ #category : #tests }
WorkflowTransitionerTest >> testInstanceCreationFailsWhenStateIsInvalid [

	| machine stream workflowContext |

	stream := WriteStream on: String new.
	machine := self machineSpecWithAutomaticConfirmationAndSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	
	self
		should: [ WorkflowTransitioner within: workflowContext for: machine in: 'Shouldfail' ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :exception | self assert: exception messageText equals: 'No state is named Shouldfail' ].
	self assert: stream isEmpty
]

{ #category : #tests }
WorkflowTransitionerTest >> testRollbackOfFailedTransition [

	| builder logs machine workflowContext transitioner |

	logs := OrderedCollection new.
	builder := StateMachineSpecificationBuilder new.
	self addStateNamed: 'Pending' to: builder loggingTo: logs.
	self addStateNamed: 'Confirmed' to: builder loggingTo: logs.
	builder
		addTransitionNamed: 'Confirm'
		from: 'Pending'
		to: 'Confirmed'
		allowedWhen: self confirmationCondition
		doing: [ 1 / 0 ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ false ]).
	builder declareAsInitialState: 'Pending'.
	machine := builder build.
	workflowContext := self workflowContext.
	transitioner := WorkflowTransitioner within: workflowContext inInitialStateFor: machine.

	self assertCollection: logs hasSameElements: (Array with: 'Now Pending').
	transitioner transitionTo: 'Confirmed'.
	self assert: transitioner currentState name equals: 'Pending'.
	self assertCollection: logs hasSameElements: (Array with: 'Now Pending')
]

{ #category : #tests }
WorkflowTransitionerTest >> testTransitionFailsWhenDestionationStateIsUnreachable [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithManualConfirmationAndSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	transitioner := WorkflowTransitioner within: workflowContext inInitialStateFor: machine.
	
	self
		should: [ transitioner transitionTo: 'Settled' ]
		raise: ObjectNotFound
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: 'No allowed transition found from Pending to Settled' ].
	self assert: stream isEmpty
]

{ #category : #tests }
WorkflowTransitionerTest >> testTransitionFailsWhenNotAllowed [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithManualConfirmationAndSettlementWritingTo: stream.
	workflowContext := WorkflowContextExample
		for: 'Bob'
		on: Date today
		managingTradeOf: 'Bob'
		expectedToSettleOn: (Date today subtractDays: 1).
	transitioner := WorkflowTransitioner within: workflowContext inInitialStateFor: machine.
	
	self
		should: [ transitioner transitionTo: 'Confirmed' ]
		raise: ObjectNotFound
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: 'No allowed transition found from Pending to Confirmed' ].
	self assert: stream isEmpty
]

{ #category : #tests }
WorkflowTransitionerTest >> testTransitionFromInitialStateWithActiveTrigger [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithAutomaticConfirmationAndSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	transitioner := WorkflowTransitioner within: workflowContext inInitialStateFor: machine.

	self assert: transitioner currentState name equals: 'Settled'.
	self
		assert: stream contents
		equals: 'Confirmation complete<r>Settlement complete<r>' expandMacros
]

{ #category : #tests }
WorkflowTransitionerTest >> testTransitionFromInitialStateWithInactiveTrigger [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithManualConfirmationAndSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	transitioner := WorkflowTransitioner within: workflowContext inInitialStateFor: machine.

	self assert: stream contents isEmpty.
	self assert: transitioner currentState name equals: 'Pending'.
	transitioner transitionTo: 'Confirmed'.
	self assert: transitioner currentState name equals: 'Confirmed'.
	self assert: stream contents equals: 'Confirmation complete<r>' expandMacros.
	transitioner transitionTo: 'Settled'.
	self assert: transitioner currentState name equals: 'Settled'.
	self
		assert: stream contents
		equals: 'Confirmation complete<r>Settlement complete<r>' expandMacros
]

{ #category : #tests }
WorkflowTransitionerTest >> testTransitionToStateWithActiveTrigger [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithManualConfirmationAndAutomaticSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	transitioner := WorkflowTransitioner within: workflowContext for: machine in: 'Pending'.

	self assert: stream contents isEmpty.
	self assert: transitioner currentState name equals: 'Pending'.
	transitioner transitionTo: 'Confirmed'.
	self assert: transitioner currentState name equals: 'Settled'.
	self
		assert: stream contents
		equals: 'Confirmation complete<r>Settlement complete<r>' expandMacros
]

{ #category : #tests }
WorkflowTransitionerTest >> testTransitionToStateWithInactiveTrigger [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithManualConfirmationAndSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	transitioner := WorkflowTransitioner within: workflowContext for: machine in: 'Pending'.

	self assert: stream contents isEmpty.
	self assert: transitioner currentState name equals: 'Pending'.
	transitioner transitionTo: 'Confirmed'.
	self assert: transitioner currentState name equals: 'Confirmed'.
	self assert: stream contents equals: 'Confirmation complete<r>' expandMacros.
	transitioner transitionTo: 'Settled'.
	self assert: transitioner currentState name equals: 'Settled'.
	self
		assert: stream contents
		equals: 'Confirmation complete<r>Settlement complete<r>' expandMacros
]

{ #category : #'private - accessing' }
WorkflowTransitionerTest >> workflowContext [

	^ WorkflowContextExample
		for: 'Alice'
		on: Date today
		managingTradeOf: 'Bob'
		expectedToSettleOn: (Date today subtractDays: 1)
]
