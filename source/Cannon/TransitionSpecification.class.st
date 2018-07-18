"
A transition specification includes the origin and destination state, can have a precondition before it is considered valid and stores a command (block) to be executed.
Optionally it can have a name.
A trigger can be specified, which determines when the transition will be activated without ""external"" intervention. It is the state machine's responsibility to determine when to check the triggers.

"
Class {
	#name : #TransitionSpecification,
	#superclass : #Object,
	#instVars : [
		'nameOptional',
		'source',
		'destination',
		'condition',
		'action',
		'trigger'
	],
	#category : #Cannon
}

{ #category : #'instance creation' }
TransitionSpecification class >> named: aName from: aSourceState to: aDestinationState allowedWhen: aConditionBlock doing: anAction triggeredBy: aTrigger [

	"Names are relevant to organize the state machine and its transitions.
	They also help during debugging."
	
	^ self
		namedUsing: (Optional containing: aName)
		from: aSourceState
		to: aDestinationState
		allowedWhen: aConditionBlock
		doing: anAction
		triggeredBy: aTrigger
]

{ #category : #'private - instance creation' }
TransitionSpecification class >> namedUsing: anOptional from: aSourceState to: aDestinationState allowedWhen: aConditionBlock doing: anAction triggeredBy: aTrigger [

	^ self new
		initializeNamedUsing: anOptional
		from: aSourceState
		to: aDestinationState
		allowedWhen: aConditionBlock
		doing: anAction
		triggeredBy: aTrigger
]

{ #category : #'instance creation' }
TransitionSpecification class >> unnamedFrom: aSourceState to: aDestinationState allowedWhen: aConditionBlock doing: anAction triggeredBy: aTrigger [

	"Names are relevant to organize the state machine and its transitions.
	They also help during debugging."

	^ self
		namedUsing: Optional unused
		from: aSourceState
		to: aDestinationState
		allowedWhen: aConditionBlock
		doing: anAction
		triggeredBy: aTrigger
]

{ #category : #processing }
TransitionSpecification >> affect: aContext [

	^ action cull: aContext
]

{ #category : #accessing }
TransitionSpecification >> destination [

	^ destination
]

{ #category : #initialization }
TransitionSpecification >> initializeNamedUsing: anOptional from: aSourceState to: aDestinationState allowedWhen: aConditionBlock doing: anAction triggeredBy: aTrigger [

	nameOptional := anOptional.
	source := aSourceState.
	destination := aDestinationState.
	condition := aConditionBlock.
	action := anAction.
	trigger := aTrigger
]

{ #category : #testing }
TransitionSpecification >> isAllowedWithin: aContext [

	^ condition isSatisfiedBy: aContext
]

{ #category : #printing }
TransitionSpecification >> printOn: aStream [

	self source printOn: aStream.
	aStream nextPutAll: '-->'.
	self destination printOn: aStream
]

{ #category : #testing }
TransitionSpecification >> shouldBeTriggeredWithin: aContext [

	^ trigger isActivatedBy: aContext
]

{ #category : #accessing }
TransitionSpecification >> source [

	^ source
]

{ #category : #accessing }
TransitionSpecification >> withNameDo: aNamedCommand ifUnnamed: anUnnamedCommand [

	^ nameOptional withContentDo: aNamedCommand ifUnused: anUnnamedCommand
]
