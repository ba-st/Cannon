"
A pluggable trigger that receives a block which determined when it will be activated.
"
Class {
	#name : #ConditionBasedTrigger,
	#superclass : #TransitionTrigger,
	#instVars : [
		'condition'
	],
	#category : #'Cannon-StateMachine'
}

{ #category : #'instance creation' }
ConditionBasedTrigger class >> basedOn: aCondition [

	^ self new initializeBasedOn: aCondition
]

{ #category : #initialization }
ConditionBasedTrigger >> initializeBasedOn: aCondition [

	condition := aCondition
]

{ #category : #testing }
ConditionBasedTrigger >> isActivatedBy: aContext [

	^ condition isSatisfiedBy: aContext
]
