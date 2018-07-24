"
A Transitioner executes all the steps in order when going from one state in a state machine to another.
Rollbacks are executed when necessary.
"
Class {
	#name : #TransitionApplicator,
	#superclass : #Object,
	#category : #'Cannon-StateMachine-Cannon-StateMachine'
}

{ #category : #'private - accessing' }
TransitionApplicator >> aborted: aTransitionSpec of: aMachineSpec notAllowedWithin: anExternalContext [

	^ TransitionAborted
		becauseOf:
			('<1p> is not an allowed transition in the current context.'
				expandMacrosWith: aTransitionSpec)
		stayingAt: aTransitionSpec source
		within: (anExternalContext readyToApply: aTransitionSpec of: aMachineSpec)
]

{ #category : #'private - accessing' }
TransitionApplicator >> aborted: aTransitionSpec within: aContext dueTo: aSignal [

	^ TransitionAborted
		becauseOf:
			('<1p> could not be completed because <2s>.'
				expandMacrosWith: aTransitionSpec
				with: aSignal messageText)
		stayingAt: aTransitionSpec source
		within: aContext
]

{ #category : #'private - accessing' }
TransitionApplicator >> abortedDueToMultipleTriggersConsidering: aResult [

	^ TransitionAborted
		becauseOf: ('Expected at most one active trigger at <1p>.' expandMacrosWith: aResult currentState)
		stayingAt: aResult currentState
		within: aResult context
]

{ #category : #processing }
TransitionApplicator >> apply: aTransitionSpec of: aMachineSpec within: anExternalContext [

	^ (aMachineSpec is: aTransitionSpec allowedWithin: anExternalContext)
		ifTrue: [ self applyAllowed: aTransitionSpec of: aMachineSpec within: anExternalContext ]
		ifFalse: [ self aborted: aTransitionSpec of: aMachineSpec notAllowedWithin: anExternalContext ]
]

{ #category : #'private - processing' }
TransitionApplicator >> apply: aTransitionSpec within: aContext [

	aTransitionSpec source exitAffecting: aContext.
	aTransitionSpec affect: aContext.
	aTransitionSpec destination enterAffecting: aContext
]

{ #category : #'private - processing' }
TransitionApplicator >> applyAllowed: aTransitionSpec of: aMachineSpec within: anExternalContext [

	| context transitionResult |

	context := anExternalContext readyToApply: aTransitionSpec of: aMachineSpec.
	transitionResult := self resultOfApplying: aTransitionSpec within: context.
	^ transitionResult
		ifComplete: [ self resultAfterTriggersConsidering: transitionResult within: anExternalContext ]
		ifAborted: [ transitionResult ]
]

{ #category : #processing }
TransitionApplicator >> applyInitialTransitionOf: aMachineSpec within: anExternalContext [

	^ self
		applyAllowed: (self transitionToInitialStateOf: aMachineSpec)
		of: aMachineSpec
		within: anExternalContext
]

{ #category : #'private - processing' }
TransitionApplicator >> resultAfterTriggersConsidering: aResult within: anExternalContext [

	| candidates |

	candidates := self transitionsToTriggerConsidering: aResult within: anExternalContext.
	candidates size > 1
		ifTrue: [ ^ self abortedDueToMultipleTriggersConsidering: aResult ].
	candidates size = 1
		ifTrue: [ ^ self
				apply: candidates anyOne
				of: aResult context stateMachine
				within: anExternalContext ].
	^ aResult
]

{ #category : #'private - processing' }
TransitionApplicator >> resultOfApplying: aTransitionSpec within: context [

	^ [ self apply: aTransitionSpec within: context.
	TransitionCompleted reaching: aTransitionSpec destination within: context ]
		on: Error
		do:
			[ :aSignal | aSignal return: (self aborted: aTransitionSpec within: context dueTo: aSignal) ]
]

{ #category : #'private - accessing' }
TransitionApplicator >> transitionToInitialStateOf: aMachineSpec [

	^ TransitionSpecification
		unnamedFrom: (StateSpecification named: '' onEntry: [  ] onExit: [  ])
		to: aMachineSpec initialState
		allowedWhen: (CompositeCondition satisfyingAll: #())
		doing: [  ]
		triggeredBy: ManualTransitionTrigger new
]

{ #category : #'private - accessing' }
TransitionApplicator >> transitionsToTriggerConsidering: aResult within: anExternalContext [

	^ (aResult context stateMachine
		transitionsFrom: aResult currentState
		allowedWithin: anExternalContext)
		select: [ :transition | transition shouldBeTriggeredWithin: aResult context ]
]
