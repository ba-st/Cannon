"
The session to be used in the Willow example that uses Cannon workflow components.
"
Class {
	#name : #WorkflowSessionExample,
	#superclass : #WillowSession,
	#instVars : [
		'rollbacks',
		'stateMachineSpecificationBinding',
		'nextActivityOptional',
		'isFocused',
		'interactions'
	],
	#category : #'Cannon-Willow-Examples'
}

{ #category : #interaction }
WorkflowSessionExample >> configure: aResponse afterEvaluating: aBlock renderingTo: anIdentifiedView [

	aBlock value.
	interactions do: [ :interaction | interaction value: aResponse value: anIdentifiedView ].
	aResponse onReturn render: anIdentifiedView
]

{ #category : #'private - accessing' }
WorkflowSessionExample >> dialogCommandsFor: theDialog [

	^ (theDialog
		setStyleTo: [ :style | 
			style
				width: 300 px;
				height: 100 px;
				position: #absolute;
				top: 50 px ]) + (theDialog setAttribute: 'open' to: true)
]

{ #category : #processing }
WorkflowSessionExample >> gainFocus [

	isFocused := true
]

{ #category : #processing }
WorkflowSessionExample >> goOn: anActivity [

	nextActivityOptional := Optional containing: anActivity
]

{ #category : #initialization }
WorkflowSessionExample >> initialize [

	super initialize.
	self resetRollbacks.
	self takeABreak.
	self loseFocus.
	self resetInteractions
]

{ #category : #testing }
WorkflowSessionExample >> isFocused [

	^ isFocused
]

{ #category : #testing }
WorkflowSessionExample >> isPreparedFor: anActivity [

	^ nextActivityOptional withContentDo: [ :activity | activity = anActivity ] ifUnused: [ false ]
]

{ #category : #processing }
WorkflowSessionExample >> loseFocus [

	isFocused := false
]

{ #category : #interaction }
WorkflowSessionExample >> openDialogToAccept: aBlock [

	interactions
		add: [ :response :identifiedView | 
			response onReturn
				open: [ :canvas | 
					canvas dialog
						apply: [ :theDialog | self dialogCommandsFor: theDialog ];
						with: [ self renderDialogToAccept: aBlock thenRender: identifiedView on: canvas ] ] ]
]

{ #category : #processing }
WorkflowSessionExample >> readyToApply: aTransitionSpecification of: aStateMachineSpecification [

	stateMachineSpecificationBinding := Binding to: aStateMachineSpecification.
	self resetRollbacks.
	self resetInteractions
]

{ #category : #interaction }
WorkflowSessionExample >> renderDialogToAccept: aBlock thenRender: identifiedView on: aCanvas [

	| button |

	button := self componentSupplier asynchronicButtonLabeled: 'Ready' applying: [  ].
	button onTrigger
		evaluate: aBlock;
		render: identifiedView.
	aCanvas
		span: 'List some initial ideas';
		textArea;
		render: button
]

{ #category : #processing }
WorkflowSessionExample >> resetInteractions [

	interactions := OrderedCollection new
]

{ #category : #initialization }
WorkflowSessionExample >> resetRollbacks [

	rollbacks := OrderedCollection new
]

{ #category : #accessing }
WorkflowSessionExample >> stateMachineSpec [

	^ stateMachineSpecificationBinding content
]

{ #category : #processing }
WorkflowSessionExample >> takeABreak [

	nextActivityOptional := Optional unused
]
