"
A state machine specification indicates the possible states and the transitions between them, but does not have a ""current state"". Ideally many machines can be instantiated from one specification.
"
Class {
	#name : #StateMachineSpecification,
	#superclass : #Object,
	#instVars : [
		'transitions',
		'initialState',
		'contextBuilder'
	],
	#category : #Cannon
}

{ #category : #'instance creation' }
StateMachineSpecification class >> assert: anInitialStateSpecification isSourceOfAny: aTransitionSpecificationCollection [

	aTransitionSpecificationCollection
		detect: [ :transition | transition source = anInitialStateSpecification ]
		ifNone: [ InstanceCreationFailed
				signal:
					('The initial state (<1s>) must be source of at least one of the transitions.'
						expandMacrosWith: anInitialStateSpecification name) ]
]

{ #category : #'private - preconditions' }
StateMachineSpecification class >> assertStateNamesAreNotRepeatedIn: aTransitionSpecificationCollection [

	| states stateNames repeatedNames |

	states := Set new.
	aTransitionSpecificationCollection
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
StateMachineSpecification class >> assertTransitionsAreNotRepeatedIn: aTransitionSpecificationCollection [

	| transitionNames repeatedNames |

	transitionNames := Bag new.
	aTransitionSpecificationCollection
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
					('Transitions can''t be repeated (<1s>).' expandMacrosWith: repeatedNames asCommaString) ]
]

{ #category : #'instance creation' }
StateMachineSpecification class >> transitioningThrough: aTransitionSpecificationCollection startingFrom: anInitialStateSpecification buildingContextWith: aContextBuilder [

	self assert: anInitialStateSpecification isSourceOfAny: aTransitionSpecificationCollection.
	self assertTransitionsAreNotRepeatedIn: aTransitionSpecificationCollection.
	self assertStateNamesAreNotRepeatedIn: aTransitionSpecificationCollection.
	^ self new
		initializeTransitioningThrough: aTransitionSpecificationCollection
		startingFrom: anInitialStateSpecification
		buildingContextWith: aContextBuilder
]

{ #category : #accessing }
StateMachineSpecification >> contextBuilder [

	^ contextBuilder
]

{ #category : #accessing }
StateMachineSpecification >> initialState [

	^ initialState
]

{ #category : #initialization }
StateMachineSpecification >> initializeTransitioningThrough: aTransitionSpecificationCollection startingFrom: anInitialStateSpecification buildingContextWith: aContextBuilder [

	transitions := aTransitionSpecificationCollection.
	initialState := anInitialStateSpecification.
	contextBuilder := aContextBuilder.

	self transitionToInitialState
]

{ #category : #'private - processing' }
StateMachineSpecification >> transitionToInitialState [

	StateMachineTransitioner new
		apply:
			(TransitionSpecification
				unnamedFrom: (StateSpecification named: '' onEntry: [  ] onExit: [  ])
				to: self initialState
				allowedWhen: (CompositeCondition satisfyingAll: #())
				doing: [  ]
				triggeredBy: ManualTransitionTrigger new)
		of: self
]

{ #category : #accessing }
StateMachineSpecification >> transitionsFrom: aCurrentState allowedWithin: aContext [

	^ transitions
		select:
			[ :transition | transition source = aCurrentState and: [ transition isAllowedWithin: aContext ] ]
]
