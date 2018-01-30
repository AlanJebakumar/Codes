node{
	deleteDir()
	checkout scm
	
	parameters{
		string(
			name='StackName',
			description='StackName'
		)
		choice(
			name='OsVersion',
			choices='2008-R2\n2012-R2',
			description='Windows Os Version'
		)
		choice(
			name='Region',
			description='AWS Region',
			choices='us-east-1'
		)
	}

	stage('Build'){
		echo 'Build Step'
		sh '''
			date +%D
		'''
	}
	stage('cloud'){
	    echo 'Testing aws-connection'
	    sh '''
	        aws ec2 describe-regions --region us-east-1
	    '''
	}
	stage('Getting workspace contents'){
		echo "Listing ${workspace} contents"	
		sh '''
			ls -al ${workspace}
		'''
	}
	stage('StackCreation'){
		echo "Trying to find param values"
		sh '''
			ami_id=$(aws ec2 describe-images --filters "Name=platform,Values=windows" "Name=name,Values=Windows_Server-${OsVersion}_SP1-English-64Bit-Base*" "Name=owner-alias,Values=amazon" --region ${Region} | jq '[.Images[].ImageId][0]' -r)
			vpc_id=$(aws ec2 describe-vpcs --filters 'Name=tag:Name,Values=DEFAULT' --region ${Region} | jq '.Vpcs[].VpcId' -r)
			subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${vpc_id}" --region ${Region}| jq '.Subnets[].SubnetId' -r | paste -d, -s -)

			echo -e "${vpc_id}\t\"${subnets}\"\t${ami_id}"
		'''
	}
}