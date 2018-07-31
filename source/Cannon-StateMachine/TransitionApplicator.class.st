"
A Transitioner executes all the steps in order when going from one state in a state machine to another.
Rollbacks are executed when necessary.
"
Class {
	#name : #TransitionApplicator,
	#superclass : #Object,
	#instVars : [
		'machineSpec',
		'externalContext'
	],
	#category : #'Cannon-StateMachine-Cannon-StateMachine'
}

{ #category : #'instance creation' }
TransitionApplicator class >> within: aContext for: aMachineSpec [

	^ self new initializeWithin: aContext for: aMachineSpec
]

{ #category : #'private - accessing' }
TransitionApplicator >> affectCommandFor: aTransitionSpec within: aTransitionContext whenComplete: aCompleteBlock [

	^ [ aTransitionSpec
		affect: aTransitionContext
		whenComplete:
			(self
				entryCommandFor: aTransitionSpec destination
				within: aTransitionContext
				whenComplete: aCompleteBlock) ]
]

{ #category : #accessing }
TransitionApplicator >> allowedTransitionsFrom: aStateSpec [

	^ machineSpec transitionsFrom: aStateSpec allowedWithin: externalContext
]

{ #category : #'private - processing' }
TransitionApplicator >> because: aTransitionSpec couldNotBeCompletedWithin: aTransitionContext dueTo: aSignal evaluate: anAbortedBlock [

	anAbortedBlock
		value: aTransitionSpec source
		value: aTransitionContext
		value:
			('<1p> could not be completed because <2s>.'
				expandMacrosWith: aTransitionSpec
				with: aSignal messageText)
]

{ #category : #'private - processing' }
TransitionApplicator >> because: aTransitionSpec isNotAllowedEvaluate: anAbortedBlock [

	anAbortedBlock
		value: aTransitionSpec source
		value: (externalContext readyToApply: aTransitionSpec of: machineSpec)
		value:
			('<1p> is not an allowed transition in the current context.'
				expandMacrosWith: aTransitionSpec)
]

{ #category : #'private - processing' }
TransitionApplicator >> becauseMultipleTriggersShouldBeActivatedFrom: aStateSpec within: aTransitionContext evaluate: anAbortedBlock [

	anAbortedBlock
		value: aStateSpec
		value: aTransitionContext
		value: ('Expected at most one active trigger at <1p>.' expandMacrosWith: aStateSpec)
]

{ #category : #'private - processing' }
TransitionApplicator >> considerTriggersAt: aStateSpec within: aTransitionContext whenComplete: aCompleteBlock ifAborted: anAbortedBlock [

	| candidates |

	candidates := self transitionsAt: aStateSpec toTriggerWithin: aTransitionContext.
	self
		with: candidates
		ifEmpty: [ aCompleteBlock value: aStateSpec value: aTransitionContext ]
		ifSingle: [ self
				startAllowed: candidates anyOne
				whenComplete: aCompleteBlock
				ifAborted: anAbortedBlock ]
		ifMultiple: [ self
				becauseMultipleTriggersShouldBeActivatedFrom: aStateSpec
				within: aTransitionContext
				evaluate: anAbortedBlock ]
]

{ #category : #'private - accessing' }
TransitionApplicator >> entryCommandFor: aStateSpec within: aTransitionContext whenComplete: aCompleteBlock [

	^ [ aStateSpec enterAffecting: aTransitionContext whenComplete: aCompleteBlock ]
]

{ #category : #initialization }
TransitionApplicator >> initializeWithin: aContext for: aMachineSpec [

	externalContext := aContext.
	machineSpec := aMachineSpec
]

{ #category : #processing }
TransitionApplicator >> start: aTransitionSpec whenComplete: aCompleteBlock ifAborted: anAbortedBlock [

	(machineSpec is: aTransitionSpec allowedWithin: externalContext)
		ifTrue:
			[ self startAllowed: aTransitionSpec whenComplete: aCompleteBlock ifAborted: anAbortedBlock ]
		ifFalse: [ self because: aTransitionSpec isNotAllowedEvaluate: anAbortedBlock ]
]

{ #category : #'private - processing' }
TransitionApplicator >> start: aTransitionSpec within: aTransitionContext whenComplete: aCompleteBlock [

	aTransitionSpec source
		exitAffecting: aTransitionContext
		whenComplete:
			(self
				affectCommandFor: aTransitionSpec
				within: aTransitionContext
				whenComplete: aCompleteBlock)
]

{ #category : #'private - processing' }
TransitionApplicator >> start: aTransitionSpec within: aTransitionContext whenComplete: aCompleteBlock ifAborted: anAbortedBlock [

	[ self start: aTransitionSpec within: aTransitionContext whenComplete: aCompleteBlock ]
		on: Error
		do: [ :aSignal | 
			self
				because: aTransitionSpec
				couldNotBeCompletedWithin: aTransitionContext
				dueTo: aSignal
				evaluate: anAbortedBlock ]
]

{ #category : #'private - processing' }
TransitionApplicator >> startAllowed: aTransitionSpec whenComplete: aCompleteBlock ifAborted: anAbortedBlock [

	| transitionContext |

	transitionContext := externalContext readyToApply: aTransitionSpec of: machineSpec.
	self
		start: aTransitionSpec
		within: transitionContext
		whenComplete: [ self
				considerTriggersAt: aTransitionSpec destination
				within: transitionContext
				whenComplete: aCompleteBlock
				ifAborted: anAbortedBlock ]
		ifAborted: anAbortedBlock
]

{ #category : #'private - accessing' }
TransitionApplicator >> transitionsAt: aStateSpec toTriggerWithin: aTransitionContext [

	^ (self allowedTransitionsFrom: aStateSpec)
		select: [ :transition | transition shouldBeTriggeredWithin: aTransitionContext ]
]

{ #category : #'private - processing' }
TransitionApplicator >> with: aCollection ifEmpty: anEmptyBlock ifSingle: aSingleBlock ifMultiple: aMultipleBlock [

	aCollection isEmpty
		ifTrue: [ ^ anEmptyBlock value ].
	aCollection size = 1
		ifTrue: [ ^ aSingleBlock value ].
	^ aMultipleBlock value
]
