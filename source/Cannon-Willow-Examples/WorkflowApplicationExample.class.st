"
A Willow application that showcases a state machine and its transitions through web interaction.
"
Class {
	#name : #WorkflowApplicationExample,
	#superclass : #WillowApplication,
	#instVars : [
		'machineSpec',
		'transitioner',
		'identifiedContentView',
		'restartButton',
		'eventHistory'
	],
	#category : #'Cannon-Willow-Examples'
}

{ #category : #accessing }
WorkflowApplicationExample class >> applicationTitle [

	^ 'Workflow Example'
]

{ #category : #accessing }
WorkflowApplicationExample class >> handlerName [

	^ 'workflow-example'
]

{ #category : #accessing }
WorkflowApplicationExample class >> sessionClass [

	^ WorkflowSessionExample
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addCodingToTestingTo: builder [

	self
		addTransitionNamed: 'Run the test'
		from: 'Coding'
		to: 'Testing'
		logging: 'Test running'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addFocusLoopTo: builder [

	builder
		addTransitionNamed: 'Focus!'
		from: 'Idle'
		to: 'Idle'
		allowedWhen:
			(PluggableConditionExample
				evaluating: [ :conditionContext | conditionContext isFocused not ])
		doing: [ :context | 
			eventHistory add: 'Gaining focus'.
			context gainFocus ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ false ])
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addIdleToCodingTo: builder [

	self
		addTransitionNamed: 'Write some code'
		from: 'Idle'
		to: 'Coding'
		logging: 'Coding without thinking'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addIdleToTestingTo: builder [

	self
		addTransitionNamed: 'Check the current version'
		from: 'Idle'
		to: 'Testing'
		logging: 'Testing whatever is there'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addIdleToThinkingTo: aBuilder [

	aBuilder
		addTransitionNamed: 'Call for a brainstorming session'
		from: 'Idle'
		to: 'Thinking'
		allowedWhen:
			(PluggableConditionExample
				evaluating: [ :conditionContext | conditionContext isFocused not ])
		doing: [ :context :completeCommand | 
			eventHistory add: 'Brainstorming session called'.
			context openDialogToAccept: completeCommand ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ false ])
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addStateNamed: aName to: aBuilder [

	aBuilder
		addStateNamed: aName
		onEntry: [ :context :completeCommand | 
			eventHistory add: ('[+] <1s>' expandMacrosWith: aName).
			completeCommand value ]
		onExit: [ :context :completeCommand | 
			eventHistory add: ('[-] <1s>' expandMacrosWith: aName).
			completeCommand value ]
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addTestingToCodingTo: builder [

	self
		addTransitionNamed: 'Fix those tests!'
		from: 'Testing'
		to: 'Coding'
		logging: 'Fixing failed tests, or maybe writing new ones'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addThinkDevelopTestIterationTo: builder [

	builder
		addTransitionNamed: 'Think how to develop a test'
			from: 'Idle'
			to: 'Thinking'
			allowedWhen: (PluggableConditionExample evaluating: [ :conditionContext | conditionContext isFocused ])
			doing: [ :context :completeCommand | 
				eventHistory add: 'Thinking about the code of a test'.
				context goOn: 'Coding'.
				completeCommand value ]
			triggeredBy: (PluggableTriggerExample activatedWhen: [ false ]);
		addTransitionNamed: 'Think how to develop a test'
			from: 'Thinking'
			to: 'Coding'
			allowedWhen: (PluggableConditionExample evaluating: [ :conditionContext | conditionContext isFocused ])
			doing: [ :context :completeCommand | 
				eventHistory add: 'Coding a test'.
				context goOn: 'Testing'.
				completeCommand value ]
			triggeredBy: (PluggableTriggerExample activatedWhen: [ :context | context isPreparedFor: 'Coding' ]);
		addTransitionNamed: 'Test the test developed'
			from: 'Coding'
			to: 'Testing'
			allowedWhen: (PluggableConditionExample evaluating: [ :conditionContext | conditionContext isFocused ])
			doing: [ :context :completeCommand | 
				eventHistory add: 'Testing a test'.
				context goOn: 'Resting'.
				completeCommand value ]
			triggeredBy: (PluggableTriggerExample activatedWhen: [ :context | context isPreparedFor: 'Testing' ]);
		addTransitionNamed: 'Rest after a tested test'
			from: 'Testing'
			to: 'Idle'
			allowedWhen: (PluggableConditionExample evaluating: [ :conditionContext | conditionContext isFocused ])
			doing: [ :context :completeCommand | 
				eventHistory add: 'Resting with green tests'.
				context
					takeABreak;
					loseFocus.
				completeCommand value ]
			triggeredBy: (PluggableTriggerExample activatedWhen: [ :context | context isPreparedFor: 'Resting' ])
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addThinkingToCodingTo: builder [

	self
		addTransitionNamed: 'Develop your ideas'
		from: 'Thinking'
		to: 'Coding'
		logging: 'Coding that which was thought'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addThinkingToIdleTo: builder [

	self
		addTransitionNamed: 'Take a break'
		from: 'Thinking'
		to: 'Idle'
		logging: 'Resting the brain'
		to: builder
]

{ #category : #'private - workflow' }
WorkflowApplicationExample >> addTransitionNamed: aName from: aSourceStateName to: aDestinationStateName logging: aText to: aBuilder [

	aBuilder
		addTransitionNamed: aName
		from: aSourceStateName
		to: aDestinationStateName
		allowedWhen:
			(PluggableConditionExample
				evaluating: [ :conditionContext | conditionContext isFocused not ])
		doing: [ :context :completeCommand | 
			eventHistory add: aText.
			completeCommand value ]
		triggeredBy: (PluggableTriggerExample activatedWhen: [ false ])
]

{ #category : #accessing }
WorkflowApplicationExample >> componentSupplierForApplication [

	^ Html5ComponentSupplier new
]

{ #category : #accessing }
WorkflowApplicationExample >> contentView [

	^ identifiedContentView
]

{ #category : #initialization }
WorkflowApplicationExample >> initialRequest: aRequest [

	super initialRequest: aRequest.
	self initializeEventHistory.
	self initializeTransitioner.
	self initializeRestartButton.
]

{ #category : #initialization }
WorkflowApplicationExample >> initialize [

	super initialize.
	identifiedContentView := IdentifiedWebView
		forDivNamed: 'Content'
		containing: [ :canvas | self renderStateAndTransitionsOn: canvas ].
	self initializeStateMachineSpecification.
]

{ #category : #initialization }
WorkflowApplicationExample >> initializeEventHistory [

	eventHistory := OrderedCollection new
]

{ #category : #initialization }
WorkflowApplicationExample >> initializeRestartButton [

	restartButton := self componentSupplier
		asynchronicButtonLabeled: 'Start again'
		applying: [  ].
	restartButton onTrigger
		evaluate: [ self initializeEventHistory.
			self initializeTransitioner ];
		render: identifiedContentView
]

{ #category : #initialization }
WorkflowApplicationExample >> initializeStateMachineSpecification [

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
	
	builder declareAsInitialState: 'Idle'.
	machineSpec := builder build
]

{ #category : #initialization }
WorkflowApplicationExample >> initializeTransitioner [

	transitioner := WorkflowTransitioner
		within: self session
		inInitialStateFor: machineSpec
]

{ #category : #accessing }
WorkflowApplicationExample >> jQueryLibrary [

	^ (self deploymentMode libraryFor: JQuery3MetadataLibrary) default
]

{ #category : #'private - accessing' }
WorkflowApplicationExample >> linkForTransitionNamed: aTransitionName toStateNamed: aStateName [

	| link |

	link := self componentSupplier
		asynchronicLinkLabeled: aTransitionName
		applying: [ :theButton | 
			theButton
				setStyleTo: [ :style | 
					style
						cursor: #pointer;
						textDecoration: #underline;
						color: #blue ] ].
	link onTrigger
		determineBehaviorByEvaluating: [ :response | 
			self session
				configure: response
				afterEvaluating: [ transitioner startTransitionTo: aStateName ]
				renderingTo: identifiedContentView ].
	^ link
]

{ #category : #'private - rendering' }
WorkflowApplicationExample >> render: candidates asOptionsOn: aCanvas [

	candidates
		ifEmpty: [ aCanvas render: 'Dead end' ]
		ifNotEmpty: [ aCanvas render: 'Your options are:'.
			(self sortedAssociationsFrom: candidates)
				do:
					[ :association | self renderLinkFor: association value labeled: association key on: aCanvas ] ]
]

{ #category : #'private - rendering' }
WorkflowApplicationExample >> renderEventHistoryOn: aCanvas [

	aCanvas
		paragraph: [ aCanvas render: 'These are the events so far'.
			aCanvas unorderedList: [ eventHistory do: [ :event | aCanvas listItem: event ] ] ]
]

{ #category : #'private - rendering' }
WorkflowApplicationExample >> renderLinkFor: aTransitionSpec labeled: aName on: aCanvas [

	aCanvas
		div: (self linkForTransitionNamed: aName toStateNamed: aTransitionSpec destination name)
]

{ #category : #'private - rendering' }
WorkflowApplicationExample >> renderOptionsSectionOn: aCanvas [

	| candidates |

	aCanvas
		div: [ candidates := machineSpec
				transitionsFrom: transitioner currentState
				allowedWithin: self session.
			self render: candidates asOptionsOn: aCanvas ]
]

{ #category : #'private - rendering' }
WorkflowApplicationExample >> renderStateAndTransitionsOn: aCanvas [

	aCanvas
		paragraph: [ aCanvas
				render: 'Current State: ';
				strong: transitioner currentState name ].
	self renderOptionsSectionOn: aCanvas.
	self renderEventHistoryOn: aCanvas.
	aCanvas paragraph: restartButton
]

{ #category : #'private - accessing' }
WorkflowApplicationExample >> sortedAssociationsFrom: candidates [

	^ (candidates
		collect: [ :transitionSpec | 
			transitionSpec
				withNameDo: [ :transitionName | transitionName -> transitionSpec ]
				ifUnnamed: [ Error signal: 'Unnamed transition found' ] ])
		sorted: [ :a :b | a key < b key ]
]
