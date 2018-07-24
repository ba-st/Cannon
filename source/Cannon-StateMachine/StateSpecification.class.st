"
StateSpecification gives the name and entry/exit behavior of a given state in a state machine.
"
Class {
	#name : #StateSpecification,
	#superclass : #Object,
	#instVars : [
		'name',
		'entryCommand',
		'exitCommand'
	],
	#category : #'Cannon-StateMachine-Cannon-StateMachine'
}

{ #category : #'instance creation' }
StateSpecification class >> named: aName onEntry: anEntryCommand onExit: anExitCommand [

	^ self new initializeNamed: aName onEntry: anEntryCommand onExit: anExitCommand
]

{ #category : #accessing }
StateSpecification >> enterAffecting: aContext [

	^ entryCommand cull: aContext
]

{ #category : #accessing }
StateSpecification >> exitAffecting: aContext [

	^ exitCommand cull: aContext
]

{ #category : #initialization }
StateSpecification >> initializeNamed: aName onEntry: anEntryCommand onExit: anExitCommand [

	name := aName.
	entryCommand := anEntryCommand.
	exitCommand := anExitCommand
]

{ #category : #accessing }
StateSpecification >> name [

	^ name
]

{ #category : #printing }
StateSpecification >> printOn: aStream [

	aStream nextPutAll: self name asString
]
