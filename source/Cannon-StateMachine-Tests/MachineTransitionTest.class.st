"
A TransitionSpecificationTest is a test class for testing the behavior of TransitionSpecification
"
Class {
	#name : #MachineTransitionTest,
	#superclass : #TestCase,
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #'private - accessing' }
MachineTransitionTest >> stateNamed: aName [

	^ MachineState named: aName onEntry: [  ] onExit: [  ]
]

{ #category : #tests }
MachineTransitionTest >> testNamedFromToAllowedWhenDoingTriggeredBy [

	| states transition context |

	context := WriteStream on: String new.
	states := Array with: (self stateNamed: 'a') with: (self stateNamed: 'b').
	transition := MachineTransition
		named: 'move'
		from: states first
		to: states last
		allowedWhen: (ArithmeticCondition toBeEqualTo: 0)
		doing: [ :currentContext :completeBlock | 
			currentContext nextPutAll: '...Transitioning...'.
			completeBlock value ]
		triggeredBy: ManualTransitionTrigger new.

	self
		assert: transition source equals: states first;
		assert: transition destination equals: states last;
		assert: (transition isAllowedWithin: context contents size);
		deny: (transition shouldBeTriggeredWithin: context).

	transition affect: context whenComplete: [ context nextPutAll: 'Done!' ].
	self assert: context contents equals: '...Transitioning...Done!'.
	self deny: (transition isAllowedWithin: context).

	context nextPutAll: transition name.
	self assert: context contents equals: '...Transitioning...Done!move'
]

{ #category : #tests }
MachineTransitionTest >> testPrintOn [

	| states transition |

	states := Array with: (self stateNamed: 'a') with: (self stateNamed: 'b').

	transition := MachineTransition
		named: 'move'
		from: states first
		to: states last
		allowedWhen: (ArithmeticCondition toBeEqualTo: 0)
		doing: [ :currentContext | currentContext nextPutAll: '...Transitioning...' ]
		triggeredBy: ManualTransitionTrigger new.
	self assert: transition asString equals: 'move (a-->b)'
]
