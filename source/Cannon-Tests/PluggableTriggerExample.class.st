"
A pluggable trigger that receives a block which determined when it will be activated.
"
Class {
	#name : #PluggableTriggerExample,
	#superclass : #TransitionTrigger,
	#instVars : [
		'activationBlock'
	],
	#category : #'Cannon-Tests'
}

{ #category : #'instance creation' }
PluggableTriggerExample class >> activatedWhen: anActivationBlock [

	^ self new initializeActivatedWhen: anActivationBlock
]

{ #category : #initialization }
PluggableTriggerExample >> initializeActivatedWhen: anActivationBlock [

	activationBlock := anActivationBlock
]

{ #category : #testing }
PluggableTriggerExample >> isActivatedBy: aContext [

	^ activationBlock cull: aContext
]
