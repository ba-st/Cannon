"
Represents the case of a failed transition. The current state is still the source of the transition attempted. The reason for aborting is also registered.
"
Class {
	#name : #TransitionAborted,
	#superclass : #TransitionResult,
	#instVars : [
		'reason',
		'context',
		'currentState'
	],
	#category : #'Cannon-StateMachine'
}

{ #category : #'instance creation' }
TransitionAborted class >> becauseOf: aReason stayingAt: aStateSpecification within: aContext [

	^ self new initializeBecauseOf: aReason stayingAt: aStateSpecification within: aContext
]

{ #category : #accessing }
TransitionAborted >> context [

	^ context
]

{ #category : #accessing }
TransitionAborted >> currentState [

	^ currentState
]

{ #category : #processing }
TransitionAborted >> ifComplete: aCompleteBlock ifAborted: anAbortBlock [

	^ anAbortBlock cull: reason
]

{ #category : #initialization }
TransitionAborted >> initializeBecauseOf: aReason stayingAt: aStateSpecification within: aContext [

	reason := aReason.
	currentState := aStateSpecification.
	context := aContext
]
