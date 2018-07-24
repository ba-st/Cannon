"
The result of attempting a transaction in a state machine.
"
Class {
	#name : #TransitionResult,
	#superclass : #Object,
	#category : #'Cannon-StateMachine'
}

{ #category : #accessing }
TransitionResult >> context [

	^ self subclassResponsibility
]

{ #category : #accessing }
TransitionResult >> currentState [

	^ self subclassResponsibility
]

{ #category : #processing }
TransitionResult >> ifComplete: aCompleteBlock ifAborted: anAbortBlock [

	^ self subclassResponsibility
]
