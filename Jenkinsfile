#!/usr/bin/groovy

pipeline{
	agent any
	options{
		//keep the last 5 builds
		buildDiscarder(
			logRotator(
				numToKeepStr: '5'
			)
		)
		//Disable Multiple builds
		disableConcurrentBuilds()
	}

	parameters{
		string(
			name: 'StackName',
			description: 'StackName'
		)
		choice(
			name: 'OsVersion',
			choices: '2008-R2\n2012-R2',
			description: 'Windows Os Version'
		)
		choice(
			name: 'Region',
			description: 'AWS Region',
			choices: 'us-east-1'
		)		
	}

	stages{
		stage('Testing AWS Connection'){
			agent{
				label 'master'
			}

			steps{
			    echo "Testing AWS Connection"
				sh '''
					aws ec2 describe-regions --region ${Region}
				'''
				
				echo "${workspace} contents"
				sh '''
				    ls -al ${workspace}
				'''
			}
		}
	}
}