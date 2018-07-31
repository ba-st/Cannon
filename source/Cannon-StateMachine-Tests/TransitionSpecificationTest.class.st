"
A TransitionSpecificationTest is a test class for testing the behavior of TransitionSpecification
"
Class {
	#name : #TransitionSpecificationTest,
	#superclass : #TestCase,
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #'private - accessing' }
TransitionSpecificationTest >> stateNamed: aName [

	^ StateSpecification named: aName onEntry: [  ] onExit: [  ]
]

{ #category : #tests }
TransitionSpecificationTest >> testNamedFromToAllowedWhenDoing [

	| states transition context |

	context := WriteStream on: String new.
	states := Array with: (self stateNamed: 'a') with: (self stateNamed: 'b').
	transition := TransitionSpecification
		named: 'move'
		from: states first
		to: states last
		allowedWhen: (ArithmeticCondition toBeEqualTo: 0)
		doing: [ :currentContext | currentContext nextPutAll: '...Transitioning...' ]
		triggeredBy: ManualTransitionTrigger new.

	self
		assert: transition source equals: states first;
		assert: transition destination equals: states last;
		assert: (transition isAllowedWithin: context contents size);
		deny: (transition shouldBeTriggeredWithin: context).

	transition affect: context.
	self assert: context contents equals: '...Transitioning...'.
	self deny: (transition isAllowedWithin: context).

	transition
		withNameDo: [ :name | context nextPutAll: name ]
		ifUnnamed: [ context nextPutAll: 'None' ].
	self assert: context contents equals: '...Transitioning...move'
]

{ #category : #tests }
TransitionSpecificationTest >> testPrintOn [

	| states transition |

	states := Array with: (self stateNamed: 'a') with: (self stateNamed: 'b').
	transition := TransitionSpecification
		unnamedFrom: states first
		to: states last
		allowedWhen: (ArithmeticCondition toBeEqualTo: 0)
		doing: [ :currentContext | currentContext nextPutAll: '...Transitioning...' ]
		triggeredBy: ManualTransitionTrigger new.
	self assert: transition asString equals: 'a-->b'.

	transition := TransitionSpecification
		named: 'move'
		from: states first
		to: states last
		allowedWhen: (ArithmeticCondition toBeEqualTo: 0)
		doing: [ :currentContext | currentContext nextPutAll: '...Transitioning...' ]
		triggeredBy: ManualTransitionTrigger new.
	self assert: transition asString equals: 'move (a-->b)'
]

{ #category : #tests }
TransitionSpecificationTest >> testUnnamedFromToAllowedWhenDoing [

	| transition states context |

	context := WriteStream on: String new.
	states := Array with: (self stateNamed: 'a') with: (self stateNamed: 'b').
	transition := TransitionSpecification
		unnamedFrom: states first
		to: states last
		allowedWhen: (ArithmeticCondition toBeEqualTo: 0)
		doing: [ :currentContext | currentContext nextPutAll: '...Transitioning...' ]
		triggeredBy: ManualTransitionTrigger new.

	self
		assert: transition source equals: states first;
		assert: transition destination equals: states last;
		assert: (transition isAllowedWithin: context contents size);
		deny: (transition shouldBeTriggeredWithin: context).

	transition affect: context.
	self assert: context contents equals: '...Transitioning...'.
	self deny: (transition isAllowedWithin: context).

	transition
		withNameDo: [ :name | context nextPutAll: name ]
		ifUnnamed: [ context nextPutAll: 'None' ].
	self assert: context contents equals: '...Transitioning...None'
]
