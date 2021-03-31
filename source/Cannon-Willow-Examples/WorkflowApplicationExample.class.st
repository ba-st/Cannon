"
A Willow application that showcases a state machine and its transitions through web interaction.
"
Class {
	#name : #WorkflowApplicationExample,
	#superclass : #WillowApplication,
	#instVars : [
		'identifiedContentView',
		'restartButton',
		'machine'
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
	identifiedContentView := self componentSupplier
		divisionContainerWrapping: [ :html | self renderStateAndTransitionsOn: html ]
		applying: [  ].
	self initializeStateMachine.
	self initializeRestartButton
]

{ #category : #initialization }
WorkflowApplicationExample >> initializeRestartButton [

	restartButton := self componentSupplier asynchronicButtonLabeled: 'Start again' applying: [  ].
	restartButton on trigger
		serverDo: [ self initializeStateMachine ];
		render: identifiedContentView
]

{ #category : #initialization }
WorkflowApplicationExample >> initializeStateMachine [

	machine := WorkflowMachineExample within: self session
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
						color: #blue
					]
			].
	link on trigger
		serverDo: [ :request | 
			self session
				configure: request
				afterEvaluating: [ machine startTransitionTo: aStateName ]
				renderingTo: identifiedContentView
			].
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
			aCanvas unorderedList: [ machine withEventHistoryDo: [ :event | aCanvas listItem: event ] ] ]
]

{ #category : #'private - rendering' }
WorkflowApplicationExample >> renderLinkFor: aTransition labeled: aName on: aCanvas [

	aCanvas
		div: (self linkForTransitionNamed: aName toStateNamed: aTransition destination name)
]

{ #category : #'private - rendering' }
WorkflowApplicationExample >> renderOptionsSectionOn: aCanvas [

	aCanvas div: [ self render: machine allowedTransitions asOptionsOn: aCanvas ]
]

{ #category : #'private - rendering' }
WorkflowApplicationExample >> renderStateAndTransitionsOn: aCanvas [

	aCanvas
		paragraph: [ aCanvas
				render: 'Current State: ';
				strong: machine currentState name ].
	self renderOptionsSectionOn: aCanvas.
	self renderEventHistoryOn: aCanvas.
	aCanvas paragraph: restartButton
]

{ #category : #'private - accessing' }
WorkflowApplicationExample >> sortedAssociationsFrom: candidates [

	^ (candidates collect: [ :transition | transition name -> transition ])
		sorted: [ :a :b | a key < b key ]
]
