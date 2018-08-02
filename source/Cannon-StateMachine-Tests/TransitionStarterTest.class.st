"
A TransitionApplicatorTest is a test class for testing the behavior of TransitionApplicator
"
Class {
	#name : #TransitionStarterTest,
	#superclass : #TestCase,
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #'private - accessing' }
TransitionStarterTest >> readyStream [

	| stream |

	stream := WriteStream on: String new.
	stream
		nextPutAll: 'Ready';
		cr.
	^ stream
]

{ #category : #'private - accessing' }
TransitionStarterTest >> sequentialTransitionsThrough: states writingTo: stream [

	^ OrderedCollection
		with:
			(self
				transitionNamed: 'the one'
				from: states first
				to: states second
				writingTo: stream)
		with:
			(self
				transitionNamed: 'another'
				from: states second
				to: states last
				writingTo: stream)
]

{ #category : #'private - processing' }
TransitionStarterTest >> start: transitions of: machineSpec writingTo: stream [

	^ (TransitionStarter within: StateMachineSpecificationContextExample new for: machineSpec)
		start: transitions first
		whenComplete: [ stream
				nextPutAll: 'Complete';
				cr ]
]

{ #category : #'private - accessing' }
TransitionStarterTest >> stateNamed: aName writingTo: aStream [

	^ MachineState
		named: aName
		onEntry: [ aStream
				nextPutAll: ('Entering <1s>' expandMacrosWith: aName);
				cr ]
		onExit: [ aStream
				nextPutAll: ('Exiting <1s>' expandMacrosWith: aName);
				cr ]
]

{ #category : #tests }
TransitionStarterTest >> testStartWhenComplete [

	| stream states transitions machineSpec |

	stream := self readyStream.
	states := self threeStatesWritingTo: stream.
	transitions := self sequentialTransitionsThrough: states writingTo: stream.
	machineSpec := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.
	(TransitionStarter within: StateMachineSpecificationContextExample new for: machineSpec)
		start: transitions first
		whenComplete: [ stream
				nextPutAll: 'Complete';
				cr ].
	self
		assert: stream contents
		equals: 'Ready<r>Exiting A<r>Inside the one<r>Entering B<r>Complete<r>' expandMacros
]

{ #category : #tests }
TransitionStarterTest >> testTransitionIsInterruptedWhenActionFails [

	| stream states transitions machineSpec |

	stream := self readyStream.
	states := self threeStatesWritingTo: stream.
	transitions := Array
		with:
			(MachineTransition
				unnamedFrom: states first
				to: states last
				allowedWhen: (TransitionConditionExample readingFrom: stream)
				doing: [ :context :completeBlock | 
					stream
						nextPutAll: 'Action started';
						cr.
					ObjectNotFound signal: 'this is not an action' ]
				triggeredBy: ManualTransitionTrigger new).
	machineSpec := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.

	self
		should: [ self start: transitions of: machineSpec writingTo: stream ]
		raise: ObjectNotFound
		withExceptionDo: [ :exception | self assert: exception messageText equals: 'this is not an action' ].
	self assert: stream contents equals: 'Ready<r>Exiting A<r>Action started<r>' expandMacros
]

{ #category : #tests }
TransitionStarterTest >> testTransitionIsInterruptedWhenEntryToDestinationStateFails [

	| stream states transitions machineSpec |

	stream := self readyStream.
	states := Array
		with:
			(MachineState
				named: 'A'
				onEntry: [ stream
						nextPutAll: 'Entering A';
						cr ]
				onExit: [ stream
						nextPutAll: 'Exiting A';
						cr ])
		with:
			(MachineState
				named: 'B'
				onEntry: [ stream
						nextPutAll: 'Trying to enter B';
						cr.
					ObjectNotFound signal: 'this door is closed' ]
				onExit: [ stream
						nextPutAll: 'Exiting B';
						cr ]).
	transitions := Array
		with:
			(self
				transitionNamed: 'no other'
				from: states first
				to: states last
				writingTo: stream).
	machineSpec := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.

	self
		should: [ self start: transitions of: machineSpec writingTo: stream ]
		raise: ObjectNotFound
		withExceptionDo: [ :exception | self assert: exception messageText equals: 'this door is closed' ].
	self
		assert: stream contents
		equals: 'Ready<r>Exiting A<r>Inside no other<r>Trying to enter B<r>' expandMacros
]

{ #category : #tests }
TransitionStarterTest >> testTransitionIsInterruptedWhenExitFromSourceStateFails [

	| stream states transitions machineSpec |

	stream := self readyStream.
	states := Array
		with:
			(MachineState
				named: 'A'
				onEntry: [ stream
						nextPutAll: 'Entering A';
						cr ]
				onExit: [ stream
						nextPutAll: 'Trying to exit A';
						cr.
					ObjectNotFound signal: 'there is no way out' ])
		with:
			(MachineState
				named: 'B'
				onEntry: [ stream
						nextPutAll: 'Entering B';
						cr ]
				onExit: [ stream
						nextPutAll: 'Exiting B';
						cr ]).
	transitions := Array
		with:
			(self
				transitionNamed: 'no other'
				from: states first
				to: states last
				writingTo: stream).
	machineSpec := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.

	self
		should: [ self start: transitions of: machineSpec writingTo: stream ]
		raise: ObjectNotFound
		withExceptionDo: [ :exception | self assert: exception messageText equals: 'there is no way out' ].
	self assert: stream contents equals: 'Ready<r>Trying to exit A<r>' expandMacros
]

{ #category : #tests }
TransitionStarterTest >> testTransitionIsNotAppliedWhenPreconditionIsNotSatisfied [

	| stream states transitions machineSpec |

	stream := WriteStream on: String new.
	stream
		nextPutAll: 'Noise';
		cr.
	states := self threeStatesWritingTo: stream.
	transitions := self sequentialTransitionsThrough: states writingTo: stream.
	machineSpec := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.

	self
		should: [ self start: transitions of: machineSpec writingTo: stream ]
		raise: TransitionFailed
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: 'the one (A-->B) is not an allowed transition in the current context.' ].
	self assert: stream contents equals: 'Noise<r>' expandMacros
]

{ #category : #tests }
TransitionStarterTest >> testTransitionsAllowedFrom [

	| stream states transitions machineSpec starter |

	stream := self readyStream.
	states := self threeStatesWritingTo: stream.
	transitions := self sequentialTransitionsThrough: states writingTo: stream.
	machineSpec := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.
	starter := TransitionStarter
		within: StateMachineSpecificationContextExample new
		for: machineSpec.

	self
		assertCollection: (starter transitionsAllowedFrom: states first)
			hasSameElements: (Array with: transitions first);
		assertCollection: (starter transitionsAllowedFrom: states second)
			hasSameElements: (Array with: transitions last);
		assert: (starter transitionsAllowedFrom: states last) isEmpty
]

{ #category : #'private - accessing' }
TransitionStarterTest >> threeStatesWritingTo: stream [

	^ OrderedCollection
		with: (self stateNamed: 'A' writingTo: stream)
		with: (self stateNamed: 'B' writingTo: stream)
		with: (self stateNamed: 'C' writingTo: stream)
]

{ #category : #'private - accessing' }
TransitionStarterTest >> transitionNamed: aName from: aSource to: aTarget writingTo: aStream [

	^ self
		transitionNamed: aName
		from: aSource
		to: aTarget
		writingTo: aStream
		triggeredWhen: [ false ]
]

{ #category : #'private - accessing' }
TransitionStarterTest >> transitionNamed: aName from: aSource to: aTarget writingTo: aStream triggeredWhen: aTriggerBlock [

	^ MachineTransition
		named: aName
		from: aSource
		to: aTarget
		allowedWhen: (TransitionConditionExample readingFrom: aStream)
		doing: [ :context :completeBlock | 
			aStream
				nextPutAll: ('Inside <1s>' expandMacrosWith: aName);
				cr.
			completeBlock value ]
		triggeredBy: (ConditionBasedTrigger basedOn: (PluggableConditionExample evaluating: aTriggerBlock))
]
