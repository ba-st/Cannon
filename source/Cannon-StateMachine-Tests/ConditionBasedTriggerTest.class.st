"
A ConditionBasedTriggerTest is a test class for testing the behavior of ConditionBasedTrigger
"
Class {
	#name : #ConditionBasedTriggerTest,
	#superclass : #TestCase,
	#category : #'Cannon-StateMachine-Tests'
}

{ #category : #tests }
ConditionBasedTriggerTest >> testIsActivatedBy [

	| trigger |

	trigger := ConditionBasedTrigger
		basedOn: (PluggableConditionExample evaluating: [ :context | context not ]).
	self
		deny: (trigger isActivatedBy: true);
		assert: (trigger isActivatedBy: false)
]
