"
This transitioner encapsulates the steps required when changing from one state to another. It can also be instructued to perform the transition to the initial state.
"
Class {
	#name : #WorkflowTransitioner,
	#superclass : #Object,
	#instVars : [
		'currentState',
		'transitionApplicator'
	],
	#category : #'Cannon-Workflow'
}

{ #category : #'instance creation' }
WorkflowTransitioner class >> within: aContext for: aMachineSpec in: aStateName [

	^ self new initializeWithin: aContext for: aMachineSpec in: aStateName
]

{ #category : #'instance creation' }
WorkflowTransitioner class >> within: anExternalContext inInitialStateFor: aMachineSpec [

	aMachineSpec initialState enterAffecting: anExternalContext whenComplete: [  ].
	^ self within: anExternalContext for: aMachineSpec in: aMachineSpec initialState name
]

{ #category : #accessing }
WorkflowTransitioner >> currentState [

	^ currentState
]

{ #category : #initialization }
WorkflowTransitioner >> initializeWithin: aContext for: aMachineSpec in: aStateName [

	currentState := aMachineSpec
		stateNamed: aStateName
		ifNone: [ InstanceCreationFailed signal: ('No state is named <1s>' expandMacrosWith: aStateName) ].
	transitionApplicator := TransitionApplicator within: aContext for: aMachineSpec
]

{ #category : #processing }
WorkflowTransitioner >> startTransitionTo: aStateName [

	| candidates |

	candidates := (transitionApplicator allowedTransitionsFrom: self currentState)
		select: [ :transitionSpec | transitionSpec destination name = aStateName ].

	candidates size = 1
		ifTrue: [ self updateStateAfterStarting: candidates anyOne ]
		ifFalse: [ ObjectNotFound
				signal:
					('Expected single transition from <1s> to <2s> but found <3p>.'
						expandMacrosWith: self currentState name
						with: aStateName
						with: candidates size) ]
]

{ #category : #'private - processing' }
WorkflowTransitioner >> updateStateAfterStarting: aTransitionSpec [

	transitionApplicator
		start: aTransitionSpec
		whenComplete: [ :state :context | currentState := state ]
		ifAborted: [ :state :context :reason | 
			context applyRollbackDueTo: reason.
			currentState := state ]
]
