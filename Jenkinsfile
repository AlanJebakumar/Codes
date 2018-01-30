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
	
	environment{
		template_name = "jk-asgwin"
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
			}
		}
		
		
		stage('Finding param Values'){
			agent{
				label 'master'
			}

			steps{
				echo "Finding ${StackName} param values"
			}
		}
		
		stage('Creating AWS Stack'){
	    agent{
	        label 'master'
	    }
	    steps{
  	    sh '''
			ami_id=$(aws ec2 describe-images --filters "Name=platform,Values=windows" "Name=name,Values=Windows_Server-${OsVersion}_SP1-English-64Bit-Base*" "Name=owner-alias,Values=amazon" --region ${Region} | jq '[.Images[].ImageId][0]' -r)
			vpc_id=$(aws ec2 describe-vpcs --filters 'Name=tag:Name,Values=DEFAULT' --region ${Region} | jq '.Vpcs[].VpcId' -r)
			subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${vpc_id}" --region ${Region}| jq '.Subnets[].SubnetId' -r | paste -d, -s -)
			echo "\\"${subnets}\\""
	        #ls -al "${WORKSPACE}/CFTemplates/"
	        aws s3 cp "${WORKSPACE}/CFTemplates/${template_name}.json" s3://devopslab-cts/JK-CFTemplates/
    	    aws cloudformation validate-template --template-url "https://s3.amazonaws.com/devopslab-cts/JK-CFTemplates/${template_name}.json" --region ${Region}
    	    aws cloudformation create-stack --stack-name ${StackName} --template-url "https://s3.amazonaws.com/devopslab-cts/JK-CFTemplates/${template_name}.json" --parameters "ParameterKey=Subnets,ParameterValue=\\"${subnets}\\"" "ParameterKey=VpcId,ParameterValue=${vpc_id}" "ParameterKey=OsAmi,ParameterValue=${ami_id}" --capabilities CAPABILITY_IAM --tags "Key=Name,Value=${StackName}" --region ${Region}
		'''
        echo "Stack Creation Initated.."
	    }
		}
	}
}