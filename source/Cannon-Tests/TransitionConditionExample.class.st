"
A condition to be used for testing purposes in state machine transitions.
"
Class {
	#name : #TransitionConditionExample,
	#superclass : #Condition,
	#instVars : [
		'stream'
	],
	#category : #'Cannon-Tests'
}

{ #category : #'instance creation' }
TransitionConditionExample class >> readingFrom: aStream [

	^ self new initializeReadingFrom: aStream
]

{ #category : #initialization }
TransitionConditionExample >> initializeReadingFrom: aStream [

	stream := aStream
]

{ #category : #testing }
TransitionConditionExample >> isSatisfiedBy: aContext [

	^ stream contents beginsWith: 'Entering A<r>' expandMacros
]
