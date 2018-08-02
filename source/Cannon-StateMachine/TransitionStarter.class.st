"
A Transitioner executes all the steps in order when going from one state in a state machine to another.
Rollbacks are executed when necessary.
"
Class {
	#name : #TransitionStarter,
	#superclass : #Object,
	#instVars : [
		'machineSpec',
		'externalContext'
	],
	#category : #'Cannon-StateMachine'
}

{ #category : #'instance creation' }
TransitionStarter class >> within: aContext for: aMachineSpec [

	^ self new initializeWithin: aContext for: aMachineSpec
]

{ #category : #initialization }
TransitionStarter >> initializeWithin: aContext for: aMachineSpec [

	externalContext := aContext.
	machineSpec := aMachineSpec
]

{ #category : #'private - processing' }
TransitionStarter >> signalNotAllowed: aTransition [

	TransitionFailed
		signal:
			('<1p> is not an allowed transition in the current context.'
				expandMacrosWith: aTransition)
]

{ #category : #processing }
TransitionStarter >> start: aTransition whenComplete: aCompleteBlock [

	(machineSpec is: aTransition allowedWithin: externalContext)
		ifTrue: [ self startAllowed: aTransition whenComplete: aCompleteBlock ]
		ifFalse: [ self signalNotAllowed: aTransition ]
]

{ #category : #'private - processing' }
TransitionStarter >> start: aTransition within: aTransitionContext whenComplete: aCompleteBlock [

	aTransition source exitAffecting: aTransitionContext.
	aTransition
		affect: aTransitionContext
		whenComplete: [ aTransition destination enterAffecting: aTransitionContext.
			aCompleteBlock value ]
]

{ #category : #'private - processing' }
TransitionStarter >> startAllowed: aTransition whenComplete: aCompleteBlock [

	| transitionContext |

	transitionContext := externalContext readyToStartTransition.
	self start: aTransition within: transitionContext whenComplete: aCompleteBlock
]

{ #category : #accessing }
TransitionStarter >> transitionsAllowedFrom: aState [

	^ machineSpec transitionsFrom: aState allowedWithin: externalContext
]
