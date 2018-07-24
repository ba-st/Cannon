"
This transitioner encapsulates the steps required when changing from one state to another. It can also be instructued to perform the transition to the initial state.
"
Class {
	#name : #WorkflowTransitioner,
	#superclass : #Object,
	#instVars : [
		'context',
		'machineSpec',
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
WorkflowTransitioner class >> within: anExternalContext inInitialStateFor: machineSpec [

	| result |

	result := TransitionApplicator new
		applyInitialTransitionOf: machineSpec
		within: anExternalContext.

	^ result
		ifComplete: [ self within: anExternalContext for: machineSpec in: result currentState name ]
		ifAborted: [ :reason | InstanceCreationFailed signal: reason ]
]

{ #category : #accessing }
WorkflowTransitioner >> currentState [

	^ currentState
]

{ #category : #initialization }
WorkflowTransitioner >> initializeWithin: aContext for: aMachineSpec in: aStateName [

	context := aContext.
	machineSpec := aMachineSpec.
	currentState := machineSpec
		stateNamed: aStateName
		ifNone: [ InstanceCreationFailed signal: ('No state is named <1s>' expandMacrosWith: aStateName) ].

	transitionApplicator := TransitionApplicator new
]

{ #category : #processing }
WorkflowTransitioner >> transitionTo: aStateName [

	^ (machineSpec transitionsFrom: self currentState allowedWithin: context)
		detect: [ :transitionSpec | transitionSpec destination name = aStateName ]
		ifFound: [ :transitionSpec | self updateStateAfterApplying: transitionSpec ]
		ifNone: [ ObjectNotFound
				signal:
					('No allowed transition found from <1s> to <2s>'
						expandMacrosWith: self currentState name
						with: aStateName) ]
]

{ #category : #'private - processing' }
WorkflowTransitioner >> updateStateAfterApplying: aTransitionSpec [

	| result |

	result := transitionApplicator apply: aTransitionSpec of: machineSpec within: context.
	result ifComplete: [  ] ifAborted: [ :reason | context applyRollback ].
	currentState := result currentState
]
