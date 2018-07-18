"
A transition trigger is a type of event that could indicate a transition in a state machine must be activated.
This is an abstract class that must defined different situations (manual, always triggered, defined by external notifications, etc.).
"
Class {
	#name : #TransitionTrigger,
	#superclass : #Object,
	#category : #Cannon
}

{ #category : #testing }
TransitionTrigger >> isActivatedBy: aContext [

	self subclassResponsibility
]
