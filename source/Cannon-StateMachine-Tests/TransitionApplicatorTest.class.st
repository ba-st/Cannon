"
A TransitionApplicatorTest is a test class for testing the behavior of TransitionApplicator
"
Class {
	#name : #TransitionApplicatorTest,
	#superclass : #TestCase,
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #'private - accessing' }
TransitionApplicatorTest >> readyStream [

	| stream |

	stream := WriteStream on: String new.
	stream
		nextPutAll: 'Ready';
		cr.
	^ stream
]

{ #category : #'private - accessing' }
TransitionApplicatorTest >> sequentialTransitionsThrough: states writingTo: stream [

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

{ #category : #'private - accessing' }
TransitionApplicatorTest >> stateNamed: aName writingTo: aStream [

	^ StateSpecification
		named: aName
		onEntry: [ aStream
				nextPutAll: ('Entering <1s>' expandMacrosWith: aName);
				cr ]
		onExit: [ aStream
				nextPutAll: ('Exiting <1s>' expandMacrosWith: aName);
				cr ]
]

{ #category : #tests }
TransitionApplicatorTest >> testApplyInitialTransitionOfWithin [

	| stream states transitions specification result |

	stream := self readyStream.
	states := self threeStatesWritingTo: stream.
	transitions := self
		sequentialTransitionsThrough: states
		writingTo: stream.
	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.
	result := TransitionApplicator new applyInitialTransition.
	result
		ifComplete: [ stream
				nextPutAll: 'Complete';
				cr ]
		ifAborted: [ self fail ].
	self
		assert: stream contents
		equals: 'Ready<r>Entering A<r>Complete<r>' expandMacros
]

{ #category : #tests }
TransitionApplicatorTest >> testApplyOfWithin [

	| stream states transitions specification result |

	stream := self readyStream.
	states := self threeStatesWritingTo: stream.
	transitions := self
		sequentialTransitionsThrough: states
		writingTo: stream.
	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.
	result := TransitionApplicator new apply: transitions first.
	result
		ifComplete: [ stream
				nextPutAll: 'Complete';
				cr ]
		ifAborted: [ self fail ].
	self
		assert: stream contents
		equals:
			'Ready<r>Exiting A<r>Inside the one<r>Entering B<r>Complete<r>'
				expandMacros
]

{ #category : #tests }
TransitionApplicatorTest >> testTransitionIsInterruptedWhenActionFails [

	| stream states transitions specification result |

	stream := self readyStream.
	states := self threeStatesWritingTo: stream.
	transitions := Array
		with:
			(TransitionSpecification
				unnamedFrom: states first
				to: states last
				allowedWhen: (TransitionConditionExample readingFrom: stream)
				doing: [ stream
						nextPutAll: 'Action started';
						cr.
					ObjectNotFound signal: 'this is not an action' ]
				triggeredBy: ManualTransitionTrigger new).
	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.

	result := TransitionApplicator new apply: transitions first.
	result
		ifComplete: [ self fail ]
		ifAborted: [ :reason | stream nextPutAll: reason ].
	self
		assert: stream contents
		equals:
			'Ready<r>Exiting A<r>Action started<r>A-->C could not be completed because this is not an action.'
				expandMacros
]

{ #category : #tests }
TransitionApplicatorTest >> testTransitionIsInterruptedWhenEntryToDestinationStateFails [

	| stream states transitions specification result |

	stream := self readyStream.
	states := Array
		with:
			(StateSpecification
				named: 'A'
				onEntry: [ stream
						nextPutAll: 'Entering A';
						cr ]
				onExit: [ stream
						nextPutAll: 'Exiting A';
						cr ])
		with:
			(StateSpecification
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
	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.

	result := TransitionApplicator new apply: transitions first.

	result
		ifComplete: [ self fail ]
		ifAborted: [ :reason | stream nextPutAll: reason ].
	self
		assert: stream contents
		equals:
			'Ready<r>Exiting A<r>Inside no other<r>Trying to enter B<r>no other (A-->B) could not be completed because this door is closed.'
				expandMacros
]

{ #category : #tests }
TransitionApplicatorTest >> testTransitionIsInterruptedWhenExitFromSourceStateFails [

	| stream states transitions specification result |

	stream := self readyStream.
	states := Array
		with:
			(StateSpecification
				named: 'A'
				onEntry: [ stream
						nextPutAll: 'Entering A';
						cr ]
				onExit: [ stream
						nextPutAll: 'Trying to exit A';
						cr.
					ObjectNotFound signal: 'there is no way out' ])
		with:
			(StateSpecification
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
	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.

	result := TransitionApplicator new apply: transitions first.
	result
		ifComplete: [ self fail ]
		ifAborted: [ :reason | stream nextPutAll: reason ].
	self
		assert: stream contents
		equals:
			'Ready<r>Trying to exit A<r>no other (A-->B) could not be completed because there is no way out.'
				expandMacros
]

{ #category : #tests }
TransitionApplicatorTest >> testTransitionIsInterruptedWhenMultipleTriggersCanBeActivated [

	| stream states transitions specification result |

	stream := self readyStream.
	states := self threeStatesWritingTo: stream.
	transitions := OrderedCollection
		with:
			(self
				transitionNamed: 'Up'
				from: states first
				to: states second
				writingTo: stream)
		with:
			(self
				transitionNamed: 'Down One'
				from: states second
				to: states first
				writingTo: stream
				triggeredWhen: [ stream
						nextPutAll: 'Down One Triggered';
						cr.
					true ])
		with:
			(self
				transitionNamed: 'Down Two'
				from: states second
				to: states last
				writingTo: stream
				triggeredWhen: [ stream
						nextPutAll: 'Down Two Triggered';
						cr.
					true ]).

	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.

	result := TransitionApplicator new apply: transitions first.
	result
		ifComplete: [ self fail ]
		ifAborted: [ :reason | stream nextPutAll: reason ].
	self
		assert: stream contents
		equals:
			'Ready<r>Exiting A<r>Inside Up<r>Entering B<r>Down One Triggered<r>Down Two Triggered<r>Expected at most one active trigger at B.'
				expandMacros
]

{ #category : #tests }
TransitionApplicatorTest >> testTransitionIsNotAppliedWhenPreconditionIsNotSatisfied [

	| stream states transitions specification result |

	stream := WriteStream on: String new.
	stream
		nextPutAll: 'Noise';
		cr.
	states := self threeStatesWritingTo: stream.
	transitions := self
		sequentialTransitionsThrough: states
		writingTo: stream.
	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.

	result := TransitionApplicator new apply: transitions first.
	result
		ifComplete: [ self fail ]
		ifAborted: [ :reason | stream nextPutAll: reason ].
	self
		assert: stream contents
		equals:
			'Noise<r>the one (A-->B) is not an allowed transition in the current context.'
				expandMacros
]

{ #category : #tests }
TransitionApplicatorTest >> testTriggersAreEvaluatedAfterEnteringDestinationState [

	| stream states transitions specification result |

	stream := self readyStream.
	states := self threeStatesWritingTo: stream.
	transitions := OrderedCollection
		with:
			(self
				transitionNamed: 'Up'
				from: states first
				to: states second
				writingTo: stream)
		with:
			(self
				transitionNamed: 'Down'
				from: states second
				to: states last
				writingTo: stream
				triggeredWhen: [ stream
						nextPutAll: 'Triggered!';
						cr.
					true ]).

	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.

	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first.
	result := TransitionApplicator new apply: transitions first.
	result
		ifComplete: [ stream
				nextPutAll: 'Complete';
				cr ]
		ifAborted: [ self fail ].
	self
		assert: stream contents
		equals:
			'Ready<r>Exiting A<r>Inside Up<r>Entering B<r>Triggered!<r>Exiting B<r>Inside Down<r>Entering C<r>Complete<r>'
				expandMacros
]

{ #category : #'private - accessing' }
TransitionApplicatorTest >> threeStatesWritingTo: stream [

	^ OrderedCollection
		with: (self stateNamed: 'A' writingTo: stream)
		with: (self stateNamed: 'B' writingTo: stream)
		with: (self stateNamed: 'C' writingTo: stream)
]

{ #category : #'private - accessing' }
TransitionApplicatorTest >> transitionNamed: aName from: aSource to: aTarget writingTo: aStream [

	^ self
		transitionNamed: aName
		from: aSource
		to: aTarget
		writingTo: aStream
		triggeredWhen: [ false ]
]

{ #category : #'private - accessing' }
TransitionApplicatorTest >> transitionNamed: aName from: aSource to: aTarget writingTo: aStream triggeredWhen: aTriggerBlock [

	^ TransitionSpecification
		named: aName
		from: aSource
		to: aTarget
		allowedWhen: (TransitionConditionExample readingFrom: aStream)
		doing: [ aStream
				nextPutAll: ('Inside <1s>' expandMacrosWith: aName);
				cr ]
		triggeredBy: (PluggableTriggerExample activatedWhen: aTriggerBlock)
]
