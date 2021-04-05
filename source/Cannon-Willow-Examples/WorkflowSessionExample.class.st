"
The session to be used in the Willow example that uses Cannon workflow components.
"
Class {
	#name : #WorkflowSessionExample,
	#superclass : #WillowSession,
	#instVars : [
		'rollbacks',
		'nextActivityOptional',
		'isFocused',
		'interactions'
	],
	#category : #'Cannon-Willow-Examples'
}

{ #category : #'private - interaction' }
WorkflowSessionExample >> applyVisualStylesTo: style [

	| color |

	color := CssRGBColor
		red: 122
		green: 125
		blue: 167
		alpha: 0.72.

	style
		textAlign: #center;
		width: 30 vw;
		height: 30 vh;
		position: #absolute;
		top: 0 px;
		margin: 0;
		padding: 0;
		borderTop: (Array with: 35 vh with: #solid with: color);
		borderBottom: (Array with: 35 vh with: #solid with: color);
		borderLeft: (Array with: 35 vw with: #solid with: color);
		borderRight: (Array with: 35 vw with: #solid with: color);
		background: color;
		display: #grid
]

{ #category : #'private - interaction' }
WorkflowSessionExample >> buttonToAccept: aBlock thenRender: identifiedView [

	| button |

	button := self componentSupplier asynchronicButtonLabeled: 'Ok' applying: [  ].
	button on trigger
		with: ( JSStream on: '$("textarea").val()' )
		serverDo: [ :request | 
			self
				configure: request
				toEvaluate: aBlock
				with: request parameter
				thenRender: identifiedView
			].
	^ button
]

{ #category : #'private - interaction' }
WorkflowSessionExample >> buttonToCancelThenRender: anIdentifiedView [

	| button |

	button := self componentSupplier asynchronicButtonLabeled: 'Cancel' applying: [  ].
	self configure: button on trigger toCloseDialogsThenRender: anIdentifiedView.
	^ button
]

{ #category : #interaction }
WorkflowSessionExample >> configure: request afterEvaluating: aBlock renderingTo: anIdentifiedView [

	aBlock value.
	interactions do: [ :interaction | interaction value: request value: anIdentifiedView ].
	request onRespond render: anIdentifiedView
]

{ #category : #'private - interaction' }
WorkflowSessionExample >> configure: anInteraction toCloseDialogsThenRender: identifiedView [

	^ anInteraction
		userAgentDo: [ :canvas | ( canvas jQuery with: 'dialog' ) remove ];
		userAgentDo:
				[ :canvas | ( ( canvas jQuery class: Willow classification >> #dialogContainer ) children: 'script' ) remove ];
		render: identifiedView
]

{ #category : #'private - interaction' }
WorkflowSessionExample >> configure: request toEvaluate: aBlock with: aModel thenRender: anIdentifiedView [

	^ [ aBlock value: aModel.
	self configure: request onRespond toCloseDialogsThenRender: anIdentifiedView ]
		on: AssertionFailed
		do: [ :aSignal | 
			request onRespond inform: aSignal messageText.
			aSignal return ]
]

{ #category : #'private - accessing' }
WorkflowSessionExample >> dialogCommandsFor: theDialog [

	^ theDialog setStyleTo: [ :style | self applyVisualStylesTo: style ]
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
WorkflowSessionExample >> openDialogStating: aMessage whenAccepted: aCompleteBlock [

	interactions
		add: [ :request :identifiedView | 
			request onRespond
				open: [ :canvas | 
					canvas dialog
						apply: [ :theDialog | self dialogCommandsFor: theDialog ];
						with: [ self
								renderDialogStating: aMessage
								whenAcceptedDo: aCompleteBlock
								thenRender: identifiedView
								on: canvas ] ] ]
]

{ #category : #processing }
WorkflowSessionExample >> readyToStartTransition [

	self resetRollbacks.
	self resetInteractions
]

{ #category : #'private - interaction' }
WorkflowSessionExample >> renderDialogStating: aMessage whenAcceptedDo: aCompleteBlock thenRender: anIdentifiedView on: aCanvas [

	(aMessage substrings: '.') do: [ :sentence | aCanvas span: sentence ].
	aCanvas
		textArea;
		render: (self buttonToAccept: aCompleteBlock thenRender: anIdentifiedView);
		render: (self buttonToCancelThenRender: anIdentifiedView)
]

{ #category : #'private - interaction' }
WorkflowSessionExample >> resetInteractions [

	interactions := OrderedCollection new
]

{ #category : #initialization }
WorkflowSessionExample >> resetRollbacks [

	rollbacks := OrderedCollection new
]

{ #category : #processing }
WorkflowSessionExample >> takeABreak [

	nextActivityOptional := Optional unused
]
