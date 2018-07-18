"
A ManualTransitionTriggerTest is a test class for testing the behavior of ManualTransitionTrigger
"
Class {
	#name : #ManualTransitionTriggerTest,
	#superclass : #TestCase,
	#category : #'Cannon-Tests'
}

{ #category : #tests }
ManualTransitionTriggerTest >> testIsActivatedBy [

	self deny: (ManualTransitionTrigger new isActivatedBy: self)
]
