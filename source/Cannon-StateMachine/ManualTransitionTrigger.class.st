"
A manual trigger is never activated. The transition must be executed explicitly by the state machine in which it is defined.
"
Class {
	#name : #ManualTransitionTrigger,
	#superclass : #TransitionTrigger,
	#category : #'Cannon-StateMachine'
}

{ #category : #testing }
ManualTransitionTrigger >> isActivatedBy: aContext [

	^ false
]
