"
Example Context to be used in the Workflow protocol of Cannon.
"
Class {
	#name : #WorkflowContextExample,
	#superclass : #Object,
	#instVars : [
		'user',
		'date',
		'trader',
		'settlementDate',
		'rollbacks'
	],
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #'instance creation' }
WorkflowContextExample class >> for: aUserName on: aDate managingTradeOf: aTrader expectedToSettleOn: aSettlementDate [

	^ self new
		initializeFor: aUserName
		on: aDate
		managingTradeOf: aTrader
		expectedToSettleOn: aSettlementDate
]

{ #category : #processing }
WorkflowContextExample >> applyRollback [

	rollbacks reverseDo: [ :command | command value ]
]

{ #category : #accessing }
WorkflowContextExample >> currentDate [

	^ date
]

{ #category : #accessing }
WorkflowContextExample >> expectedSettlementDate [

	^ settlementDate
]

{ #category : #processing }
WorkflowContextExample >> inCaseOfRollback: aBlockClosure [

	rollbacks add: aBlockClosure
]

{ #category : #initialization }
WorkflowContextExample >> initializeFor: aUserName on: aDate managingTradeOf: aTrader expectedToSettleOn: aSettlementDate [

	user := aUserName.
	date := aDate.
	trader := aTrader.
	settlementDate := aSettlementDate.

	self resetRollbacks 
]

{ #category : #accessing }
WorkflowContextExample >> loggedUser [

	^ user
]

{ #category : #processing }
WorkflowContextExample >> readyToStartTransition [

	self resetRollbacks
]

{ #category : #initialization }
WorkflowContextExample >> resetRollbacks [

	rollbacks := OrderedCollection new
]

{ #category : #accessing }
WorkflowContextExample >> tradeOriginator [

	^ trader
]
