"
A Transitioner executes all the steps in order when going from one state in a state machine to another.
Rollbacks are executed when necessary.
"
Class {
	#name : #StateMachineTransitioner,
	#superclass : #Object,
	#category : #Cannon
}

{ #category : #'private - processing' }
StateMachineTransitioner >> affectTriggersAndApply: aTransitionSpecification of: aStateMachineSpecification within: context [

	[ self apply: aTransitionSpecification within: context ]
		on: Error
		do: [ :aSignal | self handle: aSignal whileApplying: aTransitionSpecification ].

	self
		applyTriggersAt: aTransitionSpecification destination
		of: aStateMachineSpecification
		within: context
]

{ #category : #processing }
StateMachineTransitioner >> apply: aTransitionSpecification of: aStateMachineSpecification [

	| context |

	context := self
		contextReadyToApply: aTransitionSpecification
		of: aStateMachineSpecification.
	self check: aTransitionSpecification isAllowedWithin: context.
	self
		affectTriggersAndApply: aTransitionSpecification
		of: aStateMachineSpecification
		within: context.
	^ context
]

{ #category : #'private - processing' }
StateMachineTransitioner >> apply: aTransitionSpecification within: context [

	aTransitionSpecification source exitAffecting: context.
	aTransitionSpecification affect: context.
	aTransitionSpecification destination enterAffecting: context
]

{ #category : #'private - processing' }
StateMachineTransitioner >> applyTriggersAt: aStateSpecification of: aStateMachineSpecification within: aContext [

	| candidates |

	candidates := (aStateMachineSpecification
		transitionsFrom: aStateSpecification
		allowedWithin: aContext)
		select: [ :transition | transition shouldBeTriggeredWithin: aContext ].

	candidates size > 1
		ifTrue: [ TransitionFailed
				signal: ('Expected at most one active trigger at <1p>.' expandMacrosWith: aStateSpecification) ].

	candidates size = 1
		ifTrue: [ self apply: candidates anyOne of: aStateMachineSpecification ]
]

{ #category : #'private - preconditions' }
StateMachineTransitioner >> check: aTransitionSpecification isAllowedWithin: context [

	AssertionChecker
		enforce: [ aTransitionSpecification isAllowedWithin: context ]
		because:
			('<1p> is not an allowed transition in the current context.'
				expandMacrosWith: aTransitionSpecification)
		raising: TransitionFailed
]

{ #category : #'private - accessing' }
StateMachineTransitioner >> contextReadyToApply: aTransitionSpecification of: aStateMachineSpecification [

	^ aStateMachineSpecification contextBuilder readyFor: aStateMachineSpecification
]

{ #category : #'private - processing' }
StateMachineTransitioner >> handle: aSignal whileApplying: aTransitionSpecification [

	TransitionFailed
		signal:
			('<1p> could not be completed because <2s>.'
				expandMacrosWith: aTransitionSpecification
				with: aSignal messageText)
]
