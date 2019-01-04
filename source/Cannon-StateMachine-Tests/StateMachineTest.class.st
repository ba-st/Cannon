"
A WorkflowTransitionerTest is a test class for testing the behavior of WorkflowTransitioner
"
Class {
	#name : #StateMachineTest,
	#superclass : #TestCase,
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #'private - configuring' }
StateMachineTest >> addAutomaticConfirmationTransitionTo: builder writingTo: stream [

	^ self addConfirmationTransitionTo: builder writingTo: stream triggeredWhen: [ true ]
]

{ #category : #'private - configuring' }
StateMachineTest >> addAutomaticSettlementTransitionTo: builder writingTo: stream [

	^ self addSettlementTransitionTo: builder writingTo: stream triggeredWhen: [ true ]
]

{ #category : #'private - configuring' }
StateMachineTest >> addConfirmationTransitionTo: builder writingTo: stream triggeredWhen: aBooleanBlock [

	builder
		addTransitionNamed: 'Confirm'
		fromStateNamed: 'Pending'
		toStateNamed: 'Confirmed'
		allowedWhen: self confirmationCondition
		completedUsing: [ stream
				nextPutAll: 'Confirmation complete';
				cr ]
		triggeredBy: (ConditionBasedTrigger basedOn: (PluggableConditionExample evaluating: aBooleanBlock))
]

{ #category : #'private - configuring' }
StateMachineTest >> addManualConfirmationTransitionTo: builder writingTo: stream [

	^ self addConfirmationTransitionTo: builder writingTo: stream triggeredWhen: [ false ]
]

{ #category : #'private - configuring' }
StateMachineTest >> addManualSettlementTransitionTo: builder writingTo: stream [

	^ self addSettlementTransitionTo: builder writingTo: stream triggeredWhen: [ false ]
]

{ #category : #'private - configuring' }
StateMachineTest >> addSettlementTransitionTo: builder writingTo: stream triggeredWhen: aBooleanBlock [

	builder
		addTransitionNamed: 'Settlement'
		fromStateNamed: 'Confirmed'
		toStateNamed: 'Settled'
		allowedWhen: self settlementCondition
		completedUsing: [ stream
				nextPutAll: 'Settlement complete';
				cr ]
		triggeredBy: (ConditionBasedTrigger basedOn: (PluggableConditionExample evaluating: aBooleanBlock))
]

{ #category : #'private - configuring' }
StateMachineTest >> addStateNamed: aName to: aMachineSpecBuilder loggingTo: aLogCollection [

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
StateMachineTest >> confirmationCondition [

	^ PluggableConditionExample
		evaluating: [ :conditionContext | conditionContext loggedUser ~= conditionContext tradeOriginator ]
]

{ #category : #'private - accessing' }
StateMachineTest >> machineSpecBuilder [

	| builder |

	builder := StateMachineSpecificationBuilder new.
	builder addStateNamed: 'Pending'.
	builder addStateNamed: 'Confirmed'.
	builder addStateNamed: 'Settled'.
	^ builder
]

{ #category : #'private - accessing' }
StateMachineTest >> machineSpecWithAutomaticConfirmationAndSettlementWritingTo: aStream [

	| builder |

	builder := self machineSpecBuilder.
	self addAutomaticConfirmationTransitionTo: builder writingTo: aStream.
	self addAutomaticSettlementTransitionTo: builder writingTo: aStream.
	builder startFromStateNamed: 'Pending'.
	^ builder build
]

{ #category : #'private - accessing' }
StateMachineTest >> machineSpecWithManualConfirmationAndAutomaticSettlementWritingTo: aStream [

	| builder |

	builder := self machineSpecBuilder.
	self addManualConfirmationTransitionTo: builder writingTo: aStream.
	self addAutomaticSettlementTransitionTo: builder writingTo: aStream.
	builder startFromStateNamed: 'Pending'.
	^ builder build
]

{ #category : #'private - accessing' }
StateMachineTest >> machineSpecWithManualConfirmationAndSettlementWritingTo: aStream [

	| builder |

	builder := self machineSpecBuilder.
	self addManualConfirmationTransitionTo: builder writingTo: aStream.
	self addManualSettlementTransitionTo: builder writingTo: aStream.
	builder startFromStateNamed: 'Pending'.
	^ builder build
]

{ #category : #'private - accessing' }
StateMachineTest >> settlementCondition [

	^ PluggableConditionExample
		evaluating:
			[ :conditionContext | conditionContext expectedSettlementDate <= conditionContext currentDate ]
]

{ #category : #tests }
StateMachineTest >> testInstanceCreationFailsWhenStateIsInvalid [

	| machine stream workflowContext |

	stream := WriteStream on: String new.
	machine := self machineSpecWithAutomaticConfirmationAndSettlementWritingTo: stream.
	workflowContext := self workflowContext.

	self
		should: [ StateMachine within: workflowContext for: machine in: 'Shouldfail' ]
			raise: InstanceCreationFailed
			withMessageText: 'No state is named Shouldfail';
		assert: stream isEmpty
]

{ #category : #tests }
StateMachineTest >> testMultipleAllowedTransitionsFromSameSourcetoSameDestinationAreInvalid [

	| builder machine stream transitioner |

	stream := WriteStream on: String new.
	builder := self machineSpecBuilder.
	builder
		addTransitionNamed: 'A type of confirmation'
		fromStateNamed: 'Pending'
		toStateNamed: 'Confirmed'
		allowedWhen: self confirmationCondition
		completedUsing: [ stream nextPutAll: 'Confirmed one way' ]
		triggeredBy: ManualTransitionTrigger new.
	builder
		addTransitionNamed: 'Another confirmation'
		fromStateNamed: 'Pending'
		toStateNamed: 'Confirmed'
		allowedWhen: self confirmationCondition
		completedUsing: [ stream nextPutAll: 'Confirmed another' ]
		triggeredBy: ManualTransitionTrigger new.
	builder startFromStateNamed: 'Pending'.
	machine := builder build.
	transitioner := StateMachine within: self workflowContext inInitialStateFor: machine.

	self
		should: [ transitioner startTransitionTo: 'Confirmed' ]
			raise: TransitionFailed
			withMessageText: 'Expected single transition from Pending to Confirmed but found 2.';
		assert: stream isEmpty
]

{ #category : #tests }
StateMachineTest >> testTransitionFailsWhenDestionationStateIsUnreachable [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithManualConfirmationAndSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	transitioner := StateMachine within: workflowContext inInitialStateFor: machine.

	self
		should: [ transitioner startTransitionTo: 'Settled' ]
			raise: TransitionFailed
			withMessageText: 'Expected single transition from Pending to Settled but found 0.';
		assert: stream isEmpty
]

{ #category : #tests }
StateMachineTest >> testTransitionFailsWhenNotAllowed [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithManualConfirmationAndSettlementWritingTo: stream.
	workflowContext := WorkflowContextExample
		for: 'Bob'
		on: Date today
		managingTradeOf: 'Bob'
		expectedToSettleOn: ( Date today subtractDays: 1 ).
	transitioner := StateMachine within: workflowContext inInitialStateFor: machine.

	self
		should: [ transitioner startTransitionTo: 'Confirmed' ]
			raise: TransitionFailed
			withMessageText: 'Expected single transition from Pending to Confirmed but found 0.';
		assert: stream isEmpty
]

{ #category : #tests }
StateMachineTest >> testTransitionFromInitialStateWithActiveTrigger [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithAutomaticConfirmationAndSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	transitioner := StateMachine within: workflowContext inInitialStateFor: machine.

	self assert: transitioner currentState name equals: 'Settled'.
	self
		assert: stream contents
		equals: 'Confirmation complete<r>Settlement complete<r>' expandMacros
]

{ #category : #tests }
StateMachineTest >> testTransitionFromInitialStateWithInactiveTrigger [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithManualConfirmationAndSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	transitioner := StateMachine within: workflowContext inInitialStateFor: machine.

	self assert: stream contents isEmpty.
	self assert: transitioner currentState name equals: 'Pending'.
	transitioner startTransitionTo: 'Confirmed'.
	self assert: transitioner currentState name equals: 'Confirmed'.
	self assert: stream contents equals: 'Confirmation complete<r>' expandMacros.
	transitioner startTransitionTo: 'Settled'.
	self assert: transitioner currentState name equals: 'Settled'.
	self
		assert: stream contents
		equals: 'Confirmation complete<r>Settlement complete<r>' expandMacros
]

{ #category : #tests }
StateMachineTest >> testTransitionToStateWithActiveTrigger [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithManualConfirmationAndAutomaticSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	transitioner := StateMachine within: workflowContext for: machine in: 'Pending'.

	self assert: stream contents isEmpty.
	self assert: transitioner currentState name equals: 'Pending'.
	transitioner startTransitionTo: 'Confirmed'.
	self assert: transitioner currentState name equals: 'Settled'.
	self
		assert: stream contents
		equals: 'Confirmation complete<r>Settlement complete<r>' expandMacros
]

{ #category : #tests }
StateMachineTest >> testTransitionToStateWithInactiveTrigger [

	| machine stream workflowContext transitioner |

	stream := WriteStream on: String new.
	machine := self machineSpecWithManualConfirmationAndSettlementWritingTo: stream.
	workflowContext := self workflowContext.
	transitioner := StateMachine within: workflowContext for: machine in: 'Pending'.

	self assert: stream contents isEmpty.
	self assert: transitioner currentState name equals: 'Pending'.
	transitioner startTransitionTo: 'Confirmed'.
	self assert: transitioner currentState name equals: 'Confirmed'.
	self assert: stream contents equals: 'Confirmation complete<r>' expandMacros.
	transitioner startTransitionTo: 'Settled'.
	self assert: transitioner currentState name equals: 'Settled'.
	self
		assert: stream contents
		equals: 'Confirmation complete<r>Settlement complete<r>' expandMacros
]

{ #category : #'private - accessing' }
StateMachineTest >> workflowContext [

	^ WorkflowContextExample
		for: 'Alice'
		on: Date today
		managingTradeOf: 'Bob'
		expectedToSettleOn: (Date today subtractDays: 1)
]
