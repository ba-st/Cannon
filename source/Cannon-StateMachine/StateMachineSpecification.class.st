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

{ #category : #'private - preconditions' }
StateMachineSpecification class >> assert: aState isSourceOfAny: aTransitionCollection [

	aTransitionCollection
		detect: [ :transition | transition source = aState ]
		ifNone: [ InstanceCreationFailed
				signal:
					('The initial state (<1s>) must be source of at least one of the transitions.'
						expandMacrosWith: aState name) ]
]

{ #category : #'private - preconditions' }
StateMachineSpecification class >> assertStateNamesAreNotRepeatedIn: aTransitionCollection [

	| states stateNames repeatedNames |

	states := Set new.
	aTransitionCollection
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
				signal:
					('State names can''t be repeated (<1s>).'
						expandMacrosWith: ((CollectionFormatter separatingWith: ', ') format: repeatedNames)) ]
]

{ #category : #'private - preconditions' }
StateMachineSpecification class >> assertTransitionsAreNotRepeatedIn: aTransitionCollection [

	| transitionNames repeatedNames |

	transitionNames := Bag new.
	aTransitionCollection
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
				signal:
					('Transitions can''t be repeated (<1s>).'
						expandMacrosWith: ((CollectionFormatter separatingWith: ', ') format: repeatedNames)) ]
]

{ #category : #'instance creation' }
StateMachineSpecification class >> transitioningThrough: aTransitionCollection startingFrom: aState [

	self assert: aState isSourceOfAny: aTransitionCollection.
	self assertTransitionsAreNotRepeatedIn: aTransitionCollection.
	self assertStateNamesAreNotRepeatedIn: aTransitionCollection.
	^ self new initializeTransitioningThrough: aTransitionCollection startingFrom: aState
]

{ #category : #accessing }
StateMachineSpecification >> allTransitions [

	^ transitions asArray
]

{ #category : #accessing }
StateMachineSpecification >> initialState [

	^ initialState
]

{ #category : #initialization }
StateMachineSpecification >> initializeTransitioningThrough: aTransitionCollection startingFrom: aState [

	transitions := aTransitionCollection.
	initialState := aState
]

{ #category : #testing }
StateMachineSpecification >> is: aTransition allowedWithin: anExternalContext [

	^ (transitions includes: aTransition)
		ifTrue: [ aTransition isAllowedWithin: anExternalContext ]
		ifFalse: [ ObjectNotFound
				signal:
					('<1p> is not a transition known to this machine specification.'
						expandMacrosWith: aTransition) ]
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
StateMachineSpecification >> transitionsFrom: aState allowedWithin: anExternalContext [

	^ transitions
		select:
			[ :transition | transition source = aState and: [ transition isAllowedWithin: anExternalContext ] ]
]
