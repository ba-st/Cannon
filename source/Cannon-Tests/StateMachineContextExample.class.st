"
A state machine context to be used for testing purposes.
"
Class {
	#name : #StateMachineContextExample,
	#superclass : #Object,
	#instVars : [
		'machine'
	],
	#category : #'Cannon-Tests'
}

{ #category : #'instance creation' }
StateMachineContextExample class >> readyFor: aStateMachineSpecification [

	^ self new initializeReadyFor: aStateMachineSpecification
]

{ #category : #initialization }
StateMachineContextExample >> initializeReadyFor: aStateMachineSpecification [

	machine := aStateMachineSpecification
]
