"
StateSpecification gives the name and entry/exit behavior of a given state in a state machine.
"
Class {
	#name : #MachineState,
	#superclass : #Object,
	#instVars : [
		'name',
		'entryCommand',
		'exitCommand'
	],
	#category : #'Cannon-StateMachine'
}

{ #category : #'instance creation' }
MachineState class >> named: aName onEntry: anEntryCommand onExit: anExitCommand [

	^ self new initializeNamed: aName onEntry: anEntryCommand onExit: anExitCommand
]

{ #category : #accessing }
MachineState >> enterAffecting: aContext [

	^ entryCommand cull: aContext
]

{ #category : #accessing }
MachineState >> exitAffecting: aContext [

	^ exitCommand cull: aContext
]

{ #category : #initialization }
MachineState >> initializeNamed: aName onEntry: anEntryCommand onExit: anExitCommand [

	name := aName.
	entryCommand := anEntryCommand.
	exitCommand := anExitCommand
]

{ #category : #accessing }
MachineState >> name [

	^ name
]

{ #category : #printing }
MachineState >> printOn: aStream [

	aStream nextPutAll: self name asString
]
