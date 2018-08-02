"
A transition specification includes the origin and destination state, can have a precondition before it is considered valid and stores a command (block) to be executed.
Optionally it can have a name.
A trigger can be specified, which determines when the transition will be activated without ""external"" intervention. It is the state machine's responsibility to determine when to check the triggers.

"
Class {
	#name : #MachineTransition,
	#superclass : #Object,
	#instVars : [
		'nameOptional',
		'source',
		'destination',
		'condition',
		'action',
		'trigger'
	],
	#category : #'Cannon-StateMachine'
}

{ #category : #'instance creation' }
MachineTransition class >> named: aName from: aSourceState to: aDestinationState allowedWhen: aCondition doing: anAction triggeredBy: aTrigger [

	"Names are relevant to organize the state machine and its transitions.
	They also help during debugging."

	^ self
		namedUsing: (Optional containing: aName)
		from: aSourceState
		to: aDestinationState
		allowedWhen: aCondition
		doing: anAction
		triggeredBy: aTrigger
]

{ #category : #'private - instance creation' }
MachineTransition class >> namedUsing: anOptional from: aSourceState to: aDestinationState allowedWhen: aCondition doing: anAction triggeredBy: aTrigger [

	^ self new
		initializeNamedUsing: anOptional
		from: aSourceState
		to: aDestinationState
		allowedWhen: aCondition
		doing: anAction
		triggeredBy: aTrigger
]

{ #category : #'instance creation' }
MachineTransition class >> unnamedFrom: aSourceState to: aDestinationState allowedWhen: aCondition doing: anAction triggeredBy: aTrigger [

	"Names are relevant to organize the state machine and its transitions.
	They also help during debugging."

	^ self
		namedUsing: Optional unused
		from: aSourceState
		to: aDestinationState
		allowedWhen: aCondition
		doing: anAction
		triggeredBy: aTrigger
]

{ #category : #processing }
MachineTransition >> affect: aContext whenComplete: anActionWhenCompleted [

	^ action value: aContext value: anActionWhenCompleted
]

{ #category : #accessing }
MachineTransition >> destination [

	^ destination
]

{ #category : #initialization }
MachineTransition >> initializeNamedUsing: anOptional from: aSourceState to: aDestinationState allowedWhen: aCondition doing: anAction triggeredBy: aTrigger [

	nameOptional := anOptional.
	source := aSourceState.
	destination := aDestinationState.
	condition := aCondition.
	action := anAction.
	trigger := aTrigger
]

{ #category : #testing }
MachineTransition >> isAllowedWithin: anExternalContext [

	^ condition isSatisfiedBy: anExternalContext
]

{ #category : #printing }
MachineTransition >> printOn: aStream [

	self
		withNameDo: [ :name | 
			aStream
				nextPutAll: name;
				space;
				nextPut: $(.
			self printSourceToDestinationOn: aStream.
			aStream nextPut: $) ]
		ifUnnamed: [ self printSourceToDestinationOn: aStream ]
]

{ #category : #'private - printing' }
MachineTransition >> printSourceToDestinationOn: aStream [

	self source printOn: aStream.
	aStream nextPutAll: '-->'.
	self destination printOn: aStream
]

{ #category : #testing }
MachineTransition >> shouldBeTriggeredWithin: aContext [

	^ trigger isActivatedBy: aContext
]

{ #category : #accessing }
MachineTransition >> source [

	^ source
]

{ #category : #accessing }
MachineTransition >> withNameDo: aNamedCommand ifUnnamed: anUnnamedCommand [

	^ nameOptional withContentDo: aNamedCommand ifUnused: anUnnamedCommand
]
