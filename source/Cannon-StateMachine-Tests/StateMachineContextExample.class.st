"
A state machine context to be used for testing purposes.
"
Class {
	#name : #StateMachineContextExample,
	#superclass : #Object,
	#instVars : [
		'machine',
		'stateMachineBinding'
	],
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #initialization }
StateMachineContextExample >> initialize [

	stateMachineBinding := Binding undefinedExplainedBy: 'No machine has been indicated yet'
]

{ #category : #processing }
StateMachineContextExample >> readyToApply: aTransitionSpecification of: aStateMachineSpecification [

	stateMachineBinding := Binding to: aStateMachineSpecification
]

{ #category : #accessing }
StateMachineContextExample >> stateMachineSpec [

	^ stateMachineBinding content
]
