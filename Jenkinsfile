node{
	deleteDir()
	checkout scm
	
	stage('Build'){
		echo 'Build Step'
		sh '''
			date +%D
		'''
	}
	stage('Test'){
	    echo 'Testing stage'
	    sh '''
	        echo 'Testing stage'
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
}