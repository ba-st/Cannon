"
An object with a state machine that includes examples for states and transitions.
"
Class {
	#name : #WorkflowMachineExample,
	#superclass : #Object,
	#instVars : [
		'machineSpec',
		'eventHistory',
		'machine',
		'workflowContext'
	],
	#category : #'Cannon-Willow-Examples'
}

{ #category : #'instance creation' }
WorkflowMachineExample class >> within: aContext [

	^ self new initializeWithin: aContext
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addCodingToTestingTo: builder [

	self
		addTransitionNamed: 'Run the test'
		from: 'Coding'
		to: 'Testing'
		logging: 'Test running'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addFocusLoopTo: builder [

	builder
		addTransitionNamed: 'Focus!'
		fromStateNamed: 'Idle'
		toStateNamed: 'Idle'
		allowedWhen:
			(PluggableConditionExample
				evaluating: [ :conditionContext | conditionContext isFocused not ])
		completedUsing: [ :context | 
			eventHistory add: 'Gaining focus'.
			context gainFocus ]
		triggeredBy: (ConditionBasedTrigger basedOn: (PluggableConditionExample evaluating: [ false ]))
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addIdleToCodingTo: builder [

	self
		addTransitionNamed: 'Write some code'
		from: 'Idle'
		to: 'Coding'
		logging: 'Coding without thinking'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addIdleToTestingTo: builder [

	self
		addTransitionNamed: 'Check the current version'
		from: 'Idle'
		to: 'Testing'
		logging: 'Testing whatever is there'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addIdleToThinkingTo: aBuilder [

	aBuilder
		addTransitionNamed: 'Call for a brainstorming session'
		fromStateNamed: 'Idle'
		toStateNamed: 'Thinking'
		allowedWhen:
			(PluggableConditionExample
				evaluating: [ :conditionContext | conditionContext isFocused not ])
		startedUsing: [ :context :actionWhenCompleted | 
			eventHistory add: 'Brainstorming session called'.
			self configure: context toOpenDialogAndWhenAcceptedDo: actionWhenCompleted ]
		triggeredBy: (ConditionBasedTrigger basedOn: (PluggableConditionExample evaluating: [ false ]))
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addStateNamed: aName to: aBuilder [

	aBuilder
		addStateNamed: aName
		onEntry: [ :context | eventHistory add: ('[+] <1s>' expandMacrosWith: aName) ]
		onExit: [ :context | eventHistory add: ('[-] <1s>' expandMacrosWith: aName) ]
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addTestingToCodingTo: builder [

	self
		addTransitionNamed: 'Fix those tests!'
		from: 'Testing'
		to: 'Coding'
		logging: 'Fixing failed tests, or maybe writing new ones'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addThinkDevelopTestIterationTo: builder [

	builder
		addTransitionNamed: 'Think how to develop a test'
			fromStateNamed: 'Idle'
			toStateNamed: 'Thinking'
			allowedWhen: (PluggableConditionExample evaluating: [ :conditionContext | conditionContext isFocused ])
			completedUsing: [ :context | 
				eventHistory add: 'Thinking about the code of a test'.
				context goOn: 'Coding' ]
			triggeredBy: (ConditionBasedTrigger basedOn: (PluggableConditionExample evaluating: [ false ]));
		addTransitionNamed: 'Think how to develop a test'
			fromStateNamed: 'Thinking'
			toStateNamed: 'Coding'
			allowedWhen: (PluggableConditionExample evaluating: [ :conditionContext | conditionContext isFocused ])
			completedUsing: [ :context | 
				eventHistory add: 'Coding a test'.
				context goOn: 'Testing' ]
			triggeredBy:
			(ConditionBasedTrigger
					basedOn: (PluggableConditionExample evaluating: [ :context | context isPreparedFor: 'Coding' ]));
		addTransitionNamed: 'Test the test developed'
			fromStateNamed: 'Coding'
			toStateNamed: 'Testing'
			allowedWhen: (PluggableConditionExample evaluating: [ :conditionContext | conditionContext isFocused ])
			completedUsing: [ :context | 
				eventHistory add: 'Testing a test'.
				context goOn: 'Resting' ]
			triggeredBy:
			(ConditionBasedTrigger
					basedOn: (PluggableConditionExample evaluating: [ :context | context isPreparedFor: 'Testing' ]));
		addTransitionNamed: 'Rest after a tested test'
			fromStateNamed: 'Testing'
			toStateNamed: 'Idle'
			allowedWhen: (PluggableConditionExample evaluating: [ :conditionContext | conditionContext isFocused ])
			completedUsing: [ :context | 
				eventHistory add: 'Resting with green tests'.
				context
					takeABreak;
					loseFocus ]
			triggeredBy:
			(ConditionBasedTrigger
					basedOn: (PluggableConditionExample evaluating: [ :context | context isPreparedFor: 'Resting' ]))
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addThinkingToCodingTo: builder [

	self
		addTransitionNamed: 'Develop your ideas'
		from: 'Thinking'
		to: 'Coding'
		logging: 'Coding that which was thought'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addThinkingToIdleTo: builder [

	self
		addTransitionNamed: 'Take a break'
		from: 'Thinking'
		to: 'Idle'
		logging: 'Resting the brain'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> addTransitionNamed: aName from: aSourceStateName to: aDestinationStateName logging: aText to: aBuilder [

	aBuilder
		addTransitionNamed: aName
		fromStateNamed: aSourceStateName
		toStateNamed: aDestinationStateName
		allowedWhen:
			(PluggableConditionExample
				evaluating: [ :conditionContext | conditionContext isFocused not ])
		completedUsing: [ :context | eventHistory add: aText ]
		triggeredBy: (ConditionBasedTrigger basedOn: (PluggableConditionExample evaluating: [ false ]))
]

{ #category : #accessing }
WorkflowMachineExample >> allowedTransitions [

	^ machineSpec transitionsFrom: machine currentState allowedWithin: workflowContext
]

{ #category : #'private - workflow' }
WorkflowMachineExample >> configure: context toOpenDialogAndWhenAcceptedDo: completeCommand [

	^ context
		openDialogStating: 'Write down some ideas. Writing nothing won''t let you continue.'
		whenAccepted: [ :model | 
			self validateContentOf: model.
			completeCommand value ]
]

{ #category : #accessing }
WorkflowMachineExample >> currentState [

	^ machine currentState
]

{ #category : #initialization }
WorkflowMachineExample >> initializeEventHistory [

	eventHistory := OrderedCollection new
]

{ #category : #initialization }
WorkflowMachineExample >> initializeStateMachine [

	machine := StateMachine within: workflowContext inInitialStateFor: machineSpec
]

{ #category : #initialization }
WorkflowMachineExample >> initializeStateMachineSpecification [

	| builder |

	builder := StateMachineSpecificationBuilder new.
	self addStateNamed: 'Idle' to: builder.
	self addStateNamed: 'Thinking' to: builder.
	self addStateNamed: 'Coding' to: builder.
	self addStateNamed: 'Testing' to: builder.
	
	self addIdleToThinkingTo: builder.
	self addIdleToCodingTo: builder.
	self addIdleToTestingTo: builder.
	
	self addThinkingToCodingTo: builder.
	self addThinkingToIdleTo: builder.
	
	self addCodingToTestingTo: builder.
	
	self addTestingToCodingTo: builder.
	
	self addFocusLoopTo: builder.
	self addThinkDevelopTestIterationTo: builder.
	
	builder startFromStateNamed: 'Idle'.
	machineSpec := builder build
]

{ #category : #initialization }
WorkflowMachineExample >> initializeWithin: aContext [

	workflowContext := aContext.
	self initializeEventHistory.
	self initializeStateMachineSpecification.
	self initializeStateMachine
]

{ #category : #processing }
WorkflowMachineExample >> startTransitionTo: aStateName [

	^ machine startTransitionTo: aStateName
]

{ #category : #'private - processing' }
WorkflowMachineExample >> validateContentOf: aString [

	aString isEmpty
		ifTrue: [ AssertionFailed signal: 'It can''t be empty' ]
]

{ #category : #accessing }
WorkflowMachineExample >> withEventHistoryDo: aBlock [

	^ eventHistory do: aBlock
]
