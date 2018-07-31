"
A state machine specification indicates the possible states and the transitions between them, but does not have a ""current state"". Ideally many machines can be instantiated from one specification.
"
Class {
	#name : #StateMachineSpecification,
	#superclass : #Object,
	#instVars : [
		'transitions',
		'initialState'
	],
	#category : #'Cannon-StateMachine'
}

{ #category : #'instance creation' }
StateMachineSpecification class >> assert: aStateSpec isSourceOfAny: transitionSpecs [

	transitionSpecs
		detect: [ :transition | transition source = aStateSpec ]
		ifNone: [ InstanceCreationFailed
				signal:
					('The initial state (<1s>) must be source of at least one of the transitions.'
						expandMacrosWith: aStateSpec name) ]
]

{ #category : #'private - preconditions' }
StateMachineSpecification class >> assertStateNamesAreNotRepeatedIn: transitionSpecs [

	| states stateNames repeatedNames |

	states := Set new.
	transitionSpecs
		do: [ :transition | 
			states
				add: transition source;
				add: transition destination ].
	stateNames := Bag new.
	states do: [ :state | stateNames add: state name ].
	repeatedNames := SortedCollection new.
	stateNames
		doWithOccurrences: [ :stateName :repetitions | 
			repetitions > 1
				ifTrue: [ repeatedNames add: stateName ] ].
	repeatedNames
		ifNotEmpty: [ InstanceCreationFailed
				signal: ('State names can''t be repeated (<1s>).' expandMacrosWith: repeatedNames asCommaString) ]
]

{ #category : #'private - preconditions' }
StateMachineSpecification class >> assertTransitionsAreNotRepeatedIn: transitionSpecs [

	| transitionNames repeatedNames |

	transitionNames := Bag new.
	transitionSpecs
		do: [ :transition | 
			transition
				withNameDo: [ :transitionName | 
					transitionNames
						add:
							('<1s>:<2s>--><3s>'
								expandMacrosWith: transitionName
								with: transition source name
								with: transition destination name) ]
				ifUnnamed: [  ] ].
	repeatedNames := SortedCollection new.
	transitionNames
		doWithOccurrences: [ :transitionName :repetitions | 
			repetitions > 1
				ifTrue: [ repeatedNames add: transitionName ] ].
	repeatedNames
		ifNotEmpty: [ InstanceCreationFailed
				signal: ('Transitions can''t be repeated (<1s>).' expandMacrosWith: repeatedNames asCommaString) ]
]

{ #category : #'instance creation' }
StateMachineSpecification class >> transitioningThrough: transitionSpecs startingFrom: aStateSpec [

	self assert: aStateSpec isSourceOfAny: transitionSpecs.
	self assertTransitionsAreNotRepeatedIn: transitionSpecs.
	self assertStateNamesAreNotRepeatedIn: transitionSpecs.
	^ self new
		initializeTransitioningThrough: transitionSpecs
		startingFrom: aStateSpec
]

{ #category : #accessing }
StateMachineSpecification >> initialState [

	^ initialState
]

{ #category : #initialization }
StateMachineSpecification >> initializeTransitioningThrough: transitionSpecs startingFrom: aStateSpec [

	transitions := transitionSpecs.
	initialState := aStateSpec
]

{ #category : #testing }
StateMachineSpecification >> is: aTransitionSpec allowedWithin: anExternalContext [

	^ (transitions includes: aTransitionSpec)
		ifTrue: [ aTransitionSpec isAllowedWithin: anExternalContext ]
		ifFalse: [ ObjectNotFound
				signal:
					('<1p> is not a transition known to this machine specification.'
						expandMacrosWith: aTransitionSpec) ]
]

{ #category : #accessing }
StateMachineSpecification >> stateNamed: aStateName ifNone: aBlock [

	| states |

	states := Set new.
	transitions
		do: [ :transition | 
			states
				add: transition source;
				add: transition destination ].
	^ states detect: [ :state | state name = aStateName ] ifNone: aBlock
]

{ #category : #accessing }
StateMachineSpecification >> transitionsFrom: aStateSpec allowedWithin: anExternalContext [

	^ transitions
		select:
			[ :transition | transition source = aStateSpec and: [ transition isAllowedWithin: anExternalContext ] ]
]