"
A StateSpecificationTest is a test class for testing the behavior of StateSpecification
"
Class {
	#name : #MachineStateTest,
	#superclass : #TestCase,
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #tests }
MachineStateTest >> testNamedOnEntryOnExit [

	| state context |

	state := MachineState
		named: 'First'
		onEntry: [ :currentContext | 
			currentContext
				nextPutAll: 'Entering';
				cr ]
		onExit: [ :currentContext | 
			currentContext
				nextPutAll: 'Exiting';
				cr ].
	self assert: state name equals: 'First'.

	context := WriteStream on: String new.
	state enterAffecting: context.
	self assert: context contents equals: 'Entering<r>' expandMacros.

	context := WriteStream on: String new.
	state exitAffecting: context.
	self assert: context contents equals: 'Exiting<r>' expandMacros.

	context := WriteStream on: String new.
	state enterAffecting: context.
	state exitAffecting: context.
	self assert: context contents equals: 'Entering<r>Exiting<r>' expandMacros
]

{ #category : #tests }
MachineStateTest >> testPrintOn [

	| state |

	state := MachineState named: 'First' onEntry: [  ] onExit: [  ].

	self assert: state asString equals: 'First'
]
