"
A transition specification includes the origin and destination state, can have a precondition before it is considered valid and stores a command (block) to be executed.
Optionally it can have a name.
A trigger can be specified, which determines when the transition will be activated without ""external"" intervention. It is the state machine's responsibility to determine when to check the triggers.

"
Class {
	#name : #MachineTransition,
	#superclass : #Object,
	#instVars : [
		'source',
		'destination',
		'condition',
		'action',
		'trigger',
		'name'
	],
	#category : #'Cannon-StateMachine'
}

{ #category : #'instance creation' }
MachineTransition class >> named: aName from: aSourceState to: aDestinationState allowedWhen: aCondition doing: anAction triggeredBy: aTrigger [

	^ self new
		initializeNamed: aName
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
MachineTransition >> initializeNamed: aName from: aSourceState to: aDestinationState allowedWhen: aCondition doing: anAction triggeredBy: aTrigger [

	name := aName.
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

{ #category : #accessing }
MachineTransition >> name [

	^ name
]

{ #category : #printing }
MachineTransition >> printOn: aStream [

	aStream
		nextPutAll: name;
		space;
		nextPut: $(.
	self printSourceToDestinationOn: aStream.
	aStream nextPut: $)
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
