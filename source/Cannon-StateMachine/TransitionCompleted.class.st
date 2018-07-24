"
Represents the case of a complete transition. The current state is now the destination state.
"
Class {
	#name : #TransitionCompleted,
	#superclass : #TransitionResult,
	#instVars : [
		'currentState',
		'context'
	],
	#category : #'Cannon-StateMachine'
}

{ #category : #'instance creation' }
TransitionCompleted class >> reaching: aStateSpecification within: aContext [

	^ self new initializeReaching: aStateSpecification within: aContext
]

{ #category : #accessing }
TransitionCompleted >> context [

	^ context
]

{ #category : #accessing }
TransitionCompleted >> currentState [

	^ currentState
]

{ #category : #processing }
TransitionCompleted >> ifComplete: aCompleteBlock ifAborted: anAbortBlock [

	^ aCompleteBlock value
]

{ #category : #initialization }
TransitionCompleted >> initializeReaching: aStateSpecification within: aContext [

	currentState := aStateSpecification.
	context := aContext
]
