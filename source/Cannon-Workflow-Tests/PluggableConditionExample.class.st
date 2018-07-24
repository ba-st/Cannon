"
Pluggable condition to be used in the Workflow protocol of Cannon.
"
Class {
	#name : #PluggableConditionExample,
	#superclass : #Object,
	#instVars : [
		'conditionCommand'
	],
	#category : #'Cannon-Workflow-Tests'
}

{ #category : #'instance creation' }
PluggableConditionExample class >> evaluating: aBlock [

	^ self new initializeEvaluating: aBlock
]

{ #category : #initialization }
PluggableConditionExample >> initializeEvaluating: aBlock [

	conditionCommand := aBlock
]

{ #category : #testing }
PluggableConditionExample >> isSatisfiedBy: aContext [

	^ conditionCommand value: aContext
]
