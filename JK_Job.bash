#!/bin/sh

ami_id=$(aws ec2 describe-images --filters "Name=platform,Values=windows" "Name=name,Values=Windows_Server-${OsVersion}_SP1-English-64Bit-Base*" "Name=owner-alias,Values=amazon" --region ${Region} | jq '[.Images[].ImageId][0]' -r)

minprice=$(aws ec2 describe-spot-price-history --region ${Region} --filters "Name=instance-type,Values=t2.micro" "Name=product-description,Values=Windows" --start-time "$(date +%Y-%m-%d)T$(date +%H):00:00" | jq '.SpotPriceHistory[] | .SpotPrice' -r | sort | head -1)

minpriceaz=$(aws ec2 describe-spot-price-history --region ${Region} --filters "Name=instance-type,Values=t2.micro" "Name=product-description,Values=Windows" --start-time "$(date +%Y-%m-%d)T$(date +%H):00:00" | jq --arg minprice ${minprice} '.SpotPriceHistory[] | select(.SpotPrice == $minprice) | .AvailabilityZone' -r)

min2price=$(aws ec2 describe-spot-price-history --region ${Region} --filters "Name=instance-type,Values=t2.micro" "Name=product-description,Values=Windows" --start-time "$(date +%Y-%m-%d)T$(date +%H):00:00" | jq '.SpotPriceHistory[] | .SpotPrice' -r | sort | head -2 | tail -1)

min2priceaz=$(aws ec2 describe-spot-price-history --region ${Region} --filters "Name=instance-type,Values=t2.micro" "Name=product-description,Values=Windows" --start-time "$(date +%Y-%m-%d)T$(date +%H):00:00" | jq --arg min2price ${min2price} '.SpotPriceHistory[] | select(.SpotPrice == $min2price) | .AvailabilityZone' -r | head -1)

ami_id=$(aws ec2 describe-images --filters "Name=platform,Values=windows" "Name=name,Values=Windows_Server-${OsVersion}_SP1-English-64Bit-Base*" "Name=owner-alias,Values=amazon" --region ${Region} | jq '[.Images[].ImageId][0]' -r)

vpc_id=$(aws ec2 describe-vpcs --filters 'Name=tag:Name,Values=DEFAULT' --region ${Region} | jq '.Vpcs[].VpcId' -r)

subnets=$(aws ec2 describe-subnets --region ${Region} --filters "Name=availabilityZone,Values=${minpriceaz},${min2priceaz}" "Name=vpc-id,Values=${vpc_id}" | jq '.Subnets[].SubnetId' -r | paste -d, -s -)

echo -e "${minprice}\t${vpc_id}\t\"${subnets}\"\t${ami_id}"

aws cloudformation create-stack --stack-name ${Stackname} --template-url "https://s3.amazonaws.com/devopslab-cts/CFTemplates/jk-asgwin.json" --parameters "ParameterKey=Subnets,ParameterValue=\"${subnets}\"" "ParameterKey=VpcId,ParameterValue=${vpc_id}" "ParameterKey=OsVersion,ParameterValue=${ami_id}" --capabilities CAPABILITY_IAM --tags "Key=Name,Value=${Stackname}" --region ${Region}
stack_stats=$(aws cloudformation describe-stacks --stack-name ${Stackname} --region ${Region} | jq '.Stacks[].StackStatus' -r)
while [ ${stack_stats} != "CREATE_COMPLETE" ]; do 
	echo ${stack_stats}
    stack_stats=$(aws cloudformation describe-stacks --stack-name ${Stackname} --region ${Region} | jq '.Stacks[].StackStatus' -r)
    sleep 30s
done