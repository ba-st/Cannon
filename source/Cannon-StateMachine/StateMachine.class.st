"
This transitioner encapsulates the steps required when changing from one state to another. It can also be instructued to perform the transition to the initial state.
"
Class {
	#name : #StateMachine,
	#superclass : #Object,
	#instVars : [
		'currentState',
		'transitionStarter',
		'externalContext'
	],
	#category : #'Cannon-StateMachine'
}

{ #category : #'instance creation' }
StateMachine class >> within: aContext for: aMachineSpec in: aStateName [

	^ self new initializeWithin: aContext for: aMachineSpec in: aStateName
]

{ #category : #'instance creation' }
StateMachine class >> within: anExternalContext inInitialStateFor: aMachineSpec [

	| machine |

	aMachineSpec initialState enterAffecting: anExternalContext.
	machine := self
		within: anExternalContext
		for: aMachineSpec
		in: aMachineSpec initialState name.
	machine evaluateTriggers.
	^ machine
]

{ #category : #accessing }
StateMachine >> currentState [

	^ currentState
]

{ #category : #'private - processing' }
StateMachine >> evaluateTriggers [

	| candidates |

	candidates := self transitionsToTrigger.
	candidates size > 1
		ifTrue: [ self signalMultipleTriggersFound ].
	candidates size = 1
		ifTrue: [ self updateStateWhenCompleted: candidates anyOne ]
]

{ #category : #initialization }
StateMachine >> initializeWithin: aContext for: aMachineSpec in: aStateName [

	currentState := aMachineSpec
		stateNamed: aStateName
		ifNone: [ InstanceCreationFailed signal: ('No state is named <1s>' expandMacrosWith: aStateName) ].
	externalContext := aContext.
	transitionStarter := TransitionStarter within: aContext for: aMachineSpec
]

{ #category : #'private - processing' }
StateMachine >> signal: aNumber transitionsFoundTo: aStateName [

	TransitionFailed
		signal:
			('Expected single transition from <1s> to <2s> but found <3p>.'
				expandMacrosWith: self currentState name
				with: aStateName
				with: aNumber)
]

{ #category : #'private - processing' }
StateMachine >> signalMultipleTriggersFound [

	TransitionFailed
		signal: ('Expected at most one active trigger at <1p>.' expandMacrosWith: self currentState)
]

{ #category : #processing }
StateMachine >> startTransitionTo: aStateName [

	| candidates |

	candidates := (transitionStarter transitionsAllowedFrom: self currentState)
		select: [ :transition | transition destination name = aStateName ].

	candidates size = 1
		ifTrue: [ self updateStateWhenCompleted: candidates anyOne ]
		ifFalse: [ self signal: candidates size transitionsFoundTo: aStateName ]
]

{ #category : #'private - accessing' }
StateMachine >> transitionsToTrigger [

	^ (transitionStarter transitionsAllowedFrom: self currentState)
		select: [ :transition | transition shouldBeTriggeredWithin: externalContext ]
]

{ #category : #'private - processing' }
StateMachine >> updateStateWhenCompleted: aTransition [

	transitionStarter
		start: aTransition
		whenComplete: [ currentState := aTransition destination.
			self evaluateTriggers ]
]
