"
A StateMachineTest is a test class for testing the behavior of StateMachine
"
Class {
	#name : #StateMachineTransitionerTest,
	#superclass : #TestCase,
	#category : #'Cannon-Tests'
}

{ #category : #'private - accessing' }
StateMachineTransitionerTest >> sequentialTransitionsThrough: states writingTo: stream [

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
StateMachineTransitionerTest >> stateNamed: aName writingTo: aStream [

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
StateMachineTransitionerTest >> testApplyOf [

	| stream states transitions specification |

	stream := WriteStream on: String new.
	states := self threeStatesWritingTo: stream.
	transitions := self sequentialTransitionsThrough: states writingTo: stream.
	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first
		buildingContextWith: StateMachineContextExample.

	StateMachineTransitioner new apply: transitions first of: specification.
	self
		assert: stream contents
		equals: 'Entering A<r>Exiting A<r>Inside the one<r>Entering B<r>' expandMacros
]

{ #category : #tests }
StateMachineTransitionerTest >> testTransitionIsInterruptedWhenActionFails [

	| stream states transitions specification |

	stream := WriteStream on: String new.
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
		startingFrom: states first
		buildingContextWith: StateMachineContextExample.

	self
		should: [ StateMachineTransitioner new apply: transitions first of: specification ]
		raise: TransitionFailed
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: 'A-->C could not be completed because this is not an action.' ].
	self
		assert: stream contents
		equals: 'Entering A<r>Exiting A<r>Action started<r>' expandMacros
]

{ #category : #tests }
StateMachineTransitionerTest >> testTransitionIsInterruptedWhenEntryToDestinationStateFails [

	| stream states transitions specification |

	stream := WriteStream on: String new.
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
		startingFrom: states first
		buildingContextWith: StateMachineContextExample.

	self
		should: [ StateMachineTransitioner new apply: transitions first of: specification ]
		raise: TransitionFailed
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: 'A-->B could not be completed because this door is closed.' ].
	self
		assert: stream contents
		equals: 'Entering A<r>Exiting A<r>Inside no other<r>Trying to enter B<r>' expandMacros
]

{ #category : #tests }
StateMachineTransitionerTest >> testTransitionIsInterruptedWhenExitFromSourceStateFails [

	| stream states transitions specification |

	stream := WriteStream on: String new.
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
		startingFrom: states first
		buildingContextWith: StateMachineContextExample.

	self
		should: [ StateMachineTransitioner new apply: transitions first of: specification ]
		raise: TransitionFailed
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: 'A-->B could not be completed because there is no way out.' ].
	self assert: stream contents equals: 'Entering A<r>Trying to exit A<r>' expandMacros
]

{ #category : #tests }
StateMachineTransitionerTest >> testTransitionIsInterruptedWhenMultipleTriggersCanBeActivated [

	| stream states transitions specification |

	stream := WriteStream on: String new.
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
		startingFrom: states first
		buildingContextWith: StateMachineContextExample.

	self
		should: [ StateMachineTransitioner new apply: transitions first of: specification ]
		raise: TransitionFailed
		withExceptionDo:
			[ :exception | self assert: exception messageText equals: 'Expected at most one active trigger at B.' ].
	self
		assert: stream contents
		equals:
			'Entering A<r>Exiting A<r>Inside Up<r>Entering B<r>Down One Triggered<r>Down Two Triggered<r>'
				expandMacros
]

{ #category : #tests }
StateMachineTransitionerTest >> testTransitionIsNotAppliedWhenPreconditionIsNotSatisfied [

	| stream states transitions specification |

	stream := WriteStream on: String new.
	stream nextPutAll: 'Noise'; cr.
	states := self threeStatesWritingTo: stream.
	transitions := self sequentialTransitionsThrough: states writingTo: stream.
	specification := StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first
		buildingContextWith: StateMachineContextExample.

	self
		should: [ StateMachineTransitioner new apply: transitions first of: specification ]
		raise: TransitionFailed
		withExceptionDo: [ :exception | 
			self
				assert: exception messageText
				equals: 'A-->B is not an allowed transition in the current context.' ].
	self assert: stream contents equals: 'Noise<r>Entering A<r>' expandMacros 
]

{ #category : #tests }
StateMachineTransitionerTest >> testTriggersAreEvaluatedAfterEnteringDestinationState [

	| stream states transitions specification |

	stream := WriteStream on: String new.
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
		startingFrom: states first
		buildingContextWith: StateMachineContextExample.

	StateMachineTransitioner new apply: transitions first of: specification.
	self
		assert: stream contents
		equals:
			'Entering A<r>Exiting A<r>Inside Up<r>Entering B<r>Triggered!<r>Exiting B<r>Inside Down<r>Entering C<r>'
				expandMacros
]

{ #category : #tests }
StateMachineTransitionerTest >> testTriggersAreEvaluatedAfterEnteringInitialState [

	| stream states transitions |

	stream := WriteStream on: String new.
	states := self threeStatesWritingTo: stream.
	transitions := OrderedCollection
		with:
			(self
				transitionNamed: 'Up'
				from: states first
				to: states second
				writingTo: stream
				triggeredWhen: [ stream
						nextPutAll: 'Up Triggered';
						cr.
					true ])
		with:
			(self
				transitionNamed: 'Down'
				from: states second
				to: states last
				writingTo: stream
				triggeredWhen: [ stream
						nextPutAll: 'Down Triggered';
						cr.
					true ]).

	StateMachineSpecification
		transitioningThrough: transitions
		startingFrom: states first
		buildingContextWith: StateMachineContextExample.

	self
		assert: stream contents
		equals:
			'Entering A<r>Up Triggered<r>Exiting A<r>Inside Up<r>Entering B<r>Down Triggered<r>Exiting B<r>Inside Down<r>Entering C<r>'
				expandMacros
]

{ #category : #'private - accessing' }
StateMachineTransitionerTest >> threeStatesWritingTo: stream [

	^ OrderedCollection
		with: (self stateNamed: 'A' writingTo: stream)
		with: (self stateNamed: 'B' writingTo: stream)
		with: (self stateNamed: 'C' writingTo: stream)
]

{ #category : #'private - accessing' }
StateMachineTransitionerTest >> transitionNamed: aName from: aSource to: aTarget writingTo: aStream [

	^ self
		transitionNamed: aName
		from: aSource
		to: aTarget
		writingTo: aStream
		triggeredWhen: [ false ]
]

{ #category : #'private - accessing' }
StateMachineTransitionerTest >> transitionNamed: aName from: aSource to: aTarget writingTo: aStream triggeredWhen: aTriggerBlock [

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
